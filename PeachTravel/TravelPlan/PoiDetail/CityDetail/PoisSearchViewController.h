//
//  PoisSearchViewController.h
//  PeachTravel
//
//  Created by dapiao on 15/5/20.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripDetail.h"

@protocol updateSelectedPlanDelegate <NSObject>

- (void)updateSelectedPlan;

@end

@interface PoisSearchViewController : UIViewController


@property (nonatomic, copy) NSString *cityId; //当前显示的城市
@property (nonatomic, copy) NSString *zhName; //当前显示的城市

@property (nonatomic) NSUInteger currentDayIndex;

@property (nonatomic) TZPoiType poiType;
@property (nonatomic, strong) TripDetail *tripDetail;
@property (nonatomic) BOOL shouldEdit;

//进入此界面可能是行程编辑界面进来的，也可能是收藏界面进来的，两者显示的状态不一样
@property (nonatomic) BOOL isAddPoi;

@property (nonatomic, weak) id<updateSelectedPlanDelegate> delegate;

@end
