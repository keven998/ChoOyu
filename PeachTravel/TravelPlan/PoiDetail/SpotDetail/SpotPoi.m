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
        _lng = [[[[json objectForKey:@"location"] objectForKey:@"coordinates"] firstObject] doubleValue];
        _lat = [[[[json objectForKey:@"location"] objectForKey:@"coordinates"] lastObject] doubleValue];
        _priceDesc = [json objectForKey:@"priceDesc"];
        _travelMonth = [json objectForKey:@"travelMonth"];
        _desc = [json objectForKey:@"desc"];
        _descUrl = [json objectForKey:@"descUrl"];
        NSMutableArray *tempImages = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            TaoziImage *taoziImage = [[TaoziImage alloc] initWithJson:imageDic];
            [tempImages addObject:taoziImage];
        }
        _images = tempImages;
        _address = [json objectForKey:@"address"];
        _openTime = [json objectForKey:@"openTime"];
        _timeCostStr = [json objectForKey:@"timeCostDesc"];
        _trafficInfoUrl = [json objectForKey:@"trafficInfoUrl"];
        _guideUrl = [json objectForKey:@"guideUrl"];
        _tipsUrl = [json objectForKey:@"tipsUrl"];
        
        if ([json objectForKey:@"rating"] == [NSNull null] || ![json objectForKey:@"rating"]) {
            _rating = 3.5;
        } else  if ([[json objectForKey:@"rating"] floatValue] > 1){
            _rating = [[json objectForKey:@"rating"] floatValue];
        } else {
            _rating = [[json objectForKey:@"rating"] floatValue]*5;
        }
        _isMyFavorite = [[json objectForKey:@"isFavorite"] boolValue];
    }
    return self;
}

@end
