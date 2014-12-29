//
//  OperationData.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/20/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "OperationData.h"

@implementation OperationData

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        _imageUrl = [json objectForKey:@"cover"];
        _title = [json objectForKey:@"title"];
        _linkUrl = [json objectForKey:@"link"];
        _operationId = [json objectForKey:@"id"];
    }
    return self;
}

@end
