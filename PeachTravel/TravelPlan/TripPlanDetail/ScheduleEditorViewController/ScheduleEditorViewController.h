//
//  ScheduleEditorViewController.h
//  PeachTravel
//
//  Created by Luo Yong on 15/6/13.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripDetail.h"

@protocol ScheduleUpdateDelegate;
@interface ScheduleEditorViewController : UIViewController

@property (nonatomic, strong) TripDetail *tripDetail;

@end

@protocol ScheduleUpdateDelegate <NSObject>

- (void) updateSchedule:(TripDetail *)newTrip;

@end