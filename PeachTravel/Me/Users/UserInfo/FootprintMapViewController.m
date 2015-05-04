//
//  FootprintMapViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/26/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "FootprintMapViewController.h"

@interface FootprintMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) NSMutableArray *annotationsArray;

@end

@implementation FootprintMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mapView.showsBuildings = YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)annotationsArray
{
    if (!_annotationsArray) {
        _annotationsArray = [[NSMutableArray alloc] init];
    }
    return _annotationsArray;
}

- (void)addPoint:(CLLocation *)location
{
    MKPointAnnotation* item = [[MKPointAnnotation alloc]init];
    item.coordinate = location.coordinate;
    [_annotationsArray addObject:item];
    [_mapView addAnnotation:item];
    [_mapView setCenterCoordinate:location.coordinate animated:YES];
}

- (void)removePoint:(CLLocation *)location
{
    for (int i = 0; i < self.annotationsArray.count; i++) {
        MKPointAnnotation *item = self.annotationsArray[i];
        if (item.coordinate.latitude == location.coordinate.latitude && item.coordinate.longitude == location.coordinate.longitude) {
            [self.annotationsArray removeObject:item];
            break;
        }
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}
-(void)viewWillDisappear:(BOOL)animated
{
//    self.navigationController.navigationBarHidden = YES;
}
@end






