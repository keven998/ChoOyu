//
//  OrderManager+BNOrderManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/10/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "OrderManager.h"

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

@end
