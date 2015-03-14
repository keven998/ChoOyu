//
//  ForeignViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/19/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Destinations.h"
#import "MakePlanViewController.h"

@interface ForeignViewController : TZViewController

@property (nonatomic, strong) Destinations *destinations;

@property (nonatomic, weak) MakePlanViewController *makePlanCtl;     //将控制类传入本 controller

/**
 *  刷新数据
 */
- (void)reloadData;

@end
