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
        _desc = [json objectForKey:@"desc"];
        _cover = [json objectForKey:@"cover"];
        _authorName = [json objectForKey:@"authorName"];
        _authorAvatar = [json objectForKey:@"authorAvatar"];
        _source = [json objectForKey:@"source"];
        _sourceUrl = [json objectForKey:@"sourceUrl"];
        if ([json objectForKey:@"publishDate"] != [NSNull null]) {
            _publishDateStr = [ConvertMethods timeIntervalToString:([[json objectForKey:@"publishDate"] longLongValue]/1000) withFormat:@"yyyt-MM-dd HH:mm:ss" withTimeZone:[NSTimeZone systemTimeZone]];
        }
    }
    return self;
}

@end
