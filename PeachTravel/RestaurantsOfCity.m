//
//  RestaurantsOfCity.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RestaurantsOfCity.h"
#import "RestaurantPoi.h"

@implementation RestaurantsOfCity

- (id)initWithJson:(id)json
{
    if (self = [super initWithJson:json]) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (id restaurantDic in [json objectForKey:@"poiList"]) {
            RestaurantPoi *poi = [[RestaurantPoi alloc] initWithJson:restaurantDic];
            [tempArray addObject:poi];
        }
        _restaurantsList = tempArray;
    }
    return self;
}

@end

