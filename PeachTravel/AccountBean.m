//
//  AccountBean.m
//  lvxingpai
//
//  Created by Luo Yong on 14-7-23.
//  Copyright (c) 2014年 aizou. All rights reserved.
//

#import "AccountBean.h"

@implementation AccountBean

@synthesize uid;
@synthesize uname;
@synthesize avatar;
@synthesize gender;
@synthesize accountType;
@synthesize platformToken;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        uid = [aDecoder decodeObjectForKey:@"uid"];
        uname = [aDecoder decodeObjectForKey:@"uname"];
        avatar = [aDecoder decodeObjectForKey:@"avatar"];
        gender = [aDecoder decodeObjectForKey:@"gender"];
        accountType = [aDecoder decodeIntForKey:@"accountType"];
        platformToken = [aDecoder decodeObjectForKey:@"platformToken"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:uid forKey:@"uid"];
    [aCoder encodeObject:uname forKey:@"uname"];
    [aCoder encodeObject:avatar forKey:@"avatar"];
    [aCoder encodeObject:gender forKey:@"gender"];
    [aCoder encodeInt:accountType forKey:@"accountType"];
    [aCoder encodeObject:platformToken forKey:@"platformToken"];
}

@end
