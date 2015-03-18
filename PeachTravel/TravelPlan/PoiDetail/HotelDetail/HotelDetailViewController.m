//
//  HotelDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/18/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "HotelDetailViewController.h"

@implementation HotelDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.poiType = kShoppingPoi;
    NSString *url = [NSString stringWithFormat:@"%@%@", API_GET_HOTEL_DETAIL, self.poiId];
    [self loadDataWithUrl:url];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_hotel_detail"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_hotel_detail"];
}

@end
