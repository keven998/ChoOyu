//
//  TripDetail.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

/**************
 * **************包含三张单的所有数据************
 ****************/

#import <Foundation/Foundation.h>
#import "CityDestinationPoi.h"

@interface TripDetail : NSObject

@property (nonatomic, strong) id backUpJson;               //备份 json 串，用来生成备份路线
@property (nonatomic, strong) TripDetail *backUpTrip;      //备份路线

@property (nonatomic, copy) NSString *tripId;
@property (nonatomic, copy) NSString *tripTitle;
@property (nonatomic, strong) NSArray *destinations;       //保存目的地列表;
@property (nonatomic, strong) NSMutableArray *itineraryList;
@property (nonatomic, strong) NSMutableArray *shoppingList;
@property (nonatomic, strong) NSMutableArray *restaurantsList;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic) NSInteger dayCount;         //行程单一共有几天

/**
 *  攻略是否发生了变化
 */
@property (nonatomic) BOOL tripIsChange;
- (id)initWithJson:(id)json;

/**
 *  保存所有的路线，包含三张单的内容,但是你别小瞧了这个函数，这个函数可厉害了，他会自动判断你哪张单做了改动，要是没做改动是不会上传的。
 */
- (void)saveTrip:(void(^)(BOOL isSuccesss))completion;


@end

@interface TripPoi : NSObject


@property (nonatomic, copy) NSString *poiId;
@property (nonatomic, copy) NSString *zhName;
@property (nonatomic, copy) NSString *enName;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *priceDesc;
@property (nonatomic, copy) NSString *address;
@property (nonatomic) TZPoiType poiType;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic) float rating;
@property (nonatomic, copy) NSString *telephone;
@property (nonatomic) double lng;
@property (nonatomic) double lat;
@property (nonatomic, strong) CityDestinationPoi *locality;
@property (nonatomic, copy) NSString *timeCost;
@property (nonatomic, copy) NSString *distanceStr;

- (id) initWithJson:(id)json;

- (NSDictionary *)prepareAllDataForUpload;     //将完整的数据结构转换成的 json 数据

/**
 *  将只含有 id 和 type 的 TripPoi 转化为 json 数据
 *
 *  @return 
 */
- (NSDictionary *)prepareSummaryDataForUpdateBackUpTrip;

@end








