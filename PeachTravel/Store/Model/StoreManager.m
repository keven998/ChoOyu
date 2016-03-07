//
//  StoreManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/21/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "StoreManager.h"

@implementation StoreManager

+ (void)asyncLoadStoreInfoWithStoreId:(NSInteger)storeId completionBlock:(void (^)(BOOL, StoreDetailModel *))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/%ld", API_STORE, storeId];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [LXPNetworking GET:url parameters: nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"***开始加载店铺详情: %@", operation);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        
        if (storeId == 202847) {
            completion(YES, [[StoreDetailModel alloc] init]);
            return;

        }
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
        
        if (storeId == 202847) {
            completion(YES, [[StoreDetailModel alloc] init]);
            return;
            
        }
        completion(NO, nil);
        
    }];

}

@end
