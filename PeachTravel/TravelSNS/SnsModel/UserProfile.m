//
//  UserProfile.m
//  PeachTravel
//
//  Created by Luo Yong on 15/4/17.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "UserProfile.h"

@implementation UserProfile


- (id) initWithJsonObject:(id)json {
    if (self = [super init]) {
        _userId = [json objectForKey:@"id"];
        _avatarSmall = [json objectForKey:@"avatarSmall"];
        _name = [json objectForKey:@"nickName"];
        _gender = [json objectForKey:@"gender"];
        _residence = [json objectForKey:@"residence"];
        _level = [[json objectForKey:@"level"] integerValue];
        _signature = [json objectForKey:@"signature"];
        id rs = [json objectForKey:@"roles"];
        if (rs != nil && [rs count] > 0) {
            _roles = [json objectForKey:@"id"];
        }
        _travels = [json objectForKey:@"tracks"];
    }
    return self;
}

@end
