//
//  PTPlanDetailModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 4/18/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeachTravel-swift.h"
#import "MyGuideSummary.h"

@interface PTPlanDetailModel : NSObject

@property (nonatomic, copy) NSString *planId;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *commitTimeStr;
@property (nonatomic) float totalPrice;
@property (nonatomic, strong) FrendModel *seller;
@property (nonatomic, strong) NSArray<MyGuideSummary *> *dataSource;

@end
