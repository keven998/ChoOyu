//
//  OrderManager+BNOrderManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/10/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "OrderManager+BNOrderManager.h"

@implementation OrderManager (BNOrderManager)

+ (void)asyncLoadOrdersFromServerOfStore:(NSInteger)storeId orderType:(NSArray<NSString *> *)orderTypes startIndex:(NSInteger)startIndex count:(NSInteger)count completionBlock:(void (^)(BOOL, NSArray<OrderDetailModel *> *))completion
{
    NSString *url = [NSString stringWithFormat:@"%@", API_ORDERS];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInteger:storeId] forKey:@"sellerId"];
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
                    BNOrderDetailModel *orderDetail = [[BNOrderDetailModel alloc] initWithJson:dic];
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

+ (void)asyncLoadBNOrderDetailWithOrderId:(NSInteger)orderId completionBlock:(void (^)(BOOL, BNOrderDetailModel *))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/%ld", API_ORDERS, orderId];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking GET:url parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if ([[responseObject objectForKey:@"result"] isKindOfClass:[NSDictionary class]]) {
                BNOrderDetailModel *orderDetail = [[BNOrderDetailModel alloc] initWithJson:[responseObject objectForKey:@"result"]];
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

+ (void)asyncBNDeliverOrderWithOrderId:(NSInteger)orderId completionBlock:(void (^)(BOOL, NSString *))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/actions", API_ORDERS, orderId];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    [dataDic safeSetObject:[NSNumber numberWithInteger: [AccountManager shareAccountManager].account.userId] forKey:@"userId"];
    
    NSDictionary *params = @{
                             @"action": @"commit",
                             @"data": dataDic
                             };
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking POST:url parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***卖家发货接口: %@", operation);
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

+ (void)asyncBNCancelOrderWithOrderId:(NSInteger)orderId reason:(NSString *)reason leaveMessage:(NSString *)message completionBlock:(void (^)(BOOL, NSString *))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/actions", API_ORDERS, orderId];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    [dataDic safeSetObject:[NSNumber numberWithInteger: [AccountManager shareAccountManager].account.userId] forKey:@"userId"];
    [dataDic safeSetObject:reason forKey:@"reason"];
    [dataDic safeSetObject:message forKey:@"memo"];

    NSDictionary *params = @{
                             @"action": @"cancel",
                             @"data": dataDic
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

+ (void)asyncBNAgreeRefundMoneyOrderWithOrderId:(NSInteger)orderId refundMoney:(float)money leaveMessage:(NSString *)message  completionBlock:(void (^)(BOOL, NSString *))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/actions", API_ORDERS, orderId];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    [dataDic safeSetObject:[NSNumber numberWithInteger: [AccountManager shareAccountManager].account.userId] forKey:@"userId"];
    [dataDic safeSetObject:message forKey:@"memo"];
    if (money > 0) {
        [dataDic setObject:[NSNumber numberWithFloat:money] forKey:@"amount"];
    }
    NSDictionary *params = @{
                             @"action": @"refundApprove",
                             @"data": dataDic
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

+ (void)asyncBNRefuseRefundMoneyOrderWithOrderId:(NSInteger)orderId reason:(NSString *)reason leaveMessage:(NSString *)message completionBlock:(void (^)(BOOL isSuccess, NSString *errorStr))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/actions", API_ORDERS, orderId];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
    [dataDic safeSetObject:[NSNumber numberWithInteger: [AccountManager shareAccountManager].account.userId] forKey:@"userId"];
    [dataDic safeSetObject:@"reason" forKey:@"reason"];
    [dataDic safeSetObject:message forKey:@"memo"];
    
    NSDictionary *params = @{
                             @"action": @"refundDeny",
                             @"data": dataDic
                             };
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking POST:url parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***卖家拒绝退款接口: %@", operation);
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

+ (void)asyncVerifySellerPassword:(NSString *)password completionBlock:(void (^)(BOOL isSuccess, NSString *errorStr))completion
{
    completion(YES, nil);

}
@end
