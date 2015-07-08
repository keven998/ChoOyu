//
//  FrendRequest.m
//  PeachTravel
//
//  Created by liangpengshuai on 6/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "FrendRequest.h"
#import "PeachTravel-swift.h"

@implementation FrendRequest

- (id)initWithJson:(id)json
{
    if (self = [super init]) {
        NSDictionary *jsonDic;
        if ([json isKindOfClass:[NSDictionary class]]) {
            jsonDic = json;
        } else if([json isKindOfClass:[NSString class]]) {
            jsonDic = [JSONConvertMethod jsonObjcWithString:(NSString *)json];
        }
        _requestId = [jsonDic objectForKey:@"requestId"];
        _userId = [[jsonDic objectForKey:@"userId"] integerValue];
        _avatar = [jsonDic objectForKey:@"avatar"];
        _nickName = [jsonDic objectForKey:@"nickName"];
        _attachMsg = [jsonDic objectForKey:@"message"];
        _status = TZFrendDefault;
        _requestDate = [[NSDate date] timeIntervalSince1970];
        
    }
    return self;
}

@end
