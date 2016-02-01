//
//  GoodsCommentDetail.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/22/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsCommentDetail.h"

@implementation GoodsCommentDetail

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _commentId = [json objectForKey:@"id"];
        _contents = [json objectForKey:@"contents"];
        _commentUser = [[FrendModel alloc] initWithJson:[json objectForKey:@"user"]];
        NSTimeInterval pTime = [[json objectForKey:@"createTime"] longLongValue]/1000;
        _publishTime = [ConvertMethods timeIntervalToString:pTime withFormat:@"yyyy-MM-dd" withTimeZone:[NSTimeZone systemTimeZone]];
        _rating = [[json objectForKey:@"rating"] floatValue];
        
        _contents = @"第一次迟到这么好吃的火锅，下次还回来的第一次迟到这么好吃的火锅，下次还回来的第一次迟到这么好吃的火锅，下次还回来的第一次迟到这么好吃的火锅，下次还回来的";
    }
    return self;
}

@end
