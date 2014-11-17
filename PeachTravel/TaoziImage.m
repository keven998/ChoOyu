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
@end
