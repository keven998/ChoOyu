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
    
#warning 优惠券测试数据
    NSMutableArray *couponList = [[NSMutableArray alloc] init];
    for (int i=0; i<5; i++) {
        UserCouponDetail *model = [[UserCouponDetail alloc] initWithJson:nil];
        model.couponId = [NSString stringWithFormat:@"a%d", i];
        model.limitMoney = 100*i;
        model.discount = model.discount + i;
        [couponList addObject:model];
        completion(YES, couponList);
    }
    
    NSString *url = @"";
    [LXPNetworking GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
    }];
}

+ (void)asyncLoadUserCouponsWithUserId:(NSInteger)userId limitMoney:(float)lessMoney completionBlock:(void (^)(BOOL, NSArray<UserCouponDetail *> *))completion
{
#warning 优惠券测试数据
    NSMutableArray *couponList = [[NSMutableArray alloc] init];
    for (int i=0; i<5; i++) {
        UserCouponDetail *model = [[UserCouponDetail alloc] initWithJson:nil];
        model.couponId = [NSString stringWithFormat:@"a%d", i];
        model.discount = model.discount + i;
        model.limitMoney = 100*i;
        if (model.limitMoney <= lessMoney) {
            [couponList addObject:model];
        }
        completion(YES, couponList);
    }
    
    NSString *url = @"";
    [LXPNetworking GET:url parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
    }];
}

@end
