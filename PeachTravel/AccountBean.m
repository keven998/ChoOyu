//
//  AccountBean.m
//  lvxingpai
//
//  Created by Luo Yong on 14-7-23.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#import "AccountBean.h"

@implementation AccountBean

- (id)initWithJson:(id)json
{
    self = [super init];
    if (self) {
        _userId = [[json objectForKey:@"userId"] integerValue];
        _nickName = [json objectForKey:@"nickName"];
        _avatar = [json objectForKey:@"avatar"];
        _gender = [json objectForKey:@"gender"];
        _tel = [json objectForKey:@"tel"];
        _secToken = [json objectForKey:@"secToken"];
        _signature = [json objectForKey:@"signature"];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _userId = [[aDecoder decodeObjectForKey:@"userId"] integerValue];
        _nickName = [aDecoder decodeObjectForKey:@"nickName"];
        _avatar = [aDecoder decodeObjectForKey:@"avatar"];
        _gender = [aDecoder decodeObjectForKey:@"gender"];
        _tel = [aDecoder decodeObjectForKey:@"tel"];
        _secToken = [aDecoder decodeObjectForKey:@"secToken"];
        _signature = [aDecoder decodeObjectForKey:@"signature"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInteger: _userId] forKey:@"userId"];
    [aCoder encodeObject:_nickName forKey:@"nickName"];
    [aCoder encodeObject:_avatar forKey:@"avatar"];
    [aCoder encodeObject:_gender forKey:@"gender"];
    [aCoder encodeObject:_secToken forKey:@"secToken"];
    [aCoder encodeObject:_tel forKey:@"tel"];
    [aCoder encodeObject:_signature forKey:@"signature"];
}

@end
