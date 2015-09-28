//
//  ShoppingDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/18/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.


#import "ShoppingDetailViewController.h"

@implementation ShoppingDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.poiType = kShoppingPoi;
    NSString *url = [NSString stringWithFormat:@"%@%@", API_GET_SHOPPING_DETAIL, self.poiId];
    [self loadDataWithUrl:url];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
      
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

@end
