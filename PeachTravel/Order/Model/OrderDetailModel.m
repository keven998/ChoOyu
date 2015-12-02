//
//  OrderDetailModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/10/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "OrderDetailModel.h"

@implementation OrderDetailModel

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        if ([json objectForKey:@"contact"] != [NSNull null]) {
            _orderContact = [[OrderContactInfoModel alloc] initWithJson:[json objectForKey:@"contact"]];
        }
        _selectedPackage = [[GoodsPackageModel alloc] init];
        _selectedPackage.packageId = [json objectForKey:@"planId"];
        _goods = [[GoodsDetailModel alloc] initWithJson:[json objectForKey:@"commodity"]];
        _totalPrice = [[json objectForKey:@"totalPrice"] floatValue];
        _count = [[json objectForKey:@"quantity"] integerValue];
        _leaveMessage = [json objectForKey:@"comment"];
        _orderStatus = [self orderStatusWithStatusDescription:[json objectForKey:@"status"]];
        NSMutableArray *tempTravelerList = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in [json objectForKey:@"travellers"]) {
            OrderTravelerInfoModel *traveler = [[OrderTravelerInfoModel alloc] initWithJson:dic];
            [tempTravelerList addObject:traveler];
        }
        _travelerList = tempTravelerList;
    }
    return self;
}

- (NSString *)orderStatusDesc
{
    NSString *orderStatusDesc = @"";
    switch (_orderStatus) {
        case kOrderInProgress:
            orderStatusDesc = @"处理中";
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
            
        default:
            break;
    }
    return orderStatusDesc;
}

- (OrderStatus)orderStatusWithStatusDescription:(NSString *)statusStr
{
    if ([statusStr isEqualToString:@"pending"]) {
        return kOrderWaitPay;
        
    } else if ([statusStr isEqualToString:@"paid"]) {
        return kOrderInProgress;
        
    } else if ([statusStr isEqualToString:@"paid"]) {
        return kOrderInProgress;
        
    } else if ([statusStr isEqualToString:@"committed"]) {
        return kOrderInUse;
        
    } else if ([statusStr isEqualToString:@"finished"]) {
        return kOrderCompletion;
        
    } else if ([statusStr isEqualToString:@"canceled"]) {
        return kOrderCanceled;
        
    } else if ([statusStr isEqualToString:@"expired"]) {
        return kOrderExpired;
        
    } else if ([statusStr isEqualToString:@"refundApplied"]) {
        return kOrderRefunding;
        
    } else if ([statusStr isEqualToString:@"refunded"]) {
        return kOrderRefunded;
    }
    
    return 0;
}


@end
