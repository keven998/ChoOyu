//
//  RestaurantsOfCity.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RecommendsOfCity.h"

@interface RestaurantsOfCity : RecommendsOfCity

@property (nonatomic, strong) NSArray *restaurantsList;

- (id)initWithJson:(id)json;

@end
