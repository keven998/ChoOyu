//
//  GuilderManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 8/31/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuilderManager.h"
#import "PeachTravel-swift.h"

@implementation GuilderManager

+ (void)asyncLoadGuidersWithAreaId:(NSString *)areaId page:(NSInteger)page pageSize:(NSInteger)pageSize completionBlock:(void (^)(BOOL isSuccess, NSArray *guiderArray))completionBlock
{
    // 1.初始化管理对象
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    // 2.设置请求的一些类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // 3.设置请求参数
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:60];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:@"expert" forKey:@"keyword"];
    [params setObject:@"roles" forKey:@"field"];
    [params setObject:areaId forKey:@"locId"];
    [params setObject:[NSNumber numberWithInt:16] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInteger:page] forKey:@"page"];
    
    NSLog(@"%@",API_SEARCH_USER);
    
    // 更新新链接
    NSString * urlStr = [NSString stringWithFormat:@"%@%@/expert",API_GET_EXPERT_DETAIL,areaId];
    
    NSLog(@"%@",urlStr);
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

+ (NSArray *)parseGuiderListRequestResult:(id)result
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in result) {
        FrendModel *frend = [[FrendModel alloc] initWithJson:dic];
        [array addObject:frend];
    }
    return array;
}



@end
