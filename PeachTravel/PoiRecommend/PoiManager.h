//
//  PoiManager.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/28/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

typedef enum : NSUInteger {
    kRECOM,
    kEU,
    kAS,
    kAF,
    kNA,
    kSA,
    kOC
} kContinentCode;

#import <Foundation/Foundation.h>
#import "PoiRecommend.h"

@interface PoiManager : NSObject

+ (void)asyncLoadDomescticRecommendPoiWithCompletionBlcok:(void (^)(BOOL isSuccess, NSArray *poiList))completion;

+ (void)asyncLoadForeignRecommendPoiWithCompletionBlcok:(void (^)(BOOL isSuccess, NSArray *poiList))completion;

/**
 *  从服务器上获取国家列表
 *
 *  @param continentCode 洲 code
 *  @param completion    
 */
+ (void)asyncLoadRecommendCountriesWithContinentCode:(kContinentCode)continentCode completionBlcok:(void (^)(BOOL isSuccess, NSArray *poiList))completion;

/**
 *  获取某个国家的城市
 *
 *  @param countryId  国家 ID
 *  @param completion 
 */
+ (void)asyncLoadCitiesOfCountry:(NSString *)countryId completionBlcok:(void (^)(BOOL isSuccess, NSArray *poiList))completion;

/**
 *  通过传入 cityid 加载城市信息
 *
 *  @param cityId
 *  @param completion 
 */
+ (void)asyncLoadCityInfo:(NSString *)cityId completionBlock:(void (^) (BOOL isSuccess, CityPoi *cityDetail))completion;

@end
