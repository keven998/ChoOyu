//
//  AddPoiTableViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripDetail.h"

@protocol addPoiDelegate <NSObject>

- (void)finishEdit;

@end

@interface AddPoiViewController :TZViewController

@property (nonatomic, strong) TripDetail *tripDetail;

@property (nonatomic) NSUInteger currentDayIndex;    //标识添加到哪一天

@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, copy) NSString *cityName;
@property (nonatomic) TZPoiType poiType;


/**
 *  是否可以添加。如果从城市详情进来不可以，如果从三账单进来可以
 */
@property (nonatomic) BOOL shouldEdit;

@property (nonatomic, weak) id <addPoiDelegate> delegate;


@end