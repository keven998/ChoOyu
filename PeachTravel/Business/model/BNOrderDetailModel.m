//
//  BNOrderDetailModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/10/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNOrderDetailModel.h"

@implementation BNOrderDetailModel

- (id)initWithJson:(id)json
{
    if (self = [super initWithJson:json]) {
    }
    return self;
}

- (NSString *)BNOrderStatusDesc
{
    NSString *orderStatusDesc = @"";
    switch (self.orderStatus) {
        case kOrderPaid:
            orderStatusDesc = @"待发货";
            break;
            
        case kOrderCanceled:
            orderStatusDesc = @"已取消";
            break;
            
        case kOrderWaitPay:
            orderStatusDesc = @"等待买家付款";
            break;
            
        case kOrderInUse:
            orderStatusDesc = @"已发货";
            break;
            
        case kOrderCompletion:
            orderStatusDesc = @"已成功";
            break;
            
        case kOrderRefunding:
            orderStatusDesc = @"待退款";
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
            
        case kOrderReviewed:
            orderStatusDesc = @"已完成";
            break;
            
        default:
            break;
    }
    return orderStatusDesc;
}


@end
