//
//  PoiFactory.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/19/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "PoiFactory.h"
#import "SpotPoi.h"
#import "RestaurantPoi.h"
#import "ShoppingPoi.h"
#import "HotelPoi.h"
#import "CityPoi.h"

@implementation PoiFactory

+ (SuperPoi *)poiWithPoiType:(TZPoiType)poiType andJson:(id)json
{
    SuperPoi *retPoi;
    switch (poiType) {
        case kSpotPoi:
            retPoi = [[SpotPoi alloc] initWithJson:json];
            break;
            
        case kRestaurantPoi:
            retPoi = [[RestaurantPoi alloc] initWithJson:json];
            break;
            
        case kShoppingPoi:
            retPoi = [[ShoppingPoi alloc] initWithJson:json];
            break;
            
        case kHotelPoi:
            retPoi = [[HotelPoi alloc] initWithJson:json];
            break;
            
        case kCityPoi:
            retPoi = [[CityPoi alloc] initWithJson:json];
            break;
            
        default:
            break;
    }
    return retPoi;
}

+ (SuperPoi *)poiWithPoiTypeDesc:(NSString *)poiTypeDesc andJson:(id)json
{
    TZPoiType poiType = 0;
    if ([poiTypeDesc isEqualToString:@"locality"]) {
        poiType = kCityPoi;
    }
    if ([poiTypeDesc isEqualToString:@"vs"]) {
        poiType = kSpotPoi;
    }if ([poiTypeDesc isEqualToString:@"restaurant"]) {
        poiType = kRestaurantPoi;
    }if ([poiTypeDesc isEqualToString:@"shopping"]) {
        poiType = kShoppingPoi;
    }if ([poiTypeDesc isEqualToString:@"hotel"]) {
        poiType = kHotelPoi;
    }
    return [PoiFactory poiWithPoiType:poiType andJson:json];
}

+ (SuperPoi *)poiWithJson:(id)json
{
    return [PoiFactory poiWithPoiTypeDesc:[json objectForKey:@"type"] andJson:json];
}


@end
