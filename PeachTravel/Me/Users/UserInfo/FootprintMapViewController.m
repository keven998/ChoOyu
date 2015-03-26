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

@end

@implementation FootprintMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addPoint:(CLLocation *)location
{
    MKPointAnnotation* item = [[MKPointAnnotation alloc]init];
    item.coordinate = location.coordinate;
    [_mapView addAnnotation:item];
}

- (void)removePoint:(CLLocation *)location
{
    
}

@end
