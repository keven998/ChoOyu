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
 *  获得订单总价
 *
 *  @param orderDetail
 *
 *  @return    
 */
+ (float)orderTotalPrice:(OrderDetailModel *)orderDetail;


@end
