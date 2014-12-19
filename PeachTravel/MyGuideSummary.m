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

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _guideId = [aDecoder decodeObjectForKey:@"id"];
        _title = [aDecoder decodeObjectForKey:@"title"];
        _updateTime = [aDecoder decodeInt64ForKey:@"updateTime"];
        _summary = [aDecoder decodeObjectForKey:@"summary"];
        _updateTimeStr = [aDecoder decodeObjectForKey:@"updateTimeStr"];
        _images = [aDecoder decodeObjectForKey:@"images"];
        _dayCount = [aDecoder decodeIntForKey:@"dayCnt"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_guideId forKey:@"id"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeInt64:_updateTime forKey:@"updateTime"];
    [aCoder encodeObject:_summary forKey:@"summary"];
    [aCoder encodeObject:_updateTimeStr forKey:@"updateTimeStr"];
    [aCoder encodeObject:_images forKey:@"images"];
    [aCoder encodeInt:_dayCount forKey:@"dayCnt"];
}

@end
