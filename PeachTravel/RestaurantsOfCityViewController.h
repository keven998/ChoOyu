//
//  RestaurantsOfCityViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityPoi.h"

@interface RestaurantsOfCityViewController : UIViewController

@property (strong, nonatomic) NSArray *cities;
@property (nonatomic, strong) CityPoi *currentCity; //当前显示的城市

@end
