//
//  RestaurantsOfCityViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityPoi.h"
#import "TripDetail.h"

@protocol RestaurantsOfCityDelegate <NSObject>

- (void)finishEdit;

@end

@interface RestaurantsOfCityViewController : TZViewController

@property (nonatomic, strong) CityPoi *currentCity; //当前显示的城市

@property (nonatomic) BOOL shouldEdit;

@property (nonatomic, strong) TripDetail *tripDetail;


@property (nonatomic, assign) id <RestaurantsOfCityDelegate>delegate;
@end
