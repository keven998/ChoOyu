//
//  LXPHTTPAuthorization.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/7/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "LXPHTTPAuthorization.h"
#import "QiniuSDK.h"

@implementation LXPHTTPAuthorization

+ (NSString *)authorizationSignatureWithToken:(NSString *)token signatureMessage:(NSString *)signatureMessage
{
    NSString *retString;
    return retString;
}

+ (NSString *)signatureMessageWithURI:(NSString *)uri Date:(NSString *)date LxpId:(NSInteger)lxpId Query:(NSDictionary *)qureyDic Body:(NSDictionary *)bodyDic
{
    NSString *retString;
    
    NSMutableString *headerString = [[NSMutableString alloc] init];
    [headerString appendFormat:@"date="];
    [headerString appendString:[date stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]];
    
    [headerString appendFormat:@"&x-lvxingpai-id=%ld", lxpId];
    
    NSLog(@"headerString: %@", headerString);
    
    NSMutableString *queryString = [[NSMutableString alloc] init];
    for (NSString *key in qureyDic.allKeys) {
        NSString *value = [qureyDic objectForKey:key];
        if (![key isEqualToString:[qureyDic.allKeys lastObject]]) {
            if ([value isKindOfClass:[NSString class]]) {
                [queryString appendFormat:@"%@=%@&", key, [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]];
            } else {
                [queryString appendFormat:@"%@=%@&", key, value];
            }
        } else {
            if ([value isKindOfClass:[NSString class]]) {
                [queryString appendFormat:@"%@=%@", key, [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]];
            } else {
                [queryString appendFormat:@"%@=%@", key, value];
            }
        }
        NSLog(@"queryString: %@", queryString);
    }
    
    if (bodyDic) {
        NSString *jsonString = [self convertJsonObject2Json:bodyDic];
        NSString *bodyString = [QNUrlSafeBase64 encodeString:jsonString];
        NSLog(@"bodyString: %@", bodyString);
    }
    
    return retString;
}

+ (NSString *)convertJsonObject2Json:(id)object
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end
