//
//  TravelNote.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/14/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TravelNote.h"

@implementation TravelNote

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _travelNoteId = [json objectForKey:@"id"];
        _title = [json objectForKey:@"title"];
        
        /**
         *  因为取到的游记里有换行符，在这里取最长的那一行
         */
        NSString *summaryStr = [json objectForKey:@"summary"];
        NSArray *summaryList=[summaryStr componentsSeparatedByString:@"\n"];
        for (NSString *s in summaryList) {
            if (s.length > _summary.length) {
                _summary = s;
            }
        }
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (id imageDic in [json objectForKey:@"images"]) {
            TaoziImage *image = [[TaoziImage alloc] initWithJson:imageDic];
            [tempArray addObject:image];
        }
        _images = tempArray;
        _authorName = [json objectForKey:@"authorName"];
        _authorAvatar = [json objectForKey:@"authorAvatar"];
        _source = [json objectForKey:@"source"];
        _sourceUrl = [json objectForKey:@"sourceUrl"];
        if ([json objectForKey:@"publishTime"] != [NSNull null]) {
            _publishDateStr = [ConvertMethods timeIntervalToString:([[json objectForKey:@"publishTime"] longLongValue]) withFormat:@"yyyy-MM-dd" withTimeZone:[NSTimeZone systemTimeZone]];
        }
    }
    return self;
}

@end
