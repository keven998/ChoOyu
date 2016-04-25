//
//  PTPlanDetailViewController.h
//  PeachTravel
//
//  Created by liangpengshuai on 4/18/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPlanDetailModel.h"

@interface PTPlanDetailViewController : TZViewController

@property (nonatomic, strong) PTPlanDetailModel *ptPlanDetail;
@property (nonatomic) NSInteger publishUserId;
@property (nonatomic, copy) NSString *ptId;

@property (nonatomic) BOOL hasBuy;

@end
