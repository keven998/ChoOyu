//
//  BNOrderDetailModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/10/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "OrderDetailModel.h"

@interface BNOrderDetailModel : OrderDetailModel

//商家版本的订单状态描述
@property (nonatomic, copy, readonly) NSString *BNOrderStatusDesc;

@property (nonatomic) BOOL hasDeliverGoods;                                 //是否已经发货

@property (nonatomic) NSTimeInterval refundLastTimeInterval;                //同意退款的截至日期

@property (nonatomic, copy, readonly) NSString *requestRefundtDate;         //申请退款时间
@property (nonatomic, copy, readonly) NSString *requestRefundtExcuse;       //申请退款原因
@property (nonatomic, copy, readonly) NSString *requestRefundtMessage;      //申请退款留言

@end
