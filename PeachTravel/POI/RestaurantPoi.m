//
//  RestaurantPoi.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "RestaurantPoi.h"

@implementation RestaurantPoi


- (id)initWithJson:(id)json
{
    if (self = [super initWithJson:json]) {
        self.poiType = kRestaurantPoi;
        self.typeDesc = @"restaurant";
        _priceDesc = [json objectForKey:@"priceDesc"];
    }
    return self;
}

@end
