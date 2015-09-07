/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "LocationViewController.h"

#import "UIViewController+HUD.h"

static LocationViewController *defaultLocation = nil;

@interface LocationViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
{
    MKMapView *_mapView;
    MKPointAnnotation *_annotation;
    CLLocationCoordinate2D _currentLocationCoordinate;
    BOOL _isSendLocation;
    CLLocationManager* location;
    LocationModel *locModel;
}

@property (strong, nonatomic) NSString *addressString;

@end

@implementation LocationViewController

@synthesize addressString = _addressString;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isSendLocation = YES;
    }
    
    return self;
}

- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _isSendLocation = NO;
        _currentLocationCoordinate = locationCoordinate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"位置";
    locModel = [[LocationModel alloc]init];
    UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithTitle:@" 取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = backBtn;
    
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    _mapView.mapType = MKMapTypeStandard;
    _mapView.zoomEnabled = YES;
    [self.view addSubview:_mapView];
    
    if (_isSendLocation) {
        _mapView.showsUserLocation = YES;//显示当前位置
        
        UIBarButtonItem * sendButton = [[UIBarButtonItem alloc]initWithTitle:@"发送 " style:UIBarButtonItemStylePlain target:self action:@selector(sendLocation)];
        sendButton.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = sendButton;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        [self startLocation];
        location = [[CLLocationManager alloc] init];
        location.delegate= self;
        [location requestAlwaysAuthorization];
    }
    else{
        [self removeToLocation:_currentLocationCoordinate];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
      
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    if (location != nil) {
        [location stopUpdatingLocation];
        location = nil;
    }
    _mapView = nil;
    _annotation = nil;
}

#pragma mark - class methods

+ (instancetype)defaultLocation
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultLocation = [[LocationViewController alloc] initWithNibName:nil bundle:nil];
    });
    
    return defaultLocation;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    __weak typeof(self) weakSelf = self;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            weakSelf.addressString = placemark.name;
            locModel.address = placemark.name;
            locModel.latitude = userLocation.coordinate.latitude;
            locModel.longitude = userLocation.coordinate.longitude;
            [self removeToLocation:userLocation.coordinate];
        }
    }];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [self hideHud];
    [self showHint:@"定位失败"];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        casekCLAuthorizationStatusNotDetermined:
            break;
        default:
            break;
    }
}

#pragma mark - public

- (void)startLocation
{
    if (_isSendLocation) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    [self showHudInView:self.view hint:@"正在定位..."];
}

-(void)createAnnotationWithCoords:(CLLocationCoordinate2D)coords
{
    if (_annotation == nil) {
        _annotation = [[MKPointAnnotation alloc] init];
    }
    else{
        [_mapView removeAnnotation:_annotation];
    }
    _annotation.coordinate = coords;
    [_mapView addAnnotation:_annotation];
}

- (void)removeToLocation:(CLLocationCoordinate2D)locationCoordinate
{
    [self hideHud];
    _currentLocationCoordinate = locationCoordinate;
    float zoomLevel = 0.005;
    MKCoordinateRegion region = MKCoordinateRegionMake(_currentLocationCoordinate, MKCoordinateSpanMake(zoomLevel, zoomLevel));
    [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    
    if (_isSendLocation) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [self createAnnotationWithCoords:_currentLocationCoordinate];
}

- (UIImage *)screenShotWithView
{
    UIGraphicsBeginImageContext(self.view.bounds.size) ;
    [[self.view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = viewImage.CGImage;
    CGFloat y = ((self.view.bounds.size.height-64)-kWindowWidth*2/3)/2+64;
    CGRect rect = CGRectMake(0, y, kWindowWidth, kWindowWidth*2/3);
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
    UIImage *sendImage = [[UIImage alloc] initWithCGImage:imageRefRect];
    //    NSData *imageData = UIImagePNGRepresentation(sendImage);
    //    sendImage = [UIImage imageWithData:imageData];
    
    return sendImage;
}

- (void)sendLocation
{
    if (_delegate && [_delegate respondsToSelector:@selector(sendLocation:locImage:)]) {
        [_delegate sendLocation:locModel locImage:[self screenShotWithView]];
    }
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.3];
}

- (void) dismiss {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
        
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
