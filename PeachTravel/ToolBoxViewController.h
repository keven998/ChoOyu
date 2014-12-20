//
//  ToolBoxViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/21.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YWeatherUtils.h"
#import "HomeViewController.h"

@interface ToolBoxViewController : UIViewController

@property (strong, nonatomic) WeatherInfo *weatherInfo;
@property (strong, nonatomic) CLLocation *location;

@property (nonatomic, weak) HomeViewController *rootCtl;


@end
