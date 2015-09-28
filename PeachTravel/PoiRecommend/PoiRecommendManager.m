//
//  PoiRecommendManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/28/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "PoiRecommendManager.h"

@implementation PoiRecommendManager

+ (void)asyncLoadDomescticRecommendPoiWithCompletionBlcok:(void (^)(BOOL isSuccess, NSArray *poiList))completion
{
    [self asyncLoadRecommendPoiWithIsAbroad:NO completionBlcok:^(BOOL isSuccess, NSArray *poiList) {
        completion(isSuccess, poiList);
    }];
    
}

+ (void)asyncLoadForeignRecommendPoiWithCompletionBlcok:(void (^)(BOOL isSuccess, NSArray *poiList))completion
{
    [self asyncLoadRecommendPoiWithIsAbroad:YES completionBlcok:^(BOOL isSuccess, NSArray *poiList) {
        completion(isSuccess, poiList);
    }];

}

+ (void)asyncLoadRecommendPoiWithIsAbroad:(BOOL)isAbroad completionBlcok:(void (^)(BOOL, NSArray *))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSNumber *imageWidth = [NSNumber numberWithInt:450];
    NSDictionary *params = @{@"imgWidth": imageWidth, @"itemType": @"locality", @"isAbroad": [NSNumber numberWithBool:isAbroad]};
    
    NSString *url = [NSString stringWithFormat:@"%@recommendations", API_GET_LOCALITIES];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSMutableArray *retArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in [responseObject objectForKey:@"result"]) {
                PoiRecommend *poi = [[PoiRecommend alloc] initWithJson:dic];
                [retArray addObject:poi];
            }
            completion(YES, retArray);
            
        } else {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
            completion(NO, nil);
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showHint:HTTP_FAILED_HINT];
        completion(NO, nil);
        
    }];

}

@end
