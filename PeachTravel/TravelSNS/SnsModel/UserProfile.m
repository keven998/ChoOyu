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
        _roles = [json objectForKey:@"roles"];
        _travels = [json objectForKey:@"tracks"];
    }
    return self;
}

- (NSString *)getFootprintDescription {
    if (_travels == nil) return @"";
    NSInteger count = [_travels count];
    if (count == 0) return @"";
    int cityCount = 0;
    for (id key in _travels) {
        id vals = [_travels objectForKey:key];
        cityCount += [vals count];
    }
    return [NSString stringWithFormat:@"%ld个国家、%d个城市", count, cityCount];
}

- (NSString *)getRolesDescription {
    if (_roles == nil || _roles.count == 0) return @"";
    if ([[_roles objectAtIndex:0] isEqualToString:@"expert"]) {
        return @"达";
    }
    return @"";
}

@end
