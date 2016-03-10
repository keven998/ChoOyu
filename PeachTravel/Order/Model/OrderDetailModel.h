//
//  OrderDetailModel.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/10/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderTravelerInfoModel.h"
#import "GoodsDetailModel.h"
#import "UserCouponDetail.h"

typedef enum : NSUInteger {
    kOrderWaitPay = 1,      //待支付
    kOrderPaid,             //已付款,待卖家确认
    kOrderInUse,            //可使用
    kOrderCanceled,         //已取消
    kOrderRefunding,        //申请退款中
    kOrderRefunded,         //已退款
    kOrderToReview,         //待评价
    kOrderReviewed,         //已评价
    kOrderCompletion,       //已完成
    kOrderExpired,          //订单已过期
    
} OrderStatus;

@interface OrderDetailModel : NSObject

@property (nonatomic) NSInteger orderId;
@property (nonatomic, copy) NSString *orderName;

@property (nonatomic) float unitPrice;                                          //单价
@property (nonatomic, copy, readonly) NSString *formatUnitPrice;                //单价格式化描述
@property (nonatomic) float totalPrice;                                         //总价格
@property (nonatomic, copy, readonly) NSString *formatTotalPrice;               //总价格格式化描述
@property (nonatomic) float discount;                                           //优惠价格
@property (nonatomic, copy, readonly) NSString *formatDiscountPrice;            //优惠价格格式化描述
@property (nonatomic, readonly) float payPrice;                                 //应付价格
@property (nonatomic, copy, readonly) NSString *formatPayPrice;                 //应付价格格式化描述

@property (nonatomic, readonly) BOOL isRefundDenyBySeller;                      //卖家是不是已经拒绝了退款
@property (nonatomic) OrderStatus orderStatus;                                  //订单状态
@property (nonatomic, copy, readonly) NSString *orderStatusDesc;                //订单状态描述
@property (nonatomic, copy) NSString *useDate;                                  //使用时间
@property (nonatomic) NSTimeInterval expireTime;
@property (nonatomic) NSTimeInterval updateTime;
@property (nonatomic) NSTimeInterval createTime;
@property (nonatomic) NSTimeInterval currentTime;
@property (nonatomic, copy) NSString *leaveMessage;                             //留言
@property (nonatomic, strong) GoodsDetailModel *goods;                          //商品

@property (nonatomic, strong) GoodsPackageModel *selectedPackage;               //选中的套餐
@property (nonatomic) NSInteger count;                                          //订单数量
@property (nonatomic, strong) NSArray<OrderTravelerInfoModel *> *travelerList;  //旅客信息列表
@property (nonatomic, strong) OrderTravelerInfoModel *orderContact;             //订单的联系人

@property (nonatomic, strong) NSArray<NSDictionary *> *orderActivityList;       //订单状态变化

@property (nonatomic, strong) UserCouponDetail *selectedCoupon;                 //选中的优惠券

- (id)initWithJson:(id)json;

@end
