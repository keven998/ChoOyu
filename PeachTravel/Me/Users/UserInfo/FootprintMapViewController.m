//
//  FootprintMapViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/26/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "FootprintMapViewController.h"
#import "DomesticViewController.h"
#import "ForeignViewController.h"

@interface FootprintMapViewController () <MKMapViewDelegate>
{
    UISegmentedControl *_segmentControl;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSArray *annotationsArray;

@end

@implementation FootprintMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mapView.showsBuildings = YES;
    _mapView.delegate = self;
}

#pragma mark - setter or getter
- (void)setDataSource:(NSArray *)dataSource
{
    _dataSource = dataSource;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in _dataSource) {
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(poi.lat, poi.lng);
        MKPointAnnotation* item = [[MKPointAnnotation alloc]init];
        item.coordinate = location;
        item.title = poi.zhName;
        [array addObject:item];
    }
    [self showMapPinWithAnnotations:array];
}

- (void)selectPointAtIndex:(NSInteger)index
{
    [_mapView selectAnnotation:[_annotationsArray objectAtIndex:index] animated:YES];
    
}

- (void)showMapPinWithAnnotations:(NSArray *)annotations
{
    [_mapView removeAnnotations:_annotationsArray];
    
    _annotationsArray = annotations;
    NSInteger count = _annotationsArray.count;
    for (int i = 0; i < count; i++) {
        MKPointAnnotation *item = [_annotationsArray objectAtIndex:i];
        [_mapView addAnnotation:item];
    }
    
    MKCoordinateRegion region = MKCoordinateRegionMake(_mapView.centerCoordinate, MKCoordinateSpanMake(180, 360));
    [_mapView setRegion:region animated:YES];
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(39.54, 116.23)];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)sender annotationView:(MKAnnotationView *)aView calloutAccessoryControlTapped:(UIControl *)contro
{
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSInteger index = [_annotationsArray indexOfObject:annotation];
    
    MKPinAnnotationView *newAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:[annotation title]];
    newAnnotationView.pinColor = MKPinAnnotationColorRed;
    
    newAnnotationView.annotation = annotation;
    newAnnotationView.canShowCallout = YES;
    newAnnotationView.tag = index;
    NSString *imageName = @"map_icon.png";
    newAnnotationView.image = [UIImage imageNamed:imageName];
    
    return newAnnotationView;
}

@end






