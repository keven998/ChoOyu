//
//  UserCouponsManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 2/18/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "UserCouponsManager.h"
#import "LXPNetworking.h"

@implementation UserCouponsManager

+ (void)asyncLoadUserCouponsWithUserId:(NSInteger)userId completionBlock:(void (^)(BOOL, NSArray<UserCouponDetail *> *))completion
{
    
    NSMutableArray *couponList = [[NSMutableArray alloc] init];
    for (int i=0; i<5; i++) {
        UserCouponDetail *model = [[UserCouponDetail alloc] initWithJson:nil];
        [couponList addObject:model];
        completion(YES, couponList);
    }
    
    NSString *url = @"";
    [LXPNetworking GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
    }];
}

@end
