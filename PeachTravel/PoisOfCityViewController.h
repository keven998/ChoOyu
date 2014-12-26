//
//  PoisOfCityViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityPoi.h"
#import "TripDetail.h"
#import "TZTBViewController.h"

@protocol PoisOfCityDelegate <NSObject>

- (void)finishEdit;

@end

@interface PoisOfCityViewController : TZTBViewController

@property (nonatomic, copy) NSString *cityId; //当前显示的城市
@property (nonatomic, copy) NSString *zhName; //当前显示的城市

@property (nonatomic) BOOL shouldEdit;

@property (nonatomic, strong) TripDetail *tripDetail;

@property (nonatomic) tripPoiType poiType;


@property (nonatomic, assign) id <PoisOfCityDelegate>delegate;
@end
