//
//  TravelerInfoViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/16/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderTravelerInfoModel.h"

@interface TravelerInfoViewController : TZViewController

@property (nonatomic) BOOL isEditTravelerInfo;   //是否是编辑旅客信息
@property (nonatomic) BOOL isAddTravelerInfo;    //是否是添加旅客信息


@property (nonatomic, strong) OrderTravelerInfoModel *traveler;

@end
