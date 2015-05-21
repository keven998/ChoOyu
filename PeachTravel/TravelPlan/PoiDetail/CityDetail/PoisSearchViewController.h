//
//  PoisSearchViewController.h
//  PeachTravel
//
//  Created by dapiao on 15/5/20.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripDetail.h"
@interface PoisSearchViewController : UIViewController


@property (nonatomic, copy) NSString *cityId; //当前显示的城市
@property (nonatomic, copy) NSString *zhName; //当前显示的城市


@property (nonatomic) TZPoiType poiType;
@property (nonatomic, strong) TripDetail *tripDetail;

@end