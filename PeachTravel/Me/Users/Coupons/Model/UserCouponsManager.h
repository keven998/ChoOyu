//
//  UserCouponsManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 2/18/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserCouponDetail.h"

@interface UserCouponsManager : NSObject

/**
 *  异步从服务器上加载用户优惠券列表
 *
 *  @param userId
 *  @param completion 
 */
+ (void)asyncLoadUserCouponsWithUserId:(NSInteger)userId completionBlock:(void (^) (BOOL isSuccess, NSArray <UserCouponDetail *>* couponsList))completion;

@end
