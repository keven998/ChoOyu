//
//  OrderUserInfoManager.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.

// ****  订单的用户信息管理  ****

#import "OrderUserInfoManager.h"

@implementation OrderUserInfoManager

+ (void)asyncLoadTravelersFromServerOfUser:(NSInteger)userId completionBlock:(void (^)(BOOL, NSArray<OrderTravelerInfoModel *> *))completion
{
    //TODO:  完善从服务器加载旅客信息
    NSMutableArray *retArray = [[NSMutableArray alloc] init];
    for (int i=0; i<8; i++) {
        OrderTravelerInfoModel *traveler = [[OrderTravelerInfoModel alloc] init];
        traveler.uid = [NSString stringWithFormat:@"%d", i];
        traveler.firstName = @"梁";
        traveler.lastName = @"小明";
        traveler.IDCategory = @"身份证";
        traveler.IDNumber = @"12321312312312";
        [retArray addObject:traveler];
    }
    completion(YES, retArray);
}

@end
