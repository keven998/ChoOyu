//
//  CityDestinationPoi.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CityDestinationPoi.h"

@implementation CityDestinationPoi

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _destinationId = [json objectForKey:@"id"];
        _zhName = [json objectForKey:@"zhName"];
        _enName = [json objectForKey:@"enName"];
        _pinyin = [ConvertMethods chineseToPinyin:_zhName];
    }
    return self;
}

@end
