//
//  GoodsManager+BNGoodsManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/8/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsManager+BNGoodsManager.h"

@implementation GoodsManager (BNGoodsManager)

+ (void)asyncLoadGoodsOfStore:(NSInteger)storeId goodsStatus:(BNGoodsStatus)status startIndex:(NSInteger)startIndex count:(NSUInteger)count completionBlock:(void (^)(BOOL, NSArray *))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:[NSNumber numberWithInteger:storeId] forKey:@"seller"];
    [params safeSetObject:@"updateTime" forKey:@"sort"];

    if (startIndex >= 0) {
        [params safeSetObject:[NSNumber numberWithInteger:startIndex] forKey:@"start"];
    }
    if (count > 0) {
        [params safeSetObject:[NSNumber numberWithInteger:count] forKey:@"count"];
    }
    if (status == kOffSale) {
        [params safeSetObject:@"disabled" forKey:@"status"];

    } else if (status == kOnSale) {
        [params safeSetObject:@"pub" forKey:@"status"];

    } else if (status == kReviewing) {
        [params safeSetObject:@"review" forKey:@"status"];
    }
    
    [LXPNetworking GET:API_GOODSLIST parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSMutableArray *retArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in [responseObject objectForKey:@"result"]) {
                BNGoodsDetailModel *goods = [[BNGoodsDetailModel alloc] initWithJson:dic];
                [retArray addObject:goods];
            }
            completion(YES, retArray);
            
        } else {
            completion(NO, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
        
    }];
}

+ (void)asyncDisableGoods:(NSInteger)goodsId completionBlock:(void (^)(BOOL, NSString *))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:@"disabled" forKey:@"status"];
    NSString *url = [NSString stringWithFormat:@"%@/%ld", API_GOODS, goodsId];
    
    [LXPNetworking POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            completion (YES, nil);
            
        } else {
            completion(NO, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
        
    }];

}

+ (void)asyncOnsaleGoods:(NSInteger)goodsId completionBlock:(void (^)(BOOL, NSString *))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:@"pub" forKey:@"status"];
    NSString *url = [NSString stringWithFormat:@"%@/%ld", API_GOODS, goodsId];
    
    [LXPNetworking POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            completion (YES, nil);
            
        } else {
            completion(NO, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
        
    }];
}

@end
