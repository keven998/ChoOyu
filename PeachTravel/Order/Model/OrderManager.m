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
    if (!order.orderContact.telNumber || [order.orderContact.telNumber isBlankString]) {
        return @"请填写联系人的电话";
    }
    return nil;
}

+ (void)asyncMakeOrderWithGoodsId:(NSInteger)goodsId
                        travelers:(NSArray<NSString *> *)travelers
                        packageId:(NSString *)packageId
                         playDate:(NSTimeInterval)date
                         quantity:(NSInteger)quantity
                     contactPhone:(NSInteger)phone
                 contactFirstName:(NSString *)firstName
                  contactLastName:(NSString *)lastName
                     leaveMessage:(NSString *)message
                  completionBlock:(void (^)(BOOL, OrderDetailModel *))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }

    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:[NSNumber numberWithInteger:goodsId] forKey:@"commodityId"];
    [params safeSetObject:packageId forKey:@"planId"];
    [params safeSetObject:[NSNumber numberWithInteger:(NSInteger)(date*1000)] forKey:@"rendezvousTime"];  //传毫秒单位
    [params safeSetObject:travelers forKey:@"travellers"];
    [params safeSetObject:[NSNumber numberWithInteger:quantity] forKey:@"quantity"];
    NSMutableDictionary *telDic = [[NSMutableDictionary alloc] init];
    [telDic safeSetObject:[NSNumber numberWithInt:86] forKey:@"dialCode"];
    [telDic safeSetObject:[NSNumber numberWithInteger:phone] forKey:@"number"];
    [params setObject:telDic forKey:@"contactPhone"];
    [params safeSetObject:firstName forKey:@"contactGivenName"];
    [params safeSetObject:lastName forKey:@"contactSurname"];
    [params safeSetObject:message forKey:@"comment"];
    [params safeSetObject:@"" forKey:@"contactEmail"];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager POST:API_ORDERS parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***提交订单接口: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            OrderDetailModel *orderDetail = [[OrderDetailModel alloc] initWithJson:[responseObject objectForKey:@"result"]];
            completion (YES, orderDetail);
        } else {
            completion (NO, nil);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion (NO, nil);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    }];
}

+ (void)asyncCancelOrderWithOrderId:(NSInteger)orderId completionBlock:(void (^)(BOOL, NSString *))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *url = [NSString stringWithFormat:@"%@/%ld/actions", API_ORDERS, orderId];
    NSDictionary *params = @{
                             @"action": @"cancel"
                             };
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager POST:url parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***取消订单接口: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            completion(YES, nil);
        } else {
            completion(NO, nil);
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        completion(NO, nil);
        
    }];
}

+ (void)asyncRequestRefundMoneyWithOrderId:(NSInteger)orderId completionBlock:(void (^)(BOOL, NSString *))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    AppUtils *utils = [[AppUtils alloc] init];
    
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *url = [NSString stringWithFormat:@"%@/%ld/actions", API_ORDERS, orderId];
    NSDictionary *params = @{
                             @"action": @"refund"
                             };
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager POST:url parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***对订单提出退款申请接口: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            completion(YES, nil);
        } else {
            completion(NO, nil);
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        completion(NO, nil);
        
    }];
}

+ (void)asyncLoadOrderDetailWithOrderId:(NSInteger)orderId completionBlock:(void (^)(BOOL, OrderDetailModel *))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    NSString *url = [NSString stringWithFormat:@"%@/%ld", API_ORDERS, orderId];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager GET:url parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***获取订单详情接口: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if ([[responseObject objectForKey:@"result"] isKindOfClass:[NSDictionary class]]) {
                OrderDetailModel *orderDetail = [[OrderDetailModel alloc] initWithJson:[responseObject objectForKey:@"result"]];
                completion(YES, orderDetail);
            } else {
                completion(NO, nil);
            }
        } else {
            completion(NO, nil);

        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        completion(NO, nil);
        
    }];
}

+ (void)updateOrder:(OrderDetailModel *)orderDetail WithGoodsPackage:(GoodsPackageModel *)selectPackage
{
    orderDetail.selectedPackage = selectPackage;
}

+ (void)updateOrder:(OrderDetailModel *)orderDetail WithBuyCount:(NSInteger)count
{
    orderDetail.count = count;
}

