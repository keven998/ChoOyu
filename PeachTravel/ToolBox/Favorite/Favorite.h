//
//  Favorite.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/4/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CityPoi.h"

@interface Favorite : NSObject<NSCoding>

@property (nonatomic, copy) NSString *favoriteId;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic) TZPoiType type;
@property (nonatomic, copy) NSString *zhName;
@property (nonatomic, copy) NSString *enName;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, copy) NSString *timeCostDesc;
@property (nonatomic, copy) NSString *priceDesc;
@property (nonatomic) float rating;
@property (nonatomic) long long createTime;
@property (nonatomic, strong) CityPoi *locality;

- (id)initWithJson:(id)json;

- (NSString *)typeDescByType;
- (NSString *)typeFlagName;

@end
