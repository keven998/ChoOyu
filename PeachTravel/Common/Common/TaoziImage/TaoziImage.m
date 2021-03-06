//
//  TaoziImage.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TaoziImage.h"

@implementation TaoziImage

- (id) initWithJson:(id)json
{
    if (self = [super init]) {
        _imageUrl = [json objectForKey:@"url"];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _imageUrl = [aDecoder decodeObjectForKey:@"url"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_imageUrl forKey:@"url"];
}

@end
