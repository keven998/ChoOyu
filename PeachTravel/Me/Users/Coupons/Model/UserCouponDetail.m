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
        _title = [json objectForKey:@"title"];
        _desc = [json objectForKey:@"desc"];
        _limitMoney = [[json objectForKey:@"threshold"] floatValue];
        _useDate = [json objectForKey:@"expire"];
        _discount = [[json objectForKey:@"discount"] floatValue];
        
        NSDate *expirDate = [ConvertMethods stringToDate:_useDate withFormat:@"yyyy-MM-dd" withTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
        _isExpire = ([[NSDate date] compare: [NSDate dateWithTimeIntervalSince1970:([expirDate timeIntervalSince1970] + 24*60*60-1)]] == NSOrderedDescending);
    }
    return self;
}

- (NSString *)limitMoneyDesc
{
    if (_limitMoney == 0) {
        return @"无条件使用";
    } else {
        return [NSString stringWithFormat:@"满%@元可用", [self formatLimitMoney]];
    }
}

- (NSString *)formatLimitMoney
{
    NSString *priceStr;
    float currentPrice = round(_limitMoney*100)/100;
    if (!(currentPrice - (int)currentPrice)) {
        priceStr = [NSString stringWithFormat:@"%d", (int)currentPrice];
    } else {
        NSString *tempPrice = [NSString stringWithFormat:@"%.1f", currentPrice];
        if (!(_limitMoney - tempPrice.floatValue)) {
            priceStr = [NSString stringWithFormat:@"%.1f", currentPrice];
        } else {
            priceStr = [NSString stringWithFormat:@"%.2f", currentPrice];
        }
    }
    return priceStr;
}

- (NSString *)formatDiscount
{
    NSString *priceStr;
    float currentPrice = round(_discount*100)/100;
    if (!(currentPrice - (int)currentPrice)) {
        priceStr = [NSString stringWithFormat:@"%d", (int)currentPrice];
    } else {
        NSString *tempPrice = [NSString stringWithFormat:@"%.1f", currentPrice];
        if (!(_discount - tempPrice.floatValue)) {
            priceStr = [NSString stringWithFormat:@"%.1f", currentPrice];
        } else {
            priceStr = [NSString stringWithFormat:@"%.2f", currentPrice];
        }
    }
    return priceStr;
}

@end
