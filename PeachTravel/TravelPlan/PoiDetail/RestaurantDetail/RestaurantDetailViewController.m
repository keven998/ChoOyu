//
//  RestaurantDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/18/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "RestaurantDetailViewController.h"

@implementation RestaurantDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.poiType = kRestaurantPoi;
    NSString *url = [NSString stringWithFormat:@"%@%@", API_GET_RESTAURANT_DETAIL, self.poiId];
    [self loadDataWithUrl:url];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_delicacy_detail"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_delicacy_detail"];
}


@end
