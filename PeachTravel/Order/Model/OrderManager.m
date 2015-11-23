//
//  OrderManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "OrderManager.h"

@implementation OrderManager

+ (NSString *)checkOrderIsCompleteWhenMakeOrder:(OrderDetailModel *)order
{
    if (!order.orderContact.lastName || [order.orderContact.lastName isBlankString]) {
        return @"请填写联系人的姓";
    }
    if (!order.orderContact.firstName || [order.orderContact.firstName isBlankString]) {
        return @"请填写联系人的名";
    }
    if (!order.orderContact.tel || [order.orderContact.tel isBlankString]) {
        return @"请填写联系人的电话";
    }
    return nil;
}

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

+ (void)asyncLoadMyOrderFromServerWithOrderType:(OrderStatus)orderType completionBlock:(void (^)(BOOL, NSArray<OrderDetailModel *> *))completion
{
    //TODO: 完成从服务器上加载

    NSMutableArray *orderList = [[NSMutableArray alloc] init];
    for (int i = 0; i<5; i++) {
        OrderDetailModel *orderDetailModel = [[OrderDetailModel alloc] init];
        if (orderType == 0) {
            orderDetailModel.orderStatus = i+1;
        } else {
            orderDetailModel.orderStatus = orderType;
        }
        orderDetailModel.orderName = @"军都山滑雪全天";
        GoodsDetailModel *goods = [[GoodsDetailModel alloc] init];
        goods.goodsName = @"军都山滑雪全天";
        goods.image = [[TaoziImage alloc] init];
        goods.image.imageUrl = @"http://images.taozilvxing.com/c8915e680131f7e94358c52d50de9b70?imageView2/2/w/1200";
        orderDetailModel.useDateStr = @"2015-12-25";
        orderDetailModel.totalPrice = 245;
        orderDetailModel.goods = goods;
        GoodsPackageModel *package = [[GoodsPackageModel alloc] init];
        package.packageName = @"单人全天滑雪套餐";
        orderDetailModel.selectedPackage = package;
        orderDetailModel.count = 4;
        [orderList addObject:orderDetailModel];
    }
    completion(YES, orderList);
    
}

@end
