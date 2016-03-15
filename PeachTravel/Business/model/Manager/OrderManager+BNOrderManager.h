//
//  OrderManager+BNOrderManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/10/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "OrderManager.h"
#import "BNOrderDetailModel.h"

@interface OrderManager (BNOrderManager)

/**
 *  加载商家指定状态的订单列表 什么都不传加载全部订单列表
 *
 *  @param storeId
 *  @param orderTypes
 *  @param startIndex
 *  @param count
 *  @param completion
 */
+ (void)asyncLoadOrdersFromServerOfStore:(NSInteger)storeId orderType:(NSArray<NSString *> *)orderTypes startIndex:(NSInteger)startIndex count:(NSInteger)count completionBlock:(void (^)(BOOL isSuccess, NSArray<OrderDetailModel *> * orderList))completion;

/**
 *  加载商家版本的订单详情
 *
 *  @param orderId    订单 ID
 *  @param completion 
 */
+ (void)asyncLoadBNOrderDetailWithOrderId:(NSInteger)orderId completionBlock:(void (^)(BOOL isSuccess, BNOrderDetailModel *orderDetail))completion;

/**
 *  卖家发货
 *
 *  @param orderId
 *  @param completion
 */
+ (void)asyncBNDeliverOrderWithOrderId:(NSInteger)orderId ccompletionBlock:(void (^)(BOOL isSuccess, NSString *errorStr))completion;

/**
 *  卖家取消订单
 *
 *  @param orderId
 *  @param reason
 *  @param message
 *  @param completion
 */
+ (void)asyncBNCancelOrderWithOrderId:(NSInteger)orderId reason:(NSString *)reason leaveMessage:(NSString *)message completionBlock:(void (^)(BOOL isSuccess, NSString *errorStr))completion;

/**
 *  卖家同意退款
 *
 *  @param orderId
 *  @param completion
 */
+ (void)asyncBNAgreeRefundMoneyOrderWithOrderId:(NSInteger)orderId refundMoney:(float)money leaveMessage:(NSString *)message  completionBlock:(void (^)(BOOL isSuccess, NSString *errorStr))completion;

/**
 *  卖家拒绝退款
 *
 *  @param orderId
 *  @param message
 *  @param completion
 *  @param completion
 */
+ (void)asyncBNRefuseRefundMoneyOrderWithOrderId:(NSInteger)orderId reason:(NSString *)reason leaveMessage:(NSString *)message completionBlock:(void (^)(BOOL isSuccess, NSString *errorStr))completion;


/**
 *  验证卖家的密码
 *
 *  @param password
 *  @param completion
 */
+ (void)asyncVerifySellerPassword:(NSString *)password completionBlock:(void (^)(BOOL isSuccess, NSString *errorStr))completion;

@end
