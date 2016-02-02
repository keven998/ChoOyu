//
//  GoodsCommentDetail.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/22/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsCommentDetail.h"
#import "PeachTravel-swift.h"
#import "OrderDetailModel.h"

@implementation GoodsCommentDetail

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _commentId = [json objectForKey:@"id"];
        _contents = [json objectForKey:@"contents"];
        _isAnonymous = [json objectForKey:@"anonymous"];
        _commentUser = [[FrendModel alloc] initWithJson:[json objectForKey:@"user"]];
        NSTimeInterval pTime = [[json objectForKey:@"createTime"] longLongValue]/1000;
        _publishTime = [ConvertMethods timeIntervalToString:pTime withFormat:@"yyyy-MM-dd" withTimeZone:[NSTimeZone systemTimeZone]];
        _rating = [[json objectForKey:@"rating"] floatValue];
        _orderDetail = [[OrderDetailModel alloc] initWithJson:[json objectForKey:@"order"]];
    }
    return self;
}

@end
