//
//  MyTripSpotsMapViewController.h
//  lvxingpai
//
//  Created by liangpengshuai on 14-7-23.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PositionBean;

@interface MyTripSpotsMapViewController : UIViewController
@property (nonatomic, strong) NSArray *pois;
@property (nonatomic, assign) NSUInteger currentDay;         //标记当前是第几天

@end
