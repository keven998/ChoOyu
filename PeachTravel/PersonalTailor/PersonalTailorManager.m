//
//  PersonalTailorManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/11/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PersonalTailorManager.h"

@implementation PersonalTailorManager

+ (void)asyncLoadRecommendPersonalTailorData:(void (^) (BOOL isSuccess, NSArray<PTDetailModel *> *resultList))completion
{
    NSString *url = [NSString stringWithFormat:@"%@/marketplace/bounties", BASE_URL];
    [LXPNetworking GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        if (result == 0) {
            NSMutableArray *retArray = [[NSMutableArray alloc] init];
            for (NSDictionary *dic in [responseObject objectForKey:@"result"]) {
                [retArray addObject:[[PTDetailModel alloc] initWithJson:dic]];
            }
            completion(YES, retArray);
        } else {
            completion(NO, nil);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(NO, nil);

    }];
}

@end
