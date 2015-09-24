//
//  RecommendDataSource.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RecommendDataSource.h"

@implementation RecommendDataSource

- (id) initWithJsonData:(id)data {
    if (self = [super init]) {
        _typeName = [data objectForKey:@"title"];
        NSMutableArray *tempLocalities = [[NSMutableArray alloc] init];
        for (id locality in [data objectForKey:@"contents"]) {
            Recommend *recommend = [[Recommend alloc] initWithJsonData:locality];
            [tempLocalities addObject:recommend];
        }
        _localities = tempLocalities;
    }
    return self;
}

@end

@implementation Recommend

- (id) initWithJsonData:(id)data {
    if (self = [super init]) {
        _recommondId = [data objectForKey:@"itemId"];
        _title = [data objectForKey:@"title"];
        
        _desc = [data objectForKey:@"desc"];
        _linkType = [[data objectForKey:@"linkType"] integerValue];
        if ([[data objectForKey:@"linkType"] isEqualToString:@"app"]) {
            _linkType = LinkNative;
        } else if ([[data objectForKey:@"linkType"] isEqualToString:@"html"]) {
            _linkType = LinkHtml;
        }
        
        if ([[data objectForKey:@"itemType"] isEqualToString:@"vs"]) {
            _poiType = kSpotPoi;
        }
        if ([[data objectForKey:@"itemType"] isEqualToString:@"restaurant"]) {
            _poiType = kRestaurantPoi;
        }
        if ([[data objectForKey:@"itemType"] isEqualToString:@"shopping"]) {
            _poiType = kShoppingPoi;
        }
        if ([[data objectForKey:@"itemType"] isEqualToString:@"hotel"]) {
            _poiType = kHotelPoi;
        }
        if ([[data objectForKey:@"itemType"] isEqualToString:@"locality"]) {
            _poiType = kCityPoi;
        }

        _linkUrl = [data objectForKey:@"linkUrl"];
        _cover = [data objectForKey:@"cover"];
        
    }
    return self;
}

@end









