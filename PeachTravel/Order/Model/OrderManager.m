//
//  OrderManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "OrderManager.h"

@implementation OrderManager

+ (void)updateOrder:(OrderDetailModel *)orderDetail WithGoodsPackage:(GoodsPackageModel *)selectPackage
{
    orderDetail.selectedPackage = selectPackage;
    orderDetail.totalPrice = orderDetail.selectedPackage.currentPrice * orderDetail.count;
}

+ (void)updateOrder:(OrderDetailModel *)orderDetail WithBuyCount:(NSInteger)count
{
    orderDetail.count = count;
    orderDetail.totalPrice = orderDetail.selectedPackage.currentPrice * orderDetail.count;
}

+ (float)orderTotalPrice:(OrderDetailModel *)orderDetail
{
    return orderDetail.selectedPackage.currentPrice * orderDetail.count;
}
@end
