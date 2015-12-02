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

+ (void)asyncAddTraveler:(OrderTravelerInfoModel *)traveler completionBlock:(void (^)(BOOL, OrderTravelerInfoModel *))completion
{
    
}

@end
