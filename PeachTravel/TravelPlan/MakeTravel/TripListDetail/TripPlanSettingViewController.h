//
//  TripPlanSettingViewController.h
//  PeachTravel
//
//  Created by Luo Yong on 15/4/14.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripDetailRootViewController.h"
#import "SpotDetailViewController.h"

@interface TripPlanSettingViewController : UIViewController
@property (nonatomic,strong) TripDetail *tripDetail;
@property (nonatomic, weak) TripDetailRootViewController *rootViewController;
@end
