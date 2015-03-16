//
//  SuperPoi.h
//  PeachTravel
//
//  Created by liangpengshuai on 3/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CityDestinationPoi.h"

@interface SuperPoi : NSObject

@property (nonatomic, copy) NSString *poiId;
@property (nonatomic, copy) NSString *zhName;
@property (nonatomic, copy) NSString *enName;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy, readonly) NSString *typeDesc;
@property (nonatomic) TZPoiType poiType;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, copy) NSString *moreCommentsUrl;
@property (nonatomic, copy) NSString *address;
@property (nonatomic) float rating;
@property (nonatomic) int rank;
@property (nonatomic) float lat;
@property (nonatomic) float lng;
@property (nonatomic, strong) CityDestinationPoi *locality;
@property (nonatomic) BOOL isMyFavorite;

- (id)initWithJson:(id)json;

/**
 *  将完整的数据结构转换成的 Dictionary 数据,子类中补充完整.
 *  用于用户上传时候使用
 *  @return
 */
- (NSDictionary *)enCodeAllDataToDictionary;

/**
 *  将只含有 id 和 type 的 TripPoi 转化为Dictionary 数据.用于用户上传时候使用
 *  用于用户上传时候使用
 *  @return
 */
- (NSDictionary *)enCodeSummaryDataToDictionary;

@end



