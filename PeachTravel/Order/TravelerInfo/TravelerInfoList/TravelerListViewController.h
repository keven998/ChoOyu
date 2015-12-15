//
//  TravelerListViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTravelerInfoModel.h"

@interface TravelerListViewController : TZViewController

@property (nonatomic, strong) NSArray<OrderTravelerInfoModel *> *travelerList;

//是否是查看我的旅客信息列表
@property (nonatomic) BOOL isCheckMyTravelers;


@end
