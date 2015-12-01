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
        _orderContact = [[OrderContactInfoModel alloc] initWithJson:[json objectForKey:@"contact"]];
        _selectedPackage = [[GoodsPackageModel alloc] init];
        _selectedPackage.packageId = [json objectForKey:@"planId"];
        _goods = [[GoodsDetailModel alloc] initWithJson:[json objectForKey:@"commodity"]];
        _totalPrice = [[json objectForKey:@"totalPrice"] floatValue];
        _count = [[json objectForKey:@"quantity"] integerValue];
        _leaveMessage = [json objectForKey:@"comment"];
    }
    return self;
}

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
