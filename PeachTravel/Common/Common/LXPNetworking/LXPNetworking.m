//
//  LXPNetworking.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/7/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "LXPNetworking.h"
#import "LXPHTTPAuthorization.h"

@implementation LXPNetworking

+ (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(id)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))tsuccess
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))tfailure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *rfc822Date = [ConvertMethods RFC822DateWithDate:[NSDate date]];
    [manager.requestSerializer setValue:rfc822Date forHTTPHeaderField:@"Date"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (accountManager.isLogin) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"X-Lvxingpai-Id"];
        
        NSURL *url = [NSURL URLWithString:URLString];
        NSString *signature = [LXPHTTPAuthorization signatureMessageWithURI:url.path Date:rfc822Date LxpId:accountManager.account.userId Query:parameters Body:nil];
        NSString *token = [LXPHTTPAuthorization authorizationSignatureWithToken:accountManager.account.secToken signatureMessage:signature];
        NSLog(@"%@", token);
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"LVXINGPAI-v1-HMAC-SHA256 Signature=%@", token] forHTTPHeaderField:@"Authorization"];

    }
    
    return [manager GET:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tsuccess(operation, responseObject);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        tfailure(operation, error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    return [manager DELETE:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tsuccess(operation, responseObject);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        tfailure(operation, error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    return [manager PATCH:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tsuccess(operation, responseObject);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        tfailure(operation, error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (accountManager.isLogin) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    
    return [manager PUT:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tsuccess(operation, responseObject);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        tfailure(operation, error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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

    NSString *rfc822Date = [ConvertMethods RFC822DateWithDate:[NSDate date]];
    [manager.requestSerializer setValue:rfc822Date forHTTPHeaderField:@"Date"];

    if (accountManager.isLogin) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
        
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"X-Lvxingpai-Id"];
        
        NSURL *url = [NSURL URLWithString:URLString];
        NSString *signature = [LXPHTTPAuthorization signatureMessageWithURI:url.path Date:rfc822Date LxpId:accountManager.account.userId Query:nil Body:parameters];
        NSString *token = [LXPHTTPAuthorization authorizationSignatureWithToken:accountManager.account.secToken signatureMessage:signature];
        NSLog(@"%@", token);
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"LVXINGPAI-v1-HMAC-SHA256 Signature=%@", token] forHTTPHeaderField:@"Authorization"];

    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    

    return [manager POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tsuccess(operation, responseObject);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        tfailure(operation, error);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    }];
}

@end
