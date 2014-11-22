 //
//  SpotPoi.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SpotPoi.h"
#import "TaoziImage.h"

@implementation SpotPoi

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _spotId = [json objectForKey:@"id"];
        _zhName = [json objectForKey:@"zhName"];
        _enName = [json objectForKey:@"enName"];
        _lat = [[[json objectForKey:@"coords"] objectForKey:@"lat"] doubleValue];
        _lng = [[[json objectForKey:@"coords"] objectForKey:@"lng"] doubleValue];
        _priceDesc = [json objectForKey:@"priceDesc"];
        _travelMonth = [json objectForKey:@"travelMonth"];
        _desc = [json objectForKey:@"desc"];
        NSMutableArray *tempImages = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            TaoziImage *taoziImage = [[TaoziImage alloc] initWithJson:imageDic];
            [tempImages addObject:taoziImage];
        }
        _images = tempImages;
        _address = [json objectForKey:@"address"];
        _openTime = [json objectForKey:@"openTime"];
        _timeCostStr = [json objectForKey:@"timeCostStr"];
        _trafficInfoUrl = [json objectForKey:@"trafficInfoUrl"];
        _guideUrl = [json objectForKey:@"guideUrl"];
        _kengdieUrl = [json objectForKey:@"kengdieUrl"];
    }
    return self;
}

@end
