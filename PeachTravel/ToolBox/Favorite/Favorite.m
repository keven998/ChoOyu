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
        _type = [json objectForKey:@"type"];
        _zhName = [json objectForKey:@"zhName"];
        _enName = [json objectForKey:@"enName"];
        _desc = [json objectForKey:@"desc"];
        _createTime = [[json objectForKey:@"createTime"] longLongValue];
        NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            [imagesArray addObject:[[TaoziImage alloc] initWithJson:imageDic]];
        }
        _images = imagesArray;
        
        _locality = [[CityPoi alloc] initWithJson:[json objectForKey:@"locality"]];
    }
    return self;
}

- (NSString *)getTypeDesc {
    if ([_type isEqualToString:@"vs"]) {
        return @"景点";
    } else if ([_type isEqualToString:@"hotel"]) {
        return @"酒店";
    } else if ([_type isEqualToString:@"restaurant"]) {
        return @"美食";
    } else if ([_type isEqualToString:@"shopping"]) {
        return @"购物";
    } else if ([_type isEqualToString:@"travelNote"]) {
        return @"游记";
    } else {
        return @"城市";
    }
    return nil;
}

- (NSString *)getTypeFlagName {
    if ([_type isEqualToString:@"vs"]) {
        return @"ic_fav_spot.png";
    } else if ([_type isEqualToString:@"hotel"]) {
        return @"ic_fav_stay.png";
    } else if ([_type isEqualToString:@"restaurant"]) {
        return @"ic_fav_delicacy.png";
    } else if ([_type isEqualToString:@"shopping"]) {
        return @"ic_fav_shopping.png";
    } else if ([_type isEqualToString:@"travelNote"]) {
        return @"ic_fav_tnote.png";
    } else {
        return @"ic_fav_city.png";
    }
    return nil;
}

@end
