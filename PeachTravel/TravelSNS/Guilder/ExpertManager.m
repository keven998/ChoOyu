//
//  ExpertManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 8/31/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "ExpertManager.h"
#import "PeachTravel-swift.h"

@implementation ExpertManager

+ (void)asyncLoadExpertsWithAreaId:(NSString *)areaId page:(NSInteger)page pageSize:(NSInteger)pageSize completionBlock:(void(^)(BOOL isSuccess, NSArray *expertsArray))completionBlock
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:60];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:@"expert" forKey:@"keyword"];
    [params setObject:@"roles" forKey:@"field"];
    [params setObject:areaId forKey:@"locId"];
    [params setObject:[NSNumber numberWithInt:16] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    
    NSString * urlStr = [NSString stringWithFormat:@"%@%@/expert",API_GET_EXPERT_DETAIL,areaId];
    
    NSLog(@"%@",urlStr);
    
    [LXPNetworking GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSArray *resultArray = [self parseGuiderListRequestResult:[responseObject objectForKey:@"result"]];
            completionBlock(YES, resultArray);
        } else {
            completionBlock(NO, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(NO, nil);
    }];
}

+ (void)asyncLoadExpertsWithAreaName:(NSString *)areaName page:(NSInteger)page pageSize:(NSInteger)pageSize completionBlock:(void (^)(BOOL, NSArray *))completionBlock
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:areaName forKey:@"zone"];
    [params setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    
    NSString * urlStr = [NSString stringWithFormat:@"%@experts",API_USERS];
    
    NSLog(@"%@",urlStr);
    
    [LXPNetworking GET:urlStr parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSArray *resultArray = [self parseGuiderListRequestResult:[responseObject objectForKey:@"result"]];
            completionBlock(YES, resultArray);
        } else {
            completionBlock(NO, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(NO, nil);
    }];

}

/**
 *  解析达人列表的数据
 *
 *  @param result
 *
 *  @return
 */
+ (NSArray *)parseGuiderListRequestResult:(id)result
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in result) {
        ExpertModel *frend = [[ExpertModel alloc] initWithJson:dic];
        [array addObject:frend];
    }
    return array;
}

+ (void)asyncRequest2BeAnExpert:(NSString *)phoneNumber completionBlock:(void (^)(BOOL isSuccess))completionBlock
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if ([[AccountManager shareAccountManager] isLogin]) {
        [params safeSetObject:[NSNumber numberWithInteger: [AccountManager shareAccountManager].account.userId] forKey:@"userId"];
    }
    [params safeSetObject:phoneNumber forKey:@"tel"];
    
    [LXPNetworking POST:API_EXPERTREQUEST parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            completionBlock(YES);
        } else {
            completionBlock(NO);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(NO);
    }];
}

@end









