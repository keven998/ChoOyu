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
 *  从服务器上加载旅客信息
 *
 *  @param userId
 *  @param completion 
 */
+ (void)asyncLoadTravelersFromServerOfUser:(NSInteger)userId completionBlock:(void (^) (BOOL isSuccess, NSArray<OrderTravelerInfoModel *> *travelers))completion;

@end
