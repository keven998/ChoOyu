//
//  ShoppingListViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TripDetailRootViewController.h"
#import "TripDetail.h"

@interface ShoppingListViewController : TZViewController

@property (nonatomic, weak) TripDetailRootViewController *rootViewController;
@property (nonatomic, strong) TripDetail *tripDetail;

@property (nonatomic) BOOL canEdit;
/**
 *  路线是否应该进入编辑状态
 */
@property (nonatomic) BOOL shouldEdit;

@end
