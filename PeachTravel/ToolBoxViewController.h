//
//  ToolBoxViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/21.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YWeatherUtils.h"

@interface ToolBoxViewController : TZViewController

@property (strong, nonatomic) WeatherInfo *weatherInfo;
@property (strong, nonatomic) CLLocation *location;

@end
