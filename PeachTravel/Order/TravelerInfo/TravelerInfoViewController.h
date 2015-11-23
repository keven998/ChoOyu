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

@property (nonatomic) BOOL isEditTravelerInfo;

@property (nonatomic, strong) OrderTravelerInfoModel *traveler;

@end
