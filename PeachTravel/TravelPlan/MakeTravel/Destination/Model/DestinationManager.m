//
//  DestinationManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/24/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "DestinationManager.h"


@implementation DestinationManager

static NSString *domesticDestinationCacheName = @"destination_demostic";
static NSString *foreignDestinationCacheName = @"destination_foreign";


+ (void)loadDomesticDestinationFromServer:(Destinations *)destinations lastModifiedTime:(NSString *)time completionBlock:(void (^)(BOOL isSuccess, Destinations *destination)) completetion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"Cache-Control" forHTTPHeaderField:@"private"];
    if (time) {
        [manager.requestSerializer setValue:time forHTTPHeaderField:@"If-Modified-Since"];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:450];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithBool:NO] forKey:@"abroad"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"groupBy"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager GET:API_GET_DOMESTIC_DESTINATIONS parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@",responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            id result = [responseObject objectForKey:@"result"];
            [destinations.domesticCities removeAllObjects];
            [destinations initDomesticCitiesWithJson:result];
            if ([operation.response.allHeaderFields objectForKey:@"Date"]) {
                [self saveDomesticDestinations2Cache:responseObject lastModifiedTime:[operation.response.allHeaderFields objectForKey:@"Date"]];
            }
            completetion(YES, destinations);
        } else {
            completetion(NO, destinations);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completetion(NO, destinations);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

+ (void)loadForeignDestinationFromServer:(Destinations *)destinations lastModifiedTime:(NSString *)time completionBlock:(void (^)(BOOL isSuccess, Destinations *destination)) completetion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"Cache-Control" forHTTPHeaderField:@"private"];
    if (time) {
        [manager.requestSerializer setValue:time forHTTPHeaderField:@"If-Modified-Since"];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:450];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"abroad"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"groupBy"];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
   
    [manager GET:API_GET_FOREIGN_DESTINATIONS parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            id result = [responseObject objectForKey:@"result"];
            [destinations initForeignCountriesWithJson:result];
            completetion(YES, destinations);
            if ([operation.response.allHeaderFields objectForKey:@"Date"]) {
                [self saveForeignDestinations2Cache:responseObject lastModifiedTime:[operation.response.allHeaderFields objectForKey:@"Date"]];
            }
            
        } else {
            completetion(NO, destinations);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completetion(NO, destinations);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];

}

+ (void)loadDomesticDestinationFromCache:(Destinations *)destinations completionBlock:(void (^)(BOOL isSuccess, Destinations *destination, NSString *saveTime)) completetion
{
    [[TMCache sharedCache] objectForKey:domesticDestinationCacheName block:^(TMCache *cache, NSString *key, id object)  {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (object != nil) {
                if ([object isKindOfClass:[NSDictionary class]]) {
                    [destinations initDomesticCitiesWithJson:[object objectForKey:@"result"]];
                    completetion(YES, destinations, [object objectForKey:@"lastModified"]);
                } else {
                    completetion(NO, destinations, nil);

                }
            } else {
                completetion(NO, destinations, nil);
                
            }
        });
    }];

}

+ (void)loadForeignDestinationFromCache:(Destinations *)destinations completionBlock:(void (^)(BOOL isSuccess, Destinations *destination, NSString *saveTime)) completetion
{
    
}

+ (void)saveDomesticDestinations2Cache:(NSDictionary *)destinationDic lastModifiedTime:(NSString *)time
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dic = [destinationDic mutableCopy];
        if (time) {
            [dic setObject:time  forKey:@"lastModified"];
        }
        [[TMCache sharedCache] setObject:dic forKey:domesticDestinationCacheName];

    });
}

+ (void)saveForeignDestinations2Cache:(NSDictionary *)destinationDic lastModifiedTime:(NSString *)time
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dic = [destinationDic mutableCopy];
        if (time) {
            [dic setObject:time  forKey:@"lastModified"];
        }
        [[TMCache sharedCache] setObject:dic forKey:foreignDestinationCacheName];
        
    });
}


@end
