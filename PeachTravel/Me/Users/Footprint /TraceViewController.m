//
//  FootprintViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/5/22.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "TraceViewController.h"
#import <MapKit/MapKit.h>

@interface TraceViewController ()<MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *currentAnnotations;

@property (nonatomic, strong) UICollectionView *selectPanel;

@end

@implementation TraceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0.0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) )];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_mapView];
    _mapView.mapType = MKMapTypeStandard;
    _mapView.delegate = self;
    
    [self showMapPin];
    [self setupSelectPanel];
}

- (void)showMapPin
{
    if (!_currentAnnotations) {
        _currentAnnotations = [[NSMutableArray alloc] init];
    }
    
    [_mapView removeAnnotations:_currentAnnotations];
    [_currentAnnotations removeAllObjects];

    NSInteger count = _citys.count;
    for (int i = 0; i < count; i++) {
        CityDestinationPoi *pb = [_citys objectAtIndex:i];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(pb.lat, pb.lng);
        MKPointAnnotation* item = [[MKPointAnnotation alloc]init];
        item.coordinate = location;
        item.title = pb.zhName;
        
        [_currentAnnotations addObject:item];
        [_mapView addAnnotation:item];
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMake(_mapView.centerCoordinate, MKCoordinateSpanMake(180, 360));
    [_mapView setRegion:region animated:YES];
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(39.54, 116.23)];
}

- (void) setupSelectPanel {
    CGRect collectionViewFrame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49, CGRectGetWidth(self.view.bounds), 49);
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.selectPanel = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:aFlowLayout];
    [self.selectPanel setBackgroundColor:[UIColor clearColor]];
    self.selectPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.selectPanel.showsHorizontalScrollIndicator = NO;
    self.selectPanel.showsVerticalScrollIndicator = NO;
    self.selectPanel.delegate = self;
    self.selectPanel.dataSource = self;
    self.selectPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.selectPanel.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    [self.selectPanel registerClass:[CityCell class] forCellWithReuseIdentifier:@"city_cell"];
    
    UIImageView *collectionBg = [[UIImageView alloc]initWithFrame:self.selectPanel.frame];
    collectionBg.image = [UIImage imageNamed:@"collectionBack"];
    collectionBg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:collectionBg];
    
    [self.view addSubview:_selectPanel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_citys count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"city_cell" forIndexPath:indexPath];
    
    CityDestinationPoi *pb = [_citys objectAtIndex:indexPath.row];
    cell.textView.text = pb.zhName;
    cell.textView.textColor = [UIColor whiteColor];
    CGSize size = [pb.zhName sizeWithAttributes:@{NSFontAttributeName : cell.textView.font}];
    cell.textView.frame = CGRectMake(0, 0, size.width, 49);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [_mapView selectAnnotation:[_currentAnnotations objectAtIndex:indexPath.row] animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CityDestinationPoi *pb = [_citys objectAtIndex:indexPath.row];
    NSString *txt = pb.zhName;
    
    CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    return CGSizeMake(size.width, 49);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 15.0;
}



@end

@implementation CityCell

@synthesize textView;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        textView = [[UILabel alloc] init];
        textView.font = [UIFont systemFontOfSize:17];
        textView.textColor = [UIColor blueColor];
        textView.textAlignment = NSTextAlignmentCenter;
        textView.numberOfLines = 1;
        [self.contentView addSubview:textView];
    }
    return self;
}

@end
