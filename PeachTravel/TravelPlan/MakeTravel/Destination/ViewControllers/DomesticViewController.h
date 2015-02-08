//
//  DomesticViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Destinations.h"
@class MakePlanViewController;

@interface DomesticViewController : TZViewController

@property (nonatomic, strong) Destinations *destinations;

@property (nonatomic, weak) MakePlanViewController *makePlanCtl;     //将控制类传入本 controller

- (void)reloadData;


@end
