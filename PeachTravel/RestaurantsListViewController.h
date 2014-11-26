//
//  RestaurantsListViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripDetailRootViewController.h"
#import "TripDetail.h"

@interface RestaurantsListViewController : UIViewController

@property (nonatomic, weak) TripDetailRootViewController *rootViewController;
@property (nonatomic, strong) TripDetail *tripDetail;

@end
