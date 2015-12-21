//
//  StoreManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/21/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreDetailModel.h"

@interface StoreManager : NSObject

/**
 *  通过 storeId 获取店铺详情
 *
 *  @param storeId
 *  @param completion 
 */
+ (void)asyncLoadStoreInfoWithStoreId:(NSInteger)storeId completionBlock:(void (^) (BOOL isSuccess, StoreDetailModel *storeDetail))completion;


@end
