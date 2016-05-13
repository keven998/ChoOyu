//
//  StoreManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/21/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "StoreManager.h"
#import "CityDestinationPoi.h"

@implementation StoreManager

+ (void)asyncLoadStoreInfoWithStoreId:(NSInteger)storeId completionBlock:(void (^)(BOOL, StoreDetailModel *))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/%ld", API_STORE, storeId];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking GET:url parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***开始加载店铺详情: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
    
        if (code == 0) {
            NSDictionary *goodsDic = [responseObject objectForKey:@"result"];
            if ([goodsDic isKindOfClass:[NSDictionary class]]) {
                StoreDetailModel *storeDetail = [[StoreDetailModel alloc] initWithJson:goodsDic];
                completion(YES, storeDetail);
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

+ (void)asyncLoadStoreServerCitiesWithStoreId:(NSInteger)storeId completionBlock:(void (^)(BOOL isSuccess, NSArray<CityDestinationPoi *> *cityList))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/%ld/subLocalities", API_STORE, storeId];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking GET:url parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        
        if (code == 0) {
            NSMutableArray *cities = [[NSMutableArray alloc] init];
            for (NSDictionary *json in [responseObject objectForKey:@"result"]) {
                CityDestinationPoi *poi = [[CityDestinationPoi alloc] initWithJson:json];
                [cities addObject:poi];
            }
            completion(YES, cities);
        } else {
            completion(NO, nil);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        completion(NO, nil);
        
    }];
}

+ (void)asyncUpdateSellerServerCities:(NSArray<CityDestinationPoi *> *)cities completionBlock:(void (^)(BOOL isSuccess))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/subLocalities", API_STORE];
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in cities) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic safeSetObject:poi.cityId forKey:@"id"];
        [dic safeSetObject:poi.zhName forKey:@"zhName"];
        [tempArray addObject:dic];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking POST:url parameters: @{@"localities": tempArray} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        
        if (code == 0) {
            completion(YES);
        } else {
            completion(NO);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        completion(NO);
    }];

}

+ (void)asyncLoadStoreListInCity:(NSString *)cityId completionBlock:(void (^) (BOOL isSuccess, NSArray<StoreDetailModel *>*storeList))completion
{
    NSString *url = [NSString stringWithFormat:@"%@%@/sellers", API_GET_CITYDETAIL, cityId];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking GET:url parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
    
        if (code == 0) {
            NSMutableArray *retList = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in [[responseObject objectForKey:@"result"] objectForKey:@"sellers"]) {
                [retList addObject:[[StoreDetailModel alloc] initWithJson:dic]];
            }
            completion(YES, retList);
        } else {
            completion(NO, nil);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        completion(NO, nil);
    }];
}

+ (void)asyncLoadStoreListInCounrty:(NSString *)countryId completionBlock:(void (^) (BOOL isSuccess, NSArray<StoreDetailModel *>*storeList))completion
{
    NSString *url = [NSString stringWithFormat:@"%@app/marketplace/geo/countries/%@/sellers", BASE_URL, countryId];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking GET:url parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        
        if (code == 0) {
            NSMutableArray *retList = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in [responseObject objectForKey:@"sellers"]) {
                [retList addObject:[[StoreDetailModel alloc] initWithJson:dic]];
            }
            completion(YES, retList);
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
