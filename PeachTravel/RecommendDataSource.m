//
//  RecommendDataSource.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RecommendDataSource.h"

@implementation RecommendDataSource

- (id) initWithJsonData:(id)data {
    if (self = [super init]) {
        _typeId = [[data objectForKey:@"type"] objectForKey:@"id"];
        _typeName = [[data objectForKey:@"type"] objectForKey:@"name"];
        NSMutableArray *tempLocalities = [[NSMutableArray alloc] init];
        for (id locality in [data objectForKey:@"localities"]) {
            Recommend *recommend = [[Recommend alloc] initWithJsonData:locality];
            [tempLocalities addObject:recommend];
        }
        _localities = tempLocalities;
    }
    return self;
}


@end

@implementation Recommend

- (id) initWithJsonData:(id)data {
    if (self = [super init]) {
        _recommondId = [data objectForKey:@"id"];
        _zhName = [data objectForKey:@"zhName"];
        _enName = [data objectForKey:@"enName"];
        _desc = [data objectForKey:@"desc"];
        _linkType = [[data objectForKey:@"linkType"] integerValue];
        _linkUrl = [data objectForKey:@"linkUrl"];
        _cover = [data objectForKey:@"cover"];
    }
    return self;
}

@end