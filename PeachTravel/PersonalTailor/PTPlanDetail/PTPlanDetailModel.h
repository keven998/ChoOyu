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

@property (nonatomic) NSInteger planId;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic) long commitTime;
@property (nonatomic, copy, readonly) NSString *commitTimeStr;
@property (nonatomic) float totalPrice;
@property (nonatomic) BOOL hasBuy;  //是否已经购买此方案
@property (nonatomic, strong) FrendModel *seller;
@property (nonatomic, strong) NSArray<MyGuideSummary *> *dataSource;

- (id)initWithJson:(id)json;

@end
