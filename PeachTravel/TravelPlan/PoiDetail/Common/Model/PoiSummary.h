//
//  PoiSummary.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/11/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TripDetail.h"

@interface PoiSummary : NSObject

@property (nonatomic, copy) NSString *poiId;
@property (nonatomic) TZPoiType poiType;
@property (nonatomic, copy) NSString *poiTypeDesc;
@property (nonatomic, copy) NSString *zhName;
@property (nonatomic, copy) NSString *enName;
@property (nonatomic, copy) NSString *priceDesc;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *telephone;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, copy) NSString *timeCost;
@property (nonatomic, strong) NSArray *recommends;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic) NSInteger commentCount;
@property (nonatomic) float rating;
@property (nonatomic) double lat;
@property (nonatomic) double lng;
@property (nonatomic, strong) CityDestinationPoi *locality;
@property (nonatomic, copy) NSString *distanceStr;
@property (nonatomic) BOOL isMyFavorite;

- (id)initWithJson:(id)json;

- (NSDictionary *)prepareAllDataForUpload;     //将完整的数据结构转换成的 json 数据

/**
 *  将只含有 id 和 type 的 TripPoi 转化为 json 数据
 *
 *  @return
 */
- (NSDictionary *)prepareSummaryDataForUpdateBackUpTrip;


@end
