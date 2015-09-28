
//
//  PoiRecommend.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/28/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "PoiRecommend.h"

@implementation PoiRecommend

- (id) initWithJson:(id)data {
    if (self = [super init]) {
        _recommondId = [data objectForKey:@"itemId"];
        _zhName = [data objectForKey:@"zhName"];
        
        _desc = [data objectForKey:@"desc"];
        
        if ([[data objectForKey:@"itemType"] isEqualToString:@"vs"]) {
            _poiType = kSpotPoi;
        } else if ([[data objectForKey:@"itemType"] isEqualToString:@"restaurant"]) {
            _poiType = kRestaurantPoi;
        } else if ([[data objectForKey:@"itemType"] isEqualToString:@"shopping"]) {
            _poiType = kShoppingPoi;
        } else if ([[data objectForKey:@"itemType"] isEqualToString:@"hotel"]) {
            _poiType = kHotelPoi;
        } else {
            _poiType = kCityPoi;
        }
        
        _linkUrl = [data objectForKey:@"linkUrl"];
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (id imageDic in [data objectForKey:@"images"]) {
            TaoziImage *image = [[TaoziImage alloc] initWithJson:imageDic];
            [tempArray addObject:image];
        }
        _images = tempArray;
        

        
    }
    return self;
}

@end
