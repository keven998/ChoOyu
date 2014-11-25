//
//  ShoppingOfCity.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RecommendsOfCity.h"

@interface ShoppingOfCity : RecommendsOfCity

@property (nonatomic, strong) NSArray *shoppingList;

- (id)initWithJson:(id)json;

- (void)setRestaurantsListWithJson:(id)json;

@end
