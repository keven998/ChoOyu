//
//  MyTripSpotsMapViewController.m
//  lvxingpai
//
//  Created by liangpengshuai on 14-7-23.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#import "MyTripSpotsMapViewController.h"
#import "PositionBean.h"
#import <MapKit/MapKit.h>

@interface MyTripSpotsMapViewController () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UILabel *currentDayLabel;
@property (nonatomic, strong) NSMutableArray *currentAnnotations;
@property (nonatomic, assign) NSUInteger positionCount;      //记录是第几个
@property (nonatomic, strong) MKPolyline *line;
@end

@implementation MyTripSpotsMapViewController

@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"地图";
    self.view.backgroundColor = [UIColor whiteColor];
    
    mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0.0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    [self.view addSubview:mapView];
    mapView.mapType = MKMapTypeStandard;
    mapView.delegate = self;
    [self showMapPin];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)dealloc
{
    self.mapView.showsUserLocation = NO;
    self.mapView.userTrackingMode  = MKUserTrackingModeNone;
    [self.mapView.layer removeAllAnimations];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeFromSuperview];
    self.mapView.delegate = nil;
    self.mapView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)showMapPin
{
    if (!_currentAnnotations) {
        _currentAnnotations = [[NSMutableArray alloc] init];
    }
    _positionCount = 0;

    [mapView removeAnnotations:_currentAnnotations];
    [_currentAnnotations removeAllObjects];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    CLLocationCoordinate2D pointsToUse[_pois.count];
    for (int i = 0; i < _pois.count; i++) {
        PositionBean *pb = [_pois objectAtIndex:i];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(pb.latitude, pb.longitude);
        MKPointAnnotation* item = [[MKPointAnnotation alloc]init];
        item.coordinate = location;
        item.title = pb.poiName;
        [tempArray addObject:item];
        [_currentAnnotations addObject:item];
        [mapView addAnnotation:item];
        pointsToUse[i] = location;
        
        if (i == 0) {
            [mapView selectAnnotation:item animated:YES];
        }
    }
    _line = [MKPolyline polylineWithCoordinates:pointsToUse count:_pois.count];
    [mapView addOverlay:_line level:MKOverlayLevelAboveLabels];
    [self moveMapToCenteratMapView:mapView withArray:_pois];
}

//设置百度地图缩放级别
- (void)  moveMapToCenteratMapView:(MKMapView *)mv_bmap withArray: (NSArray *)list
{
    if (!list) {
        return;
    }
    
    if (0 == list.count) {
        return;
    }
    
    double minLat = 0.0;
    double minLon = 0.0;
    double maxLat = 0.0;
    double maxLon = 0.0;
    
    double curLat = 0.0;
    double curLon = 0.0;
    
    PositionBean *point = [list objectAtIndex:0];
    minLat = point.latitude;
    minLon = point.longitude;
    maxLat = point.latitude;
    maxLon = point.longitude;
    PositionBean *b;
    for (int i = 0; i < list.count; i++) {
        b = list[i];
        curLat = b.latitude;
        curLon = b.longitude;
        
        minLat = (minLat > curLat) ? curLat : minLat;
        maxLat = (maxLat < curLat) ? curLat : maxLat;
        minLon = (minLon > curLon) ? curLon : minLon;
        maxLon = (maxLon < curLon) ? curLon : maxLon;
    }
    minLon = minLon - 0.01;
    minLat = minLat - 0.01;
    maxLon = maxLon + 0.01;
    maxLat = maxLat + 0.01;
    double midLat = (minLat + maxLat) / 2;
    double midLon = (minLon + maxLon) / 2;
    CLLocationCoordinate2D centerPoint = CLLocationCoordinate2DMake(midLat, midLon);
    MKCoordinateSpan span = MKCoordinateSpanMake((maxLat - minLat)*1.2, (maxLon - minLon)*1.2);
    MKCoordinateRegion region = MKCoordinateRegionMake(centerPoint,span);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:region];
    [mv_bmap setRegion:adjustedRegion animated:YES];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)sender annotationView:(MKAnnotationView *)aView
calloutAccessoryControlTapped:(UIControl *)control{
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSInteger index = [_currentAnnotations indexOfObject:annotation];
    
    MKPinAnnotationView *newAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[annotation title]];
    newAnnotationView.pinColor = MKPinAnnotationColorRed;

    newAnnotationView.annotation = annotation;
    newAnnotationView.canShowCallout = YES;
    newAnnotationView.tag = index;

    
    return newAnnotationView;
}

- (MKOverlayRenderer*)mapView:(MKMapView*)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineRenderer* lineView = [[MKPolylineRenderer alloc] initWithPolyline:_line];
    lineView.strokeColor = APP_SUB_THEME_COLOR;
    lineView.lineWidth = 2;
    return lineView;
}
@end



