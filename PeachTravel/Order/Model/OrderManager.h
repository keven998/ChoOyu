//
//  OrderManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoodsPackageModel.h"
#import "OrderDetailModel.h"

@interface OrderManager : NSObject

/**
 *  检查订单所有的信息是否填写完整
 *
 *  @param order 需要检查的订单
 *
 *  @return 返回的错误信息
 */
+ (NSString *)checkOrderIsCompleteWhenMakeOrder:(OrderDetailModel *)order;

/**
 *  提交订单
 *
 *  @param goodsId    商品 ID
 *  @param travelers  旅客信息（包含旅客 ID 的数组）
 *  @param packageId  套餐 ID
 *  @param date       使用日期
 *  @param quantity   购买数量
 *  @param phone      联系人电话
 *  @param firstName  联系人名
 *  @param lastName   联系人姓
 *  @param message    留言
 *  @param completion 完成回调
 */
+ (void)asyncMakeOrderWithGoodsId:(NSInteger)goodsId
                        travelers:(NSArray<NSString *> *)travelers
                        packageId:(NSString *)packageId
                         playDate:(NSTimeInterval)date
                         quantity:(NSInteger)quantity
                     contactPhone:(NSInteger)phone
                 contactFirstName:(NSString *)firstName
                  contactLastName:(NSString *)lastName
                     leaveMessage:(NSString *)message
                  completionBlock:(void (^)(BOOL isSuccess, OrderDetailModel *orderDetail))completion;

/**
 *  取消订单
 *
 *  @param orerId     订单 ID
 *  @param completion 完成回调
 */
+ (void)asyncCancelOrderWithOrderId:(NSInteger)orderId completionBlock:(void (^) (BOOL isSuccess, NSString *error))completion;


/**
 *  获取订单详情
 *
 *  @param orderId    订单 ID
 *  @param completion 
 */
+ (void)asyncLoadOrderDetailWithOrderId:(NSInteger)orderId completionBlock:(void (^) (BOOL isSuccess, OrderDetailModel *orderDetail))completion;

/**
 *  更新订单的套餐
 *
 *  @param orderDetail
 *  @param selectPackage 
 */
+ (void)updateOrder:(OrderDetailModel *)orderDetail WithGoodsPackage:(GoodsPackageModel *)selectPackage;

/**
 *  更新订单数量
 *
 *  @param orderDetail
 *  @param count
 */
+ (void)updateOrder:(OrderDetailModel *)orderDetail WithBuyCount:(NSInteger)count;


/**
 *  加载我的全部订单列表
 * 
 *  @param userId 用户 ID
 *  @param completion
 */
+ (void)asyncLoadOrdersFromServerOfUser:(NSInteger)userId completionBlock:(void (^)(BOOL isSuccess, NSArray<OrderDetailModel *> * orderList))completion;

/**
 *  加载指定状态的订单列表 什么都不传加载全部订单列表
 *
 *  @param userId
 *  @param orderTypes
 *  @param startIndex
 *  @param count
 *  @param completion
 */
+ (void)asyncLoadOrdersFromServerOfUser:(NSInteger)userId orderType:(NSArray<NSString *> *)orderTypes startIndex:(NSInteger)startIndex count:(NSInteger)count completionBlock:(void (^)(BOOL isSuccess, NSArray<OrderDetailModel *> * orderList))completion;;

/**
 *  用指定的类型筛选订单列表
 *
 *  @param orderType 需要的订单类型
 *  @param orderList 待筛选的订单列表 如果为0则不进行筛选
 *
 *  @return 筛选完的订单列表
 */
+ (NSArray<OrderDetailModel *> *)filterOrderListWithOrderType:(OrderStatus)orderType andOrderList:(NSArray<OrderDetailModel *> *)orderList;

@end