+ (void)asyncLoadOrdersFromServerOfUser:(NSInteger)userId completionBlock:(void (^)(BOOL isSuccess, NSArray<OrderDetailModel *> * orderList))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    NSString *url = [NSString stringWithFormat:@"%@", API_ORDERS];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInteger:userId] forKey:@"userId"];
    
    [manager GET:url parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***获取订单列表接口: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if ([[responseObject objectForKey:@"result"] isKindOfClass:[NSArray class]]) {
                NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                for (NSDictionary *dic in [responseObject objectForKey:@"result"]) {
                    OrderDetailModel *orderDetail = [[OrderDetailModel alloc] initWithJson:dic];
                    [tempArray addObject:orderDetail];
                }
                completion(YES, tempArray);
            } else {
                completion(NO, nil);
            }
        } else {
            completion(NO, nil);
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        completion(NO, nil);
        
    }];
}

+ (void)asyncLoadOrdersFromServerOfUser:(NSInteger)userId orderType:(NSArray<NSNumber *> *)orderTypes startIndex:(NSInteger)startIndex count:(NSInteger)count completionBlock:(void (^)(BOOL, NSArray<OrderDetailModel *> *))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    NSString *url = [NSString stringWithFormat:@"%@", API_ORDERS];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInteger:userId] forKey:@"userId"];
    [params setObject:[NSNumber numberWithInteger:startIndex] forKey:@"start"];
    [params setObject:[NSNumber numberWithInteger:count] forKey:@"count"];
    [params safeSetObject:[orderTypes firstObject] forKey:@"status"];
    
    [manager GET:url parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***获取订单列表接口: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if ([[responseObject objectForKey:@"result"] isKindOfClass:[NSArray class]]) {
                NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                for (NSDictionary *dic in [responseObject objectForKey:@"result"]) {
                    OrderDetailModel *orderDetail = [[OrderDetailModel alloc] initWithJson:dic];
                    [tempArray addObject:orderDetail];
                }
                completion(YES, tempArray);
            } else {
                completion(NO, nil);
            }
        } else {
            completion(NO, nil);
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        completion(NO, nil);
        
    }];

}

+ (NSArray<OrderDetailModel *> *)filterOrderListWithOrderType:(OrderStatus)orderType andOrderList:(NSArray<OrderDetailModel *> *)orderList
{
    if (orderType == 0) {    //如果传的类型为0 则不进行筛选
        return orderList;
    }
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (OrderDetailModel *order in orderList) {
        if (orderType == order.orderStatus) {
            [retArray addObject:order];
        }
    }
    return retArray;
}

+ (OrderStatus)orderStatusWithServerOrderStatus:(NSString *)statusStr
{
    if ([statusStr isEqualToString:@"pending"]) {
        return kOrderWaitPay;
        
    } else if ([statusStr isEqualToString:@"paid"]) {
        return kOrderPaid;
        
    } else if ([statusStr isEqualToString:@"paid"]) {
        return kOrderPaid;
        
    } else if ([statusStr isEqualToString:@"committed"]) {
        return kOrderInUse;
        
    } else if ([statusStr isEqualToString:@"finished"]) {
        return kOrderCompletion;
        
    } else if ([statusStr isEqualToString:@"canceled"]) {
        return kOrderCanceled;
        
    } else if ([statusStr isEqualToString:@"expired"]) {
        return kOrderExpired;
        
    } else if ([statusStr isEqualToString:@"refundApplied"]) {
        return kOrderRefunding;
        
    } else if ([statusStr isEqualToString:@"refunded"]) {
        return kOrderRefunded;
    }
    
    return 0;
}

+ (NSString *)orderServerStatusWithLocalStatus:(OrderStatus)orderStatus
{
    NSString *retStatus;
    switch (orderStatus) {
        case kOrderWaitPay:
            retStatus = @"pending";
            break;
            
        case kOrderPaid:
            retStatus = @"paid";
            break;
            
        case kOrderInUse:
            retStatus = @"committed";
            break;
            
        case kOrderCompletion:
            retStatus = @"finished";
            break;
            
        case kOrderRefunded:
            retStatus = @"refunded";
            break;
            
        case kOrderCanceled:
            retStatus = @"canceled";
            break;
            
        case kOrderExpired:
            retStatus = @"expired";
            break;
            
        case kOrderRefunding:
            retStatus = @"refundApplied";
            break;
            
        default:
            break;
    }
    return retStatus;
}



@end
