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
    if (!order.useDate) {
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
                         playDate:(NSString *)date
                         quantity:(NSInteger)quantity
                     contactModel:(OrderTravelerInfoModel *)contactInfo
                     leaveMessage:(NSString *)message
                  completionBlock:(void (^)(BOOL, OrderDetailModel *))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:[NSNumber numberWithInteger:goodsId] forKey:@"commodityId"];
    [params safeSetObject:packageId forKey:@"planId"];
    [params safeSetObject:date forKey:@"rendezvousTime"];  //传毫秒单位
    [params safeSetObject:travelers forKey:@"travellers"];
    [params safeSetObject:[NSNumber numberWithInteger:quantity] forKey:@"quantity"];
    
    NSMutableDictionary *contactDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *telDic = [[NSMutableDictionary alloc] init];
    [telDic safeSetObject:[NSNumber numberWithInteger:contactInfo.dialCode.integerValue] forKey:@"dialCode"];
    [telDic safeSetObject:[NSNumber numberWithInteger:contactInfo.telNumber.integerValue] forKey:@"number"];
    [contactDic setObject:telDic forKey:@"tel"];
    [contactDic safeSetObject:contactInfo.firstName forKey:@"givenName"];
    [contactDic safeSetObject:contactInfo.lastName forKey:@"surname"];
    [contactDic safeSetObject:@"" forKey:@"email"];
    [params setObject:contactDic forKey:@"contact"];
    
    [params safeSetObject:message forKey:@"comment"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking POST:API_ORDERS parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    NSString *url = [NSString stringWithFormat:@"%@/%ld/actions", API_ORDERS, orderId];
    NSDictionary *params = @{
                             @"action": @"cancel",
                             @"data": @{
                                     @"userId": [NSNumber numberWithInteger: [AccountManager shareAccountManager].account.userId]
                                     }
                             };
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking POST:url parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

+ (void)asyncRequestRefundMoneyWithOrderId:(NSInteger)orderId reason:(NSString *)reason leaveMessage:(NSString *)message completionBlock:(void (^) (BOOL isSuccess, NSString *error))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/actions", API_ORDERS, orderId];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:@"refundApply" forKey:@"action"];
    NSMutableDictionary *refundData = [[NSMutableDictionary alloc] init];
    [refundData safeSetObject:[NSNumber numberWithInteger:[AccountManager shareAccountManager].account.userId] forKey:@"userId"];
    [refundData safeSetObject:reason forKey:@"reason"];
    [refundData safeSetObject:message forKey:@"memo"];
    [params safeSetObject:refundData forKey:@"data"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking POST:url parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    NSString *url = [NSString stringWithFormat:@"%@/%ld", API_ORDERS, orderId];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking GET:url parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    NSString *url = [NSString stringWithFormat:@"%@", API_ORDERS];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInteger:userId] forKey:@"userId"];
    
    [LXPNetworking GET:url parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

+ (void)asyncLoadOrdersFromServerOfUser:(NSInteger)userId orderType:(NSArray<NSString *> *)orderTypes startIndex:(NSInteger)startIndex count:(NSInteger)count completionBlock:(void (^)(BOOL, NSArray<OrderDetailModel *> *))completion
{
    NSString *url = [NSString stringWithFormat:@"%@", API_ORDERS];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInteger:userId] forKey:@"userId"];
    [params setObject:[NSNumber numberWithInteger:startIndex] forKey:@"start"];
    [params setObject:[NSNumber numberWithInteger:count] forKey:@"count"];
    
    NSMutableString *types;
    if (orderTypes.count) {
        types = [[NSMutableString alloc] initWithString:[orderTypes firstObject]];
    }
    if (orderTypes.count > 1) {
        for (int i=1; i<orderTypes.count; i++) {
            [types appendString:[NSString stringWithFormat:@",%@", [orderTypes objectAtIndex:i]]];
        }
    }
    [params safeSetObject:types forKey:@"status"];
    
    [LXPNetworking GET:url parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
