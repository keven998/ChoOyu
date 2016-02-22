//
//  UserCouponsDetail.m
//  PeachTravel
//
//  Created by liangpengshuai on 2/18/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "UserCouponDetail.h"

@implementation UserCouponDetail

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _couponId = [json objectForKey:@"id"];
        _title = [json objectForKey:@"desc"];
        _limitMoney = [[json objectForKey:@"threshold"] floatValue];
        _useDate = [json objectForKey:@"expire"];
        _discount = [[json objectForKey:@"discount"] floatValue];
    }
    return self;
}

- (NSString *)limitMoneyDesc
{
    if (_limitMoney == 0) {
        return @"无条件使用";
    } else {
        return [NSString stringWithFormat:@"满%d元可用", (int)_limitMoney];
    }
}

@end
