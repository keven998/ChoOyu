//
//  NSURL+TZURL.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/9/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "NSURL+TZURL.h"

@implementation NSURL (TZURL)

- (NSString *)parameterForKey:(NSString *)key
{
    NSDictionary *parameters = [self parameters];
    if(parameters == nil)
        return nil;
    return parameters[key];
}
- (NSDictionary  *)parameters
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSString *query = [self query];
    NSArray *values = [query componentsSeparatedByString:@"&"];
    
    if(values == nil || values.count == 0)
        return nil;
    
    for(NSString *value in values)
    {
        NSArray *param = [value componentsSeparatedByString:@"="];
        if(param == nil || param.count !=2)
            continue;
        [parameters setObject:param[1] forKey:param[0]];
    }
    return parameters;
}

@end
