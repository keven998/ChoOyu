//
//  LXPNetworking.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/7/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "LXPNetworking.h"

@implementation LXPNetworking

+ (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(id)parameters
                        tsuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))tsuccess
                        tfailure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))tfailure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (accountManager.isLogin) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    
    return [manager GET:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tsuccess(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        tsuccess(operation, error);
    }];

    
}


+ (nullable AFHTTPRequestOperation *)DELETE:(NSString *)URLString
                                 parameters:(nullable id)parameters
                                    success:(nullable void (^)(AFHTTPRequestOperation *operation, id responseObject))tsuccess
                                    failure:(nullable void (^)(AFHTTPRequestOperation *operation, NSError *error))tfailure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];

    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (accountManager.isLogin) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    
    return [manager PATCH:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tsuccess(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        tsuccess(operation, error);
    }];
}

+ (nullable AFHTTPRequestOperation *)PATCH:(NSString *)URLString
                                parameters:(nullable id)parameters
                                   success:(nullable void (^)(AFHTTPRequestOperation *operation, id responseObject))tsuccess
                                   failure:(nullable void (^)(AFHTTPRequestOperation *operation, NSError *error))tfailure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (accountManager.isLogin) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    
    return [manager PATCH:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tsuccess(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        tsuccess(operation, error);
    }];
}


+ (nullable AFHTTPRequestOperation *)PUT:(NSString *)URLString
                              parameters:(nullable id)parameters
                                 success:(nullable void (^)(AFHTTPRequestOperation *operation, id responseObject))tsuccess
                                 failure:(nullable void (^)(AFHTTPRequestOperation *operation, NSError *error))tfailure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (accountManager.isLogin) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    
    return [manager PUT:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tsuccess(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        tsuccess(operation, error);
    }];
    
}


+ (nullable AFHTTPRequestOperation *)POST:(NSString *)URLString
                               parameters:(nullable id)parameters
                                  success:(nullable void (^)(AFHTTPRequestOperation *operation, id responseObject))tsuccess
                                  failure:(nullable void (^)(AFHTTPRequestOperation *operation, NSError *error))tfailure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (accountManager.isLogin) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    
    return [manager POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tsuccess(operation, responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        tsuccess(operation, error);
    }];
}

@end
