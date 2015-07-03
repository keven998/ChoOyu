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
        self.typeDesc = @"vs";
        self.poiTypeName = @"景点";
        _bookUrl = [json objectForKey:@"lyPoiUrl"];
        _timeCostStr = [json objectForKey:@"timeCostDesc"];
        _trafficInfoUrl = [json objectForKey:@"trafficInfoUrl"];
        _guideUrl = [json objectForKey:@"visitGuideUrl"];
        _tipsUrl = [json objectForKey:@"tipsUrl"];
        _travelMonth = [json objectForKey:@"travelMonth"];
        _telephone = [json objectForKey:@"telephone"];
    }
    return self;
}

- (NSDictionary *)enCodeAllDataToDictionary
{
    NSMutableDictionary *retDic = [[super enCodeAllDataToDictionary] mutableCopy];
    [retDic safeSetObject:_timeCostStr forKey:@"timeCostDesc"];
    [retDic safeSetObject:super.priceDesc forKey:@"priceDesc"];

    return retDic;

}
@end
