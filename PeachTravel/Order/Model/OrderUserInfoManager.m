//
//  OrderUserInfoManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.

// ****  订单的用户信息管理  ****

#import "OrderUserInfoManager.h"

@implementation OrderUserInfoManager

+ (NSString *)checkTravelerInfoIsComplete:(OrderTravelerInfoModel *)traveler
{
    if (!traveler.lastName || [traveler.lastName isBlankString]) {
        return @"请填写旅客的姓";
        
    } else if (!traveler.firstName || [traveler.firstName isBlankString]) {
        return @"请填写旅客的名";
        
    } else if (!traveler.tel || [traveler.tel isBlankString]) {
        return @"请填写旅客的电话";
        
    } else if (!traveler.IDNumber || [traveler.IDNumber isBlankString]) {
        return @"请填写旅客的证件号码";
    }
    return nil;
}

+ (void)asyncLoadTravelersFromServerOfUser:(NSInteger)userId completionBlock:(void (^)(BOOL, NSArray<OrderTravelerInfoModel *> *))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *url = [NSString stringWithFormat:@"%@%ld/travellers", API_USERS, [AccountManager shareAccountManager].account.userId];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager GET:url parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***正在添加新的旅客: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if ([[responseObject objectForKey:@"result"] isKindOfClass:[NSArray class]]) {
                NSMutableArray *retArray = [[NSMutableArray alloc] init];
                for (NSDictionary *dic in [responseObject objectForKey:@"result"]) {
                    OrderTravelerInfoModel *traveler = [[OrderTravelerInfoModel alloc] initWithJson: [dic objectForKey:@"traveller"]];
                    traveler.uid = [dic objectForKey:@"key"];
                    [retArray addObject:traveler];
                }
                completion(YES, retArray);
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

+ (void)asyncAddTraveler:(OrderTravelerInfoModel *)traveler completionBlock:(void (^)(BOOL, OrderTravelerInfoModel *))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *url = [NSString stringWithFormat:@"%@%ld/travellers", API_USERS, [AccountManager shareAccountManager].account.userId];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInteger:[AccountManager shareAccountManager].account.userId] forKey:@"userId"];
    [params safeSetObject:traveler.firstName forKey:@"givenName"];
    [params safeSetObject:traveler.lastName forKey:@"surname"];
    NSMutableDictionary *IDDic = [[NSMutableDictionary alloc] init];
    [IDDic safeSetObject:traveler.IDCategory forKey:@"idType"];
    [IDDic safeSetObject:traveler.IDNumber forKey:@"number"];
    [params setObject:IDDic forKey:@"idProof"];
    [params setObject:@"0" forKey:@"birthday"];
    [params setObject:@"male" forKey:@"gender"];
    [params setObject:@"" forKey:@"email"];
    NSMutableDictionary *tel = [[NSMutableDictionary alloc] init];
    [tel setObject:@"86" forKey:@"dialCode"];
    [tel setObject:traveler.tel forKey:@"number"];
    [params safeSetObject:tel forKey:@"tel"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager POST:url parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***正在添加新的旅客: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if ([[responseObject objectForKey:@"result"] isKindOfClass:[NSDictionary class]]) {
                OrderTravelerInfoModel *traveler = [[OrderTravelerInfoModel alloc] initWithJson:[responseObject objectForKey:@"result"]];
                completion(YES, traveler);
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

+ (void)asyncEditTraveler:(OrderTravelerInfoModel *)traveler completionBlock:(void (^)(BOOL, OrderTravelerInfoModel *))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *url = [NSString stringWithFormat:@"%@%ld/travellers/%@", API_USERS, [AccountManager shareAccountManager].account.userId, traveler.uid];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInteger:[AccountManager shareAccountManager].account.userId] forKey:@"userId"];
    [params safeSetObject:traveler.firstName forKey:@"givenName"];
    [params safeSetObject:traveler.lastName forKey:@"surname"];
    NSMutableDictionary *IDDic = [[NSMutableDictionary alloc] init];
    [IDDic safeSetObject:traveler.IDCategory forKey:@"idType"];
    [IDDic safeSetObject:traveler.IDNumber forKey:@"number"];
    [params setObject:IDDic forKey:@"idProof"];
    [params setObject:@"0" forKey:@"birthday"];
    [params setObject:@"male" forKey:@"gender"];
    [params setObject:@"" forKey:@"email"];
    NSMutableDictionary *tel = [[NSMutableDictionary alloc] init];
    [tel setObject:@"86" forKey:@"dialCode"];
    [tel setObject:traveler.tel forKey:@"number"];
    [params safeSetObject:tel forKey:@"tel"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager PUT:url parameters: params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***正在添加新的旅客: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if ([[responseObject objectForKey:@"result"] isKindOfClass:[NSDictionary class]]) {
                OrderTravelerInfoModel *traveler = [[OrderTravelerInfoModel alloc] initWithJson:[responseObject objectForKey:@"result"]];
                completion(YES, traveler);
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
