//
//  PoiSummary.h
//  PeachTravel
//
//  Created by liangpengshuai on 12/11/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PoiSummary : NSObject

@property (nonatomic, copy) NSString *poiId;
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
@property (nonatomic, copy) NSString *distanceStr;


- (id)initWithJson:(id)json;

@end
