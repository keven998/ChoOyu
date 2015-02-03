//
//  RecommendsOfCity.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RecommendsOfCity.h"
#import "PoiSummary.h"

@implementation RecommendsOfCity

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _cityId = [json objectForKey:@"id"];
        _zhName = [json objectForKey:@"zhName"];
        _enName = [json objectForKey:@"enName"];
        _desc = [json objectForKey:@"desc"];
        NSMutableArray *tempImages = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            TaoziImage *image = [[TaoziImage alloc] initWithJson:imageDic];
            [tempImages addObject:image];
        }
        _rating = [[json objectForKey:@"rating"] floatValue];
        _images = tempImages;

    }
    return self;
}

- (void)addRecommendList:(id)json
{
    if (!_recommendList) {
        _recommendList = [[NSMutableArray alloc] init];
    }
    for (NSDictionary *poiDic in json) {
        PoiSummary *poi = [[PoiSummary alloc] initWithJson:poiDic];
        [_recommendList addObject:poi];
    }
}
@end
