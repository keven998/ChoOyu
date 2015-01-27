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
        _commentLongTime = [[json objectForKey:@"publishTime"] longLongValue];
        _commentTime = [ConvertMethods timeIntervalToString:(_commentLongTime/1000) withFormat:@"yyyy-MM-dd HH:mm:ss" withTimeZone:[NSTimeZone systemTimeZone]];
        
        if ([json objectForKey:@"rating"] == [NSNull null]) {
            _rating = 3.5;
        } else {
            _rating = [[json objectForKey:@"rating"] floatValue]*5;
        }
    }
    return self;
}

- (id)enCodeToJson
{
    NSMutableDictionary *retDic = [[NSMutableDictionary alloc] init];
    [retDic safeSetObject:_nickName forKey:@"authorName"];
    [retDic safeSetObject:_avatar forKey:@"authorAvatar"];
    [retDic safeSetObject:_commentDetails forKey:@"contents"];
    [retDic safeSetObject:[NSNumber numberWithLongLong:_commentLongTime] forKey:@"puhlishTime"];
    [retDic safeSetObject:[NSNumber numberWithFloat:_rating] forKey:@"rating"];
    return retDic;
}

@end
