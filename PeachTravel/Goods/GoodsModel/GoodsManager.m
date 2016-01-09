//
//  GoodsManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsManager.h"
#import "GoodsDetailModel.h"

@implementation GoodsManager

+ (void)asyncLoadGoodsDetailWithGoodsId:(NSInteger)goodsId completionBlock:(void (^)(BOOL, NSDictionary *, GoodsDetailModel *))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/%ld", API_GOODSLIST, goodsId];
    
    [LXPNetworking GET:url parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***开始加载商品详情: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSDictionary *goodsDic = [responseObject objectForKey:@"result"];
            if ([goodsDic isKindOfClass:[NSDictionary class]]) {
                GoodsDetailModel *goodsDetail = [[GoodsDetailModel alloc] initWithJson:goodsDic];
                completion(YES, goodsDic, goodsDetail);
            } else {
                completion(YES, nil, nil);
            }
        } else {
            completion(NO, nil, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil, nil);
        
    }];

}

+ (void)asyncLoadGoodsOfCity:(NSString *)cityId startIndex:(NSInteger)startIndex count:(NSUInteger)count completionBlock:(void (^)(BOOL isSuccess, NSArray *goodsList))completion
{
    [self asyncLoadGoodsOfCity:cityId category:nil sortBy:nil sortValue:nil startIndex:startIndex count:count completionBlock:completion];
}

+ (void)asyncLoadGoodsOfCity:(NSString *)cityId category:(NSString *)category completionBlock:(void (^)(BOOL, NSArray *))completion
{
    [self asyncLoadGoodsOfCity:cityId category:category sortBy:nil sortValue:nil startIndex:0 count:15 completionBlock:completion];
}

+ (void)asyncLoadGoodsOfCity:(NSString *)cityId category:(NSString *)category sortBy:(NSString *)sortType sort:(NSString *)sort completionBlock:(void (^)(BOOL, NSArray *))completion
{
    [self asyncLoadGoodsOfCity:cityId category:category sortBy:sortType sortValue:sort startIndex:0 count:15 completionBlock:completion];
}

+ (void)asyncLoadGoodsOfCity:(NSString *)cityId category:(NSString *)category sortBy:(NSString *)sortType sortValue:(NSString *)sortValue completionBlock:(void (^)(BOOL, NSArray *))completion
{
    [self asyncLoadGoodsOfCity:cityId category:category sortBy:sortType sortValue:sortType startIndex:0 count:15 completionBlock:completion];
}

+ (void)asyncLoadGoodsOfCity:(NSString *)cityId category:(NSString *)category sortBy:(NSString *)sortType sortValue:(NSString *)sortValue startIndex:(NSInteger)startIndex count:(NSUInteger)count completionBlock:(void (^)(BOOL, NSArray *))completion;
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:cityId forKey:@"locality"];
    [params safeSetObject:category forKey:@"category"];
    [params safeSetObject:sortType forKey:@"sortBy"];
    [params safeSetObject:sortValue forKey:@"sort"];
    if (startIndex >= 0) {
        [params safeSetObject:[NSNumber numberWithInteger:startIndex] forKey:@"start"];
    }
    if (count > 0) {
        [params safeSetObject:[NSNumber numberWithInteger:count] forKey:@"count"];
    }
    
    [LXPNetworking GET:API_GOODSLIST parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***开始加载城市的商品列表: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSMutableArray *retArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in [responseObject objectForKey:@"result"]) {
                GoodsDetailModel *goods = [[GoodsDetailModel alloc] initWithJson:dic];
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

+ (void)asyncLoadGoodsOfStore:(NSInteger)storeId startIndex:(NSInteger)startIndex count:(NSUInteger)count completionBlock:(void (^)(BOOL, NSArray *))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:[NSNumber numberWithInteger:storeId] forKey:@"seller"];
    if (startIndex >= 0) {
        [params safeSetObject:[NSNumber numberWithInteger:startIndex] forKey:@"start"];
    }
    if (count > 0) {
        [params safeSetObject:[NSNumber numberWithInteger:count] forKey:@"count"];
    }
    
    [LXPNetworking GET:API_GOODSLIST parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***开始加载城市的商品列表: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSMutableArray *retArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in [responseObject objectForKey:@"result"]) {
                GoodsDetailModel *goods = [[GoodsDetailModel alloc] initWithJson:dic];
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

+ (void)asyncLoadRecommendGoodsWithCompletionBlock:(void (^)(BOOL isSuccess, NSArray<NSDictionary *> *goodsList))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/recommendations", API_GOODS];
    [LXPNetworking GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSMutableArray *retArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in [responseObject objectForKey:@"result"]) {
                NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
                [retDic setObject:[dic objectForKey:@"topicType"] forKey:@"title"];
                NSMutableArray *goodsList = [[NSMutableArray alloc] init];
                for (id goodsDic in [dic objectForKey:@"commodities"]) {
                    if ([goodsDic isKindOfClass:[NSDictionary class]]) {
                        GoodsDetailModel *goods = [[GoodsDetailModel alloc] initWithJson:goodsDic];
                        [goodsList addObject:goods];
                    }
                }
                [retDic setObject:goodsList forKey:@"goodsList"];
                [retArray addObject:retDic];
            }
            completion(YES, retArray);
            
        } else {
            completion(NO, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
        
    }];
}

+ (void)asyncFavoriteGoodsWithGoodsId:(NSString *)goodsId isFavorite:(BOOL)isFavorite completionBlock:(void (^)(BOOL))completion
{
    completion(YES);
}

+ (void)asyncLoadGoodsCategoryOfLocality:(NSString *)localityId completionBlock:(void (^)(BOOL, NSArray<NSString *> *))completion
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:localityId forKey:@"locality"];
    
    [LXPNetworking GET:API_GOODS_CATEGORY parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSArray *retArray = [[responseObject objectForKey:@"result"] objectForKey:@"category"];
            completion(YES, retArray);
            
        } else {
            completion(NO, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(NO, nil);
        
    }];
}


@end
