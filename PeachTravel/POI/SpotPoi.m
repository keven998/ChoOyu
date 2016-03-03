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
        
        _trafficInfo = [json objectForKey:@"trafficInfo"];
        _trafficInfoUrl = [json objectForKey:@"trafficInfoUrl"];
        
        _guideInfo = [json objectForKey:@"visitGuide"];
        _guideUrl = [json objectForKey:@"visitGuideUrl"];
        
        NSMutableString *tipsStr = [[NSMutableString alloc] init];
        for (NSDictionary *tipsDic in [json objectForKey:@"tips"]) {
            [tipsStr appendString:[NSString stringWithFormat:@"%@\n", [tipsDic objectForKey:@"title"]]];
            [tipsStr appendString:[NSString stringWithFormat:@"%@\n", [tipsDic objectForKey:@"desc"]]];
        }
        _tipsInfo = tipsStr;
        
        _tipsUrl = [json objectForKey:@"tipsUrl"];
        _travelMonth = [json objectForKey:@"travelMonth"];
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
