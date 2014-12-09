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

@interface AddPoiTableViewController :TZTableViewController

@property (nonatomic, strong) TripDetail *tripDetail;
@property (nonatomic) NSUInteger currentDayIndex;    //标识添加到哪一天

@property (nonatomic, assign) id <addPoiDelegate> delegate;

- (void)loadData;

@end
