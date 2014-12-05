//
//  MyGuideSummary.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/29/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "MyGuideSummary.h"

@implementation MyGuideSummary

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _guideId = [json objectForKey:@"id"];
        _title = [json objectForKey:@"title"];
        _updateTime = [[json objectForKey:@"updateTime"] longLongValue]/1000;
        _summary = [json objectForKey:@"summary"];
        NSMutableArray *imagesArray = [[NSMutableArray alloc] init];
        _updateTimeStr = [ConvertMethods timeIntervalToString:_updateTime withFormat:@"yyyy-MM-dd HH:mm:ss" withTimeZone:[NSTimeZone systemTimeZone]];
        for (id imageDic in [json objectForKey:@"images"]) {
            TaoziImage *image = [[TaoziImage alloc] initWithJson:imageDic];
            [imagesArray addObject:image];
        }
        _images = imagesArray;
        _dayCount = [[json objectForKey:@"dayCnt"] integerValue];
    }
    return self;
}

@end
