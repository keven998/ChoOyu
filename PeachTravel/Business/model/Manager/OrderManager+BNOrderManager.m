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

@end
