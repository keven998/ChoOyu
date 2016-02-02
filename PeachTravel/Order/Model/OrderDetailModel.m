//
//  OrderDetailModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/10/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "OrderDetailModel.h"
#import "OrderManager.h"

@implementation OrderDetailModel

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _orderId = [[json objectForKey:@"orderId"] integerValue];
        if ([json objectForKey:@"contact"] != [NSNull null]) {
            _orderContact = [[OrderTravelerInfoModel alloc] initWithJson:[json objectForKey:@"contact"]];
        }
        _selectedPackage.packageId = [json objectForKey:@"planId"];
        _goods = [[GoodsDetailModel alloc] initWithJson:[json objectForKey:@"commodity"]];
        _selectedPackage = [_goods.packages firstObject];
        _count = [[json objectForKey:@"quantity"] integerValue];
        _totalPrice = [[json objectForKey:@"totalPrice"] floatValue];
        _leaveMessage = [json objectForKey:@"comment"];
        _useDate = [json objectForKey:@"rendezvousTime"];
        _updateTime = [[json objectForKey:@"updateTime"] doubleValue]/1000;
        _expireTime = [[json objectForKey:@"expireTime"] doubleValue]/1000;
        _currentTime = [[NSDate date] timeIntervalSince1970];
        _orderStatus = [OrderManager orderStatusWithServerOrderStatus:[json objectForKey:@"status"]];
        NSMutableArray *tempTravelerList = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in [json objectForKey:@"travellers"]) {
            OrderTravelerInfoModel *traveler = [[OrderTravelerInfoModel alloc] initWithJson:dic];
            [tempTravelerList addObject:traveler];
        }
        _travelerList = tempTravelerList;
        
        NSMutableArray *activities = [[NSMutableArray alloc] init];
        for (NSDictionary *activityDic in [json objectForKey:@"activities"]) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:[[activityDic objectForKey:@"timestamp"] longLongValue]/1000];
            NSString *dateStr = [ConvertMethods dateToString:createDate withFormat:@"yyyy-MM-dd HH:mm:ss" withTimeZone:[NSTimeZone systemTimeZone]];
            [dic safeSetObject:dateStr forKey:@"time"];
            if ([self activityDescWithStatus:activityDic]) {
                [dic setObject:[self activityDescWithStatus:activityDic] forKey:@"status"];
                [activities addObject:dic];
            }
            
        }
        _orderActivityList = activities;
        [self canRefundApplyWithStatusDic:[json objectForKey:@"activities"]];

    }
    return self;
}

- (void)canRefundApplyWithStatusDic:(NSArray *)orderActivities
{
    for (NSDictionary *statusDic in orderActivities) {
        if ([[statusDic objectForKey:@"action"] isEqualToString:@"refundDeny"]) {
            _isRefundDenyBySeller = YES;
            return;
        }
    }
    _isRefundDenyBySeller = NO;
}

//通过订单的状态的变化得到状态变化的描述
- (NSString *)activityDescWithStatus:(NSDictionary *)statusDic
{
    NSString *retStr;
    NSString *status = [statusDic objectForKey:@"action"];
    if ([status isEqualToString:@"create"]) {
        retStr = @"买家提交订单";
        
    } else if ([status isEqualToString:@"cancel"]) {
        
        //取消订单分为卖家取消和买家取消，通过 userId 来判断
        if ([[[statusDic objectForKey:@"data"] objectForKey:@"userId"] integerValue] == [AccountManager shareAccountManager].account.userId) {
            retStr = @"买家取消订单";
        } else {
            retStr = @"卖家取消订单";
        }
        
    } else if ([status isEqualToString:@"pay"]) {
        retStr = @"买家支付订单";
        
    } else if ([status isEqualToString:@"commit"]) {
        retStr = @"卖家已经发货";
        
    } else if ([status isEqualToString:@"expire"]) {
        if ([[statusDic objectForKey:@"prevStatus"] isEqualToString:@"pending"]) {
            retStr = @"买家未支付,订单过期";
        } else if ([[statusDic objectForKey:@"prevStatus"] isEqualToString:@"paid"]) {
            retStr = @"卖家未确认订单，系统自动退款";
        }  else if ([[statusDic objectForKey:@"prevStatus"] isEqualToString:@"refundApplied"]) {
            retStr = @"超时未确认，系统自动退款";
        }
        
    } else if ([status isEqualToString:@"finish"]) {
        retStr = @"订单已完成";
        
    }  else if ([status isEqualToString:@"refundApply"]) {
        retStr = @"买家申请退款";
        
    } else if ([status isEqualToString:@"refundApprove"]) {
        retStr = @"卖家同意退款";
        
    } else if ([status isEqualToString:@"refundDeny"]) {
        retStr = @"卖家拒绝退款申请";
    } else if ([status isEqualToString:@"refundAuto"]) {
        retStr = @"系统自动退款";
    }
    return retStr;
}

- (void)setUnitPrice:(float)unitPrice
{
    _unitPrice = unitPrice;
    _totalPrice = _unitPrice * _count;
}

- (void)setCount:(NSInteger)count
{
    _count = count;
    _totalPrice = _unitPrice * _count;
}

- (NSString *)formatUnitPrice
{
    NSString *priceStr;
    float currentPrice = round(_unitPrice*100)/100;
    if (!(currentPrice - (int)currentPrice)) {
        priceStr = [NSString stringWithFormat:@"%d", (int)currentPrice];
    } else {
        NSString *tempPrice = [NSString stringWithFormat:@"%.1f", currentPrice];
        if (!(_unitPrice - tempPrice.floatValue)) {
            priceStr = [NSString stringWithFormat:@"%.1f", currentPrice];
        } else {
            priceStr = [NSString stringWithFormat:@"%.2f", currentPrice];
        }
    }
    return priceStr;

}

- (NSString *)formatTotalPrice
{
    NSString *priceStr;
    float currentPrice = round(_totalPrice*100)/100;
    if (!(currentPrice - (int)currentPrice)) {
        priceStr = [NSString stringWithFormat:@"%d", (int)currentPrice];
    } else {
        NSString *tempPrice = [NSString stringWithFormat:@"%.1f", currentPrice];
        if (!(_totalPrice - tempPrice.floatValue)) {
            priceStr = [NSString stringWithFormat:@"%.1f", currentPrice];
        } else {
            priceStr = [NSString stringWithFormat:@"%.2f", currentPrice];
        }
        
    }
    return priceStr;
}

- (NSString *)orderStatusDesc
{
    NSString *orderStatusDesc = @"";
    switch (_orderStatus) {
        case kOrderPaid:
            orderStatusDesc = @"待卖家确认";
            break;
            
        case kOrderCanceled:
            orderStatusDesc = @"已取消";
            break;
            
        case kOrderWaitPay:
            orderStatusDesc = @"待付款";
            break;
            
        case kOrderInUse:
            orderStatusDesc = @"可使用";
            break;
            
        case kOrderCompletion:
            orderStatusDesc = @"已完成";
            break;
            
        case kOrderRefunding:
            orderStatusDesc = @"退款申请中";
            break;
            
        case kOrderRefunded:
            orderStatusDesc = @"已退款";
            break;
            
        case kOrderExpired:
            orderStatusDesc = @"已过期";
            break;
            
        case kOrderToReview:
            orderStatusDesc = @"已完成";
            break;
            
        default:
            break;
    }
    return orderStatusDesc;
}

@end
