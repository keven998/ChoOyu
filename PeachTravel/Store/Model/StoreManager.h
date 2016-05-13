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

//获取商家服务城市
+ (void)asyncLoadStoreServerCitiesWithStoreId:(NSInteger)storeId completionBlock:(void (^)(BOOL isSuccess, NSArray<CityDestinationPoi *> *cityList))completion;

//更新商家服务城市
+ (void)asyncUpdateSellerServerCities:(NSArray<CityDestinationPoi *> *)cities completionBlock:(void (^)(BOOL isSuccess))completion;

/**
 *  获取某个城市的服务商
 *
 *  @param cityId
 *  @param completion
 */
+ (void)asyncLoadStoreListInCity:(NSString *)cityId completionBlock:(void (^) (BOOL isSuccess, NSArray<StoreDetailModel *>*storeList))completion;

/**
 *  获取某个国家的服务商
 *
 *  @param countryId
 *  @param completion
 */
+ (void)asyncLoadStoreListInCounrty:(NSString *)countryId completionBlock:(void (^) (BOOL isSuccess, NSArray<StoreDetailModel *>*storeList))completion;


@end
