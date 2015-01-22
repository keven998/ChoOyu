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

@interface PoisOfCityViewController : UIViewController

@property (nonatomic, copy) NSString *cityId; //当前显示的城市
@property (nonatomic, copy) NSString *zhName; //当前显示的城市

/**
 *  标记是从三账单进来的还是从从城市详情界面进来的
 */
@property (nonatomic) BOOL shouldEdit;

@property (nonatomic, strong) TripDetail *tripDetail;

@property (nonatomic) TZPoiType poiType;


@property (nonatomic, assign) id <PoisOfCityDelegate>delegate;

@end
