//
//  DayAgendaViewController.h
//  PeachTravel
//
//  Created by Luo Yong on 15/6/12.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripDetail.h"
#import "REFrostedViewController.h"

@interface DayAgendaViewController : TZViewController

- (id)initWithDay:(NSInteger)day;

@property (nonatomic, assign) int currentDay;
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, strong) TripDetail *tripDetail;

@property (nonatomic, strong) UIImage *sceenImage;

@property (nonatomic, assign)int sep;

@end
