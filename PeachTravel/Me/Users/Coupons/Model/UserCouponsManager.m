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
    
    [LXPNetworking GET:API_USERCOUPON parameters:@{@"userId": [NSNumber numberWithInteger:userId]} success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            for (NSDictionary *couponDic in [responseObject objectForKey:@"result"]) {
                UserCouponDetail *model = [[UserCouponDetail alloc] initWithJson:couponDic];
                [couponList addObject:model];
            }
            completion(YES, couponList);              
        } else {
            completion(NO, nil);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(NO, nil);

    }];
}

+ (void)asyncLoadUserCouponsWithUserId:(NSInteger)userId limitMoney:(float)lessMoney completionBlock:(void (^)(BOOL, NSArray<UserCouponDetail *> *))completion
{
    NSMutableArray *couponList = [[NSMutableArray alloc] init];
    [LXPNetworking GET:API_USERCOUPON parameters:@{@"userId": [NSNumber numberWithInteger:userId]} success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            for (NSDictionary *couponDic in [responseObject objectForKey:@"result"]) {
                UserCouponDetail *model = [[UserCouponDetail alloc] initWithJson:couponDic];
                if (model.limitMoney <= lessMoney) {
                    [couponList addObject:model];
                }
            }
            completion(YES, couponList);
        } else {
            completion(NO, nil);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        completion(NO, nil);
        
    }];
    
    
    
}

@end
