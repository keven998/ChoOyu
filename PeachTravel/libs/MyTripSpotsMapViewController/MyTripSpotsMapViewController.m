//
//  MyTripSpotsMapViewController.m
//  lvxingpai
//
//  Created by liangpengshuai on 14-7-23.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#import "MyTripSpotsMapViewController.h"
#import "SelectionTableViewController.h"
#import "TZButton.h"
#import <MapKit/MapKit.h>

@interface MyTripSpotsMapViewController () <MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, SelectDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UILabel *currentDayLabel;
@property (nonatomic, strong) NSMutableArray *currentAnnotations;
@property (nonatomic, assign) NSUInteger positionCount;      //记录是第几个
@property (nonatomic, strong) MKPolyline *line;
@property (nonatomic, strong) NSArray *pois;

@property (nonatomic, strong) UICollectionView *selectPanel;

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
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.navigationItem.title = _titleText;
    UIBarButtonItem *lbtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_icon_navigaiton_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = lbtn;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 64, 28);
    [btn setTitle:@"01.Day" forState:UIControlStateNormal];
    btn.layer.borderWidth = 1.0;
    btn.layer.cornerRadius = 3.0;
    btn.layer.borderColor = [UIColor whiteColor].CGColor;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn addTarget:self action:@selector(switchDay) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];

    _pois = _tripDetail.itineraryList[_currentDay];
    
    mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0.0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    [self.view addSubview:mapView];
    mapView.mapType = MKMapTypeStandard;
    mapView.delegate = self;
    [self showMapPin];

    [self setupSelectPanel];
}

- (void)viewWillAppear:(BOOL)animated {
    [MobClick beginLogPageView:@"page_plan_map_view"];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [MobClick endLogPageView:@"page_plan_map_view"];
    [super viewWillDisappear:animated];
}

- (void) setupSelectPanel {
    CGRect collectionViewFrame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49, CGRectGetWidth(self.view.bounds), 49);
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.selectPanel = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:aFlowLayout];
    self.selectPanel.showsHorizontalScrollIndicator = NO;
    self.selectPanel.showsVerticalScrollIndicator = NO;
    self.selectPanel.delegate = self;
    self.selectPanel.backgroundColor = [UIColor whiteColor];
    self.selectPanel.dataSource = self;
    self.selectPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.selectPanel.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    [self.selectPanel registerClass:[SelectPoiCell class] forCellWithReuseIdentifier:@"spoi_cell"];
    [self.view addSubview:_selectPanel];
}

#pragma mark - IBAction
- (void) switchDay {
    NSInteger count = _tripDetail.itineraryList.count;
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:(count + 1)];
    int i = 0;
    while (i < count) {
        if (i < 9) {
            [array addObject:[NSString stringWithFormat:@"0%d.Day", ++i]];
        } else {
            [array addObject:[NSString stringWithFormat:@"%d.Day", ++i]];
        }
    }
    
    SelectionTableViewController *ctl = [[SelectionTableViewController alloc] init];
    ctl.contentItems = array;
    ctl.delegate = self;
    ctl.titleTxt = @"切换";
    ctl.selectItem = ((UIButton *)self.navigationItem.rightBarButtonItem.customView).titleLabel.text;
    TZNavigationViewController *nav = [[TZNavigationViewController alloc] initWithRootViewController:ctl];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
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
    
    NSInteger count = _pois.count;
    CLLocationCoordinate2D pointsToUse[count];
    for (int i = 0; i < count; i++) {
        SuperPoi *pb = [_pois objectAtIndex:i];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(pb.lat, pb.lng);
        MKPointAnnotation* item = [[MKPointAnnotation alloc]init];
        item.coordinate = location;
        item.title = pb.zhName;
        
        [_currentAnnotations addObject:item];
        [mapView addAnnotation:item];
        pointsToUse[i] = location;
        
        if (i == 0) {
            [mapView selectAnnotation:item animated:YES];
        }
    }
    [mapView removeOverlay:_line];
    _line = [MKPolyline polylineWithCoordinates:pointsToUse count:count];
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
    
    SuperPoi *pb = [list objectAtIndex:0];
    
//    PositionBean *point = [list objectAtIndex:0];
    minLat = pb.lat;
    minLon = pb.lng;
    maxLat = pb.lat;
    maxLon = pb.lng;
//    PositionBean *b;
    for (int i = 0; i < list.count; i++) {
        pb = list[i];
        curLat = pb.lat;
        curLon = pb.lng;
        
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

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_pois count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectPoiCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"spoi_cell" forIndexPath:indexPath];
    
    SuperPoi *pb = [_pois objectAtIndex:indexPath.row];
    NSString *txt = [NSString stringWithFormat:@"%ld.%@", (indexPath.row + 1), pb.zhName];
    cell.textView.text = txt;
    CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName : cell.textView.font}];
    cell.textView.frame = CGRectMake(0, 0, size.width, 49);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [mapView selectAnnotation:[_currentAnnotations objectAtIndex:indexPath.row] animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    SuperPoi *pb = [_pois objectAtIndex:indexPath.row];
    NSString *txt = [NSString stringWithFormat:@"%ld.%@", (indexPath.row + 1), pb.zhName];
    CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    return CGSizeMake(size.width, 49);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 15.0;
}

#pragma mark - SelectDelegate
- (void) selectItem:(NSString *)str atIndex:(NSIndexPath *)indexPath {
    [((UIButton *)self.navigationItem.rightBarButtonItem.customView) setTitle:str forState:UIControlStateNormal];
    _currentDay = indexPath.row;
    _pois = [self.tripDetail.itineraryList objectAtIndex:_currentDay];

    [self resetView];
}

- (void) resetView {
    [self showMapPin];
    [self.selectPanel reloadData];
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
    newAnnotationView.layer.anchorPoint = CGPointMake(0.7, 0.55);
    NSString *imageName = [NSString stringWithFormat:@"map_icon_%ld.png", index+1];
    newAnnotationView.image = [UIImage imageNamed:imageName];
    return newAnnotationView;
}

- (MKOverlayRenderer*)mapView:(MKMapView*)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineRenderer* lineView = [[MKPolylineRenderer alloc] initWithPolyline:_line];
    lineView.strokeColor = COLOR_CHECKED;
    lineView.lineWidth = 2;
    return lineView;
}

@end

@implementation SelectPoiCell

@synthesize textView;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        textView = [[UILabel alloc] init];
        textView.font = [UIFont systemFontOfSize:17];
        textView.textColor = COLOR_TEXT_II;
        textView.textAlignment = NSTextAlignmentCenter;
        textView.numberOfLines = 1;
        [self.contentView addSubview:textView];
    }
    return self;
}

@end


