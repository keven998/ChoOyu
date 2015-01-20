//
//  SpotsListViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripDetailRootViewController.h"
#import "TripDetail.h"
#import "DestinationsView.h"

@interface SpotsListViewController : TZViewController

@property (nonatomic, weak) TripDetailRootViewController *rootViewController;

@property (nonatomic, strong) TripDetail *tripDetail;

/**
 *  是否有资格更改路线，当从聊天界面点击别人发送的攻略进入此界面时，没有资格编辑路线
 */
@property (nonatomic) BOOL canEdit;


@end
