//
//  SpotPoi.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "SpotPoi.h"

@implementation SpotPoi

- (id)initWithJson:(id)json
{
    if (self = [super initWithJson:json]) {
        self.poiType = kSpotPoi;
        _priceDesc = [json objectForKey:@"priceDesc"];
        _bookUrl = [json objectForKey:@"lyPoiUrl"];
        _openTime = [json objectForKey:@"openTime"];
        _timeCostStr = [json objectForKey:@"timeCostDesc"];
        _trafficInfoUrl = [json objectForKey:@"trafficInfoUrl"];
        _guideUrl = [json objectForKey:@"visitGuideUrl"];
        _tipsUrl = [json objectForKey:@"tipsUrl"];
        _travelMonth = [json objectForKey:@"travelMonth"];
        _descUrl = [json objectForKey:@"descUrl"];
    }
    return self;
}

@end
