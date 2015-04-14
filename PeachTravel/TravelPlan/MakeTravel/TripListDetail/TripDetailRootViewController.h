//
//  TripDetailRootViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TripDetail.h"

@protocol TripUpdateDelegate;
@interface TripDetailRootViewController : UIViewController

@property (nonatomic, strong) TripDetail *tripDetail;
@property (nonatomic, strong) NSArray *destinations;

@property (nonatomic, weak) id<TripUpdateDelegate> contentMgrDelegate;

//编辑按钮
@property (nonatomic, strong) UIButton *editBtn;

/**
 *  进入三账单会有两种情况，一种是传目的地列表新制作攻略，另一种是传攻略 id 来查看攻略
 */
@property (nonatomic, assign) BOOL isMakeNewTrip;

/**
 *  是否有资格更改路线，当从聊天界面点击别人发送的攻略进入此界面时，没有资格编辑路线
 */
@property (nonatomic, assign) BOOL canEdit;

@property (nonatomic, copy) NSString *tripId;

/**
 *  当前 viewcontroller 是否正在显示
 */
@property (nonatomic) BOOL isShowing;

@end

@protocol TripUpdateDelegate <NSObject>

- (void) tripUpdate:(id)detail;

@end
