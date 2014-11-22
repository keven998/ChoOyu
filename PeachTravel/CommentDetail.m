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
        _nickName = [json objectForKey:@"nickName"];
        _avatar = [json objectForKey:@"avatar"];
        _commentDetails = [json objectForKey:@"commentDetails"];
        _commentTime = [json objectForKey:@"commentTime"];
    }
    return self;
}

@end
