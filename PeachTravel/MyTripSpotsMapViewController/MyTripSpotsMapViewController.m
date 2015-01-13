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
@property (nonatomic, strong) NSMutableArray *poisWillShow;       //记录需要显示的poi坐标的数组
@property (nonatomic, strong)  UILabel *currentDayLabel;
@property (nonatomic, strong) NSMutableArray *currentAnnotations;
@property (nonatomic, assign) NSUInteger positionCount;      //记录是第几个
@property (nonatomic, strong)  MKPolyline *line;
@end

@implementation MyTripSpotsMapViewController

@synthesize mapView;
@synthesize pois;

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
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    UIView *stepBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 108, self.view.bounds.size.width, 44.)];
    stepBar.backgroundColor = UIColorFromRGB(0x767f86);
    CALayer *layer = [stepBar layer];
    layer.shadowColor = [UIColor colorWithWhite:0. alpha:0.30].CGColor;
    layer.shadowOffset = CGSizeMake(0, -0.5);
    layer.shadowOpacity = 1.0;
    layer.shadowRadius = 0.5;
//    [self.view addSubview:stepBar];
    
    mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    [self.view addSubview:mapView];
    mapView.mapType = MKMapTypeStandard;
    mapView.delegate = self;
    [self showMapPin];
    
    UIButton *nextDayBtn = [[UIButton alloc] initWithFrame:CGRectMake(125, 12., 35., 20.)];
    [nextDayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [nextDayBtn setImage:[UIImage imageNamed:@"mapright.png"] forState:UIControlStateNormal];
    [nextDayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIButton *formerDayBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 35., 20.)];
    [formerDayBtn setImage:[UIImage imageNamed:@"mapleft.png"] forState:UIControlStateNormal];
    [formerDayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [formerDayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _currentDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(60., 3., 60., 38.)];
    
    _currentDayLabel.text = [NSString stringWithFormat:@"第 1 天"];
    _currentDayLabel.backgroundColor = [UIColor clearColor];
    _currentDayLabel.textColor = [UIColor whiteColor];
    [nextDayBtn addTarget:self action:@selector(nextDay:) forControlEvents:UIControlEventTouchUpInside];
    [formerDayBtn addTarget:self action:@selector(formerDay:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *showAllpositionBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-98.5, 6, 90, 32.)];
    showAllpositionBtn.layer.cornerRadius = 2;
    [showAllpositionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showAllpositionBtn setTitle:@"全部" forState:UIControlStateNormal];
    showAllpositionBtn.backgroundColor = UIColorFromRGB(0x13deac);
    [showAllpositionBtn addTarget:self action:@selector(showAllposition:) forControlEvents:UIControlEventTouchUpInside];
    [stepBar addSubview:showAllpositionBtn];
    [stepBar addSubview:nextDayBtn];
    [stepBar addSubview:formerDayBtn];
    [stepBar addSubview:_currentDayLabel];
//    [self.view addSubview:stepBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void) dealloc {
    mapView = nil;
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
    if (!_poisWillShow) {
        _poisWillShow = [[NSMutableArray alloc] init];
    }
    _positionCount = 0;
    [_poisWillShow removeAllObjects];
    [mapView removeAnnotations:_currentAnnotations];
    [_currentAnnotations removeAllObjects];
    for (PositionBean *position in [pois objectAtIndex:_currentDay-1]) {
        [_poisWillShow addObject:position];
    }
    NSInteger count = _poisWillShow.count;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    CLLocationCoordinate2D pointsToUse[3];
    for (int i = 0; i < count; ++i) {
        PositionBean *pb = [_poisWillShow objectAtIndex:i];
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
    _line = [MKPolyline polylineWithCoordinates:pointsToUse count:count];
    _line.title = @"red";
    [mapView addOverlay:_line level:MKOverlayLevelAboveLabels];
    [self moveMapToCenteratMapView:mapView withArray:_poisWillShow];
}

#pragma mark - action methods

- (void)nextDay:(id)sender
{
    ++_currentDay;
    if (_currentDay == [pois count]+1) {
        _currentDay = 1;
    }
    _currentDayLabel.text = [NSString stringWithFormat:@"第 %ld 天",(long)_currentDay];
    [self showMapPin];
}

- (void)formerDay:(id)sender
{
    --_currentDay;
    if (_currentDay == 0) {
        _currentDay = [pois count];
    }
    _currentDayLabel.text = [NSString stringWithFormat:@"第 %ld 天",(long)_currentDay];
    [self showMapPin];
}

- (void)showAllposition:(id)sender
{
    if (!_currentAnnotations) {
        _currentAnnotations = [[NSMutableArray alloc] init];
    }
    if (!_poisWillShow) {
        _poisWillShow = [[NSMutableArray alloc] init];
    }
    _currentDayLabel.text = @"全部";
    [mapView removeAnnotations:_currentAnnotations];
    
    [_currentAnnotations removeAllObjects];
    [_poisWillShow removeAllObjects];
    _positionCount = 0;
    
    for (NSArray *oneDay in pois) {
        for (PositionBean *position in oneDay) {
            [_poisWillShow addObject:position];
        }
    }
    NSInteger count = _poisWillShow.count;
    
    for (int i = 0; i < count; ++i) {
        PositionBean *pb = [_poisWillShow objectAtIndex:i];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(pb.latitude, pb.longitude);
        MKPointAnnotation* item = [[MKPointAnnotation alloc]init];
        
        item.coordinate = location;
        item.title = pb.poiName;
        [_currentAnnotations addObject:item];
        [mapView addAnnotation:item];
        if (i == 0) {
            [mapView selectAnnotation:item animated:YES];
        }
    }
    
    [self moveMapToCenteratMapView:mapView withArray:_poisWillShow];
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
    UIButton *advertButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    advertButton.frame = CGRectMake(0, 0, 15, 23);
    advertButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    advertButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [advertButton setImage:[UIImage imageNamed:@"cell_accessory_gray.png"] forState:UIControlStateNormal];

    newAnnotationView.rightCalloutAccessoryView = advertButton;
    newAnnotationView.pinColor = MKPinAnnotationColorRed;

    newAnnotationView.annotation = annotation;
    newAnnotationView.canShowCallout = YES;
    newAnnotationView.tag = index;
    
//    if (index <= 20) {
//        newAnnotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"map%ld.png", (long)index+1]];
//    } else {
//        newAnnotationView.image = [UIImage imageNamed:[NSString stringWithFormat:@"mapempty.png"]];
//    }
    
    return newAnnotationView;
}

- (MKOverlayRenderer*)mapView:(MKMapView*)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineRenderer* lineView = [[MKPolylineRenderer alloc] initWithPolyline:_line];
    lineView.strokeColor = [UIColor blueColor];
    lineView.lineWidth = 2;
    return lineView;
}
@end



