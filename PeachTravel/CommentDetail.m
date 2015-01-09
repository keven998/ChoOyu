//
//  CommentDetail.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CommentDetail.h"

@implementation CommentDetail

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _nickName = [json objectForKey:@"authorName"];
        _avatar = [json objectForKey:@"authorAvatar"];
        _commentDetails = [json objectForKey:@"contents"];
        _commentTime = [ConvertMethods timeIntervalToString:([[json objectForKey:@"cTime"] longLongValue]/1000) withFormat:@"yyyy-MM-dd HH:mm:ss" withTimeZone:[NSTimeZone systemTimeZone]];
        
        if ([json objectForKey:@"rating"] == [NSNull null]) {
            _rating = 3.5;
        } else {
            _rating = [[json objectForKey:@"rating"] floatValue]*5;
        }
    }
    return self;
}

@end
