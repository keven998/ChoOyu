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
    if (!order.useDateStr) {
        return @"请选择出发日期";
    }
    if (![order.travelerList count]) {
        return @"请至少选择一个旅客";
    }
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

+ (void)asyncMakeOrderWithGoodsId:(NSInteger)goodsId
                        travelers:(NSArray<NSString *> *)travelers
                        packageId:(NSString *)packageId
                         playDate:(NSString *)date
                         quantity:(NSInteger)quantity
                     contactPhone:(NSString *)phone
                 contactFirstName:(NSString *)firstName
                  contactLastName:(NSString *)lastName
                     leaveMessage:(NSString *)message
                  completionBlock:(void (^)(BOOL, NSInteger))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:[NSNumber numberWithInteger:goodsId] forKey:@"commodityId"];
    [params safeSetObject:packageId forKey:@"planId"];
    [params safeSetObject:@"2015-11-28" forKey:@"rendezvousTime"];
    [params safeSetObject:travelers forKey:@"travellers"];
    [params safeSetObject:[NSNumber numberWithInteger:quantity] forKey:@"quantity"];
    [params safeSetObject:phone forKey:@"contactPhone"];
    [params safeSetObject:firstName forKey:@"contactGivenName"];
    [params safeSetObject:lastName forKey:@"contactSurname"];
    [params safeSetObject:message forKey:@"contactComment"];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager POST:API_ORDERS parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***提交订单接口: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            completion (YES, 0);
        } else {
            completion (NO, 0);

        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion (NO, 0);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    }];
}

+ (void)asyncLoadOrderDetailWithOrderId:(NSInteger)orderId completionBlock:(void (^)(BOOL, OrderDetailModel *))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *url = [NSString stringWithFormat:@"%@/%ld", API_ORDERS, orderId];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager GET:url parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***获取订单详情接口: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
        } else {
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    }];

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
