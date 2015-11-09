//
//  CityPoi.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/14/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RecommendsOfCity.h"
#import "SuperPoi.h"

@interface CityPoi : SuperPoi<NSCoding>

@property (nonatomic, copy) NSString *playGuide;
@property (nonatomic, copy) NSString *timeCostDesc;
@property (nonatomic, copy) NSString *travelMonth;
@property (nonatomic, copy) NSString *diningTitles;
@property (nonatomic, copy) NSString *shoppingTitles;

@property (nonatomic) NSInteger goodsCount;
// 喜欢和去过
@property (nonatomic, assign) BOOL isVote;
@property (nonatomic, assign) BOOL traveled;
@property (nonatomic) NSUInteger imageCount;
@property (nonatomic, strong) NSArray *travelNotes;
@property (nonatomic, strong) RecommendsOfCity *restaurantsOfCity;
@property (nonatomic, strong) RecommendsOfCity *shoppingOfCity;

- (id)initWithJson:(id)json;

@end
