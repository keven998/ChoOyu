//
//  Favorite.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/4/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "Favorite.h"

@implementation Favorite

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _favoriteId = [json objectForKey:@"id"];
        _itemId = [json objectForKey:@"itemId"];
        NSString *typeStr = [json objectForKey:@"type"];
        if ([typeStr isEqualToString:@"vs"]) {
            _type = kSpotPoi;
        } else if ([typeStr isEqualToString:@"hotel"]) {
            _type = kHotelPoi;
        } else if ([typeStr isEqualToString:@"restaurant"]) {
            _type = kRestaurantPoi;
        } else if ([typeStr isEqualToString:@"shopping"]) {
            _type = kShoppingPoi;
        } else if ([typeStr isEqualToString:@"travelNote"]) {
            _type = kTravelNotePoi;
        } else if ([typeStr isEqualToString:@"loc"]) {
            _type = kCityPoi;
        }
        _detailUrl = [json objectForKey:@"detailUrl"];
        _zhName = [json objectForKey:@"zhName"];
        _enName = [json objectForKey:@"enName"];
        _desc = [json objectForKey:@"desc"];
        _createTime = [[json objectForKey:@"createTime"] longLongValue];
        NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            [imagesArray addObject:[[TaoziImage alloc] initWithJson:imageDic]];
        }
        _images = imagesArray;
        _timeCostDesc = [json objectForKey:@"timeCostDesc"];
        _priceDesc = [json objectForKey:@"priceDesc"];
        if ([json objectForKey:@"rating"] == [NSNull null] || ![json objectForKey:@"rating"]) {
            _rating = 3.5;
        } else {
            _rating = [[json objectForKey:@"rating"] floatValue]*5;
        }
        
        _locality = [[CityPoi alloc] initWithJson:[json objectForKey:@"locality"]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _favoriteId = [aDecoder decodeObjectForKey:@"id"];
        _itemId = [aDecoder decodeObjectForKey:@"itemId"];
        _type = [[aDecoder decodeObjectForKey:@"type"] integerValue];
        _zhName = [aDecoder decodeObjectForKey:@"zhName"];
        _enName = [aDecoder decodeObjectForKey:@"enName"];
        _desc = [aDecoder decodeObjectForKey:@"desc"];
        _createTime = [aDecoder decodeInt64ForKey:@"createTime"];
        _images = [aDecoder decodeObjectForKey:@"images"];
        _locality = [aDecoder decodeObjectForKey:@"locality"];
        _timeCostDesc = [aDecoder decodeObjectForKey:@"timeCostDesc"];
        _priceDesc = [aDecoder decodeObjectForKey:@"priceDesc"];
        _rating = [aDecoder decodeFloatForKey:@"rating"];
        _detailUrl = [aDecoder decodeObjectForKey:@"detailUrl"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_favoriteId forKey:@"id"];
    [aCoder encodeObject:_itemId forKey:@"itemId"];
    [aCoder encodeObject:[NSNumber numberWithInteger:_type] forKey:@"type"];
    [aCoder encodeObject:_zhName forKey:@"zhName"];
    [aCoder encodeObject:_enName forKey:@"enName"];
    [aCoder encodeObject:_desc forKey:@"desc"];
    [aCoder encodeInt64:_createTime forKey:@"createTime"];
    [aCoder encodeObject:_images forKey:@"images"];
    [aCoder encodeObject:_locality forKey:@"locality"];
    [aCoder encodeObject:_priceDesc forKey:@"priceDesc"];
    [aCoder encodeObject:_timeCostDesc forKey:@"timeCostDesc"];
    [aCoder encodeFloat:_rating forKey:@"rating"];
    [aCoder encodeObject:_detailUrl forKey:@"detailUrl"];

}

- (NSString *)typeDescByType
{
    if (_type == kSpotPoi) {
        return @"景点";
    } else if (_type == kHotelPoi) {
        return @"酒店";
    } else if (_type == kRestaurantPoi) {
        return @"美食";
    } else if (_type == kShoppingPoi) {
        return @"购物";
    } else if (_type == kTravelNotePoi) {
        return @"游记";
    } else {
        return @"城市";
    }
    return nil;
}

- (NSString *)typeFlagName
{
    if (_type == kSpotPoi) {
        return @"ic_fav_spot.png";
    } else if (_type == kHotelPoi) {
        return @"ic_fav_stay.png";
    } else if (_type == kRestaurantPoi) {
        return @"ic_fav_delicacy.png";
    } else if (_type == kShoppingPoi) {
        return @"ic_fav_shopping.png";
    } else if (_type == kTravelNotePoi) {
        return @"ic_fav_tnote.png";
    } else {
        return @"ic_fav_city.png";
    }
    return nil;
}

@end
