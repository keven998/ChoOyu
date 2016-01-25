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
    [self setOtherHeaderValue:manager andUrl:URLString parameters:parameters];
    return [manager GET:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tsuccess(operation, responseObject);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        tfailure(operation, error);
        [self handleHttpError:error andOperation:operation];
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
    
    [self setOtherHeaderValue:manager andUrl:URLString parameters:parameters];
    
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
    
    [self setHeaderValueForPXMethods:manager andUrl:URLString parameters:parameters];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    return [manager PATCH:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tsuccess(operation, responseObject);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        tfailure(operation, error);
        [self handleHttpError:error andOperation:operation];
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
    
    [self setHeaderValueForPXMethods:manager andUrl:URLString parameters:parameters];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    return [manager PUT:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tsuccess(operation, responseObject);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        tfailure(operation, error);
        [self handleHttpError:error andOperation:operation];
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
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self setHeaderValueForPXMethods:manager andUrl:URLString parameters:parameters];

    return [manager POST:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        tsuccess(operation, responseObject);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        tfailure(operation, error);
        [self handleHttpError:error andOperation:operation];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    }];
}

//POST PUT PATCH
+ (void)setHeaderValueForPXMethods:(AFHTTPRequestOperationManager *)manager andUrl:(NSString *)URLString parameters:parameters
{
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"LXPBetaTest"] isEqualToString:@"Dev"]) {
        [manager.requestSerializer setValue:@"Dev" forHTTPHeaderField:@"X-Lvxingpai-API-Control"];
        
    } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"LXPBetaTest"] isEqualToString:@"Beta"]) {
        [manager.requestSerializer setValue:@"Beta" forHTTPHeaderField:@"X-Lvxingpai-API-Control"];
        
    }
    
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
        if (accountManager.account.secToken) {
            NSString *token = [LXPHTTPAuthorization authorizationSignatureWithToken:accountManager.account.secToken signatureMessage:signature];
            NSLog(@"%@", token);
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"LVXINGPAI-v1-HMAC-SHA256 Signature=%@", token] forHTTPHeaderField:@"Authorization"];

        }
    }
}

//GET DELETE
+ (void)setOtherHeaderValue:(AFHTTPRequestOperationManager *)manager andUrl:(NSString *)URLString parameters:parameters
{
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    
    NSString *rfc822Date = [ConvertMethods RFC822DateWithDate:[NSDate date]];
    [manager.requestSerializer setValue:rfc822Date forHTTPHeaderField:@"Date"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"LXPBetaTest"] isEqualToString:@"Dev"]) {
        [manager.requestSerializer setValue:@"Dev" forHTTPHeaderField:@"X-Lvxingpai-API-Control"];
        
    } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"LXPBetaTest"] isEqualToString:@"Beta"]) {
        [manager.requestSerializer setValue:@"Beta" forHTTPHeaderField:@"X-Lvxingpai-API-Control"];
        
    }
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (accountManager.isLogin) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"X-Lvxingpai-Id"];
        
        NSURL *url = [NSURL URLWithString:URLString];
        NSString *signature = [LXPHTTPAuthorization signatureMessageWithURI:url.path Date:rfc822Date LxpId:accountManager.account.userId Query:parameters Body:nil];
        if (accountManager.account.secToken) {
            NSString *token = [LXPHTTPAuthorization authorizationSignatureWithToken:accountManager.account.secToken signatureMessage:signature];
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"LVXINGPAI-v1-HMAC-SHA256 Signature=%@", token] forHTTPHeaderField:@"Authorization"];
            NSLog(@"%@", token);
        }
    }
}

//处理 http 错误信息
+ (void)handleHttpError:(NSError *)error andOperation:(AFHTTPRequestOperation *)operation
{
    NSInteger errorCode = operation.response.statusCode;
    if (errorCode == 401 && [[AccountManager shareAccountManager] isLogin]) {     //用户鉴权失败，提示用户退出登录
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"帐号验证失败，请重新登录" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
            [[AccountManager shareAccountManager] asyncLogout:^(BOOL isSuccess) {
                
                
            }];
        }];
    }
}


@end
