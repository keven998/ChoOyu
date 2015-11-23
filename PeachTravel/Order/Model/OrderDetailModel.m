//
//  OrderDetailModel.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/10/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "OrderDetailModel.h"

@implementation OrderDetailModel

- (void)setOrderStatus:(OrderStatus)orderStatus
{
    _orderStatus = orderStatus;
    switch (_orderStatus) {
        case kOrderInProgress:
            _orderStatusDesc = @"处理中";
            break;
            
        case kOrderCanceled:
            _orderStatusDesc = @"已取消";
            break;
            
        case kOrderWaitPay:
            _orderStatusDesc = @"待付款";
            break;
            
        case kOrderInUse:
            _orderStatusDesc = @"可使用";
            break;
            
        case kOrderCompletion:
            _orderStatusDesc = @"已完成";
            break;
            
        case kOrderRefunding:
            _orderStatusDesc = @"退款申请中";
            break;

        case kOrderRefunded:
            _orderStatusDesc = @"已退款";
            break;
            
        default:
            break;
    }
}

@end
