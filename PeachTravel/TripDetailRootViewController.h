//
//  TripDetailRootViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RDVTabBarController.h"
#import "TripDetail.h"

@interface TripDetailRootViewController : RDVTabBarController

@property (nonatomic, strong) NSArray *destinations;

@property (nonatomic, strong) TripDetail *tripDetail;

@end
