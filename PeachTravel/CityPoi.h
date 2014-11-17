//
//  CityPoi.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/14/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SuperPoi.h"

@interface CityPoi : NSObject

@property (nonatomic, strong) NSString *cityId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *enName;
@property (nonatomic) double lat;
@property (nonatomic) double lng;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic) double timeCost;
@property (nonatomic, strong) NSString *travelMonth;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic) NSUInteger imageCount;
@property (nonatomic, strong) NSArray *travelNotes;

- (id)initWithJson:(id)json;

@end
