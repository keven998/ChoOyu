//
//  CityPoi.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/14/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SuperPoi.h"

@interface CityPoi : NSObject

@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *enName;
@property (nonatomic) double lat;
@property (nonatomic) double lng;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic) double timeCost;
@property (nonatomic, copy) NSString *travelMonth;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic) NSUInteger imageCount;
@property (nonatomic, strong) NSArray *travelNotes;

- (id)initWithJson:(id)json;

@end
