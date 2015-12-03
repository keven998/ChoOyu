//
//  OrderUserInfoManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/12/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderTravelerInfoModel.h"

@interface OrderUserInfoManager : NSObject


/**
 *  检查旅客信息是否填写完整
 *
 *  @param traveler 待检查的旅客信息
 *
 *  @return 返回错误信息
 */
+ (NSString *)checkTravelerInfoIsComplete:(OrderTravelerInfoModel *)traveler;


/**
 *  从服务器上加载旅客信息
 *
 *  @param userId
 *  @param completion 
 */
+ (void)asyncLoadTravelersFromServerOfUser:(NSInteger)userId completionBlock:(void (^) (BOOL isSuccess, NSArray<OrderTravelerInfoModel *> *travelers))completion;

/**
 *  添加一个旅客信息
 *
 *  @param traveler   需要添加的旅客
 *  @param completion 完成后的回调
 */
+ (void)asyncAddTraveler:(OrderTravelerInfoModel *)traveler completionBlock:(void (^) (BOOL isSuccess, OrderTravelerInfoModel *traveler))completion;

/**
 *  修改旅客信息
 *
 *  @param traveler   需要修改的旅客
 *  @param completion 完成后的回掉
 */
+ (void)asyncEditTraveler:(OrderTravelerInfoModel *)traveler completionBlock:(void (^) (BOOL isSuccess, OrderTravelerInfoModel *traveler))completion;

@end
