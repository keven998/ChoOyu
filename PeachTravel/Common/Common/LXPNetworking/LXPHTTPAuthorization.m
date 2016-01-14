//
//  LXPHTTPAuthorization.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/7/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "LXPHTTPAuthorization.h"
#import "QiniuSDK.h"
#include <CommonCrypto/CommonCrypto.h>
#import "NSString+UrlEncodeing.h"
#import "NSString+Base64.h"

@implementation LXPHTTPAuthorization

+ (NSString *)authorizationSignatureWithToken:(NSString *)token signatureMessage:(NSString *)signatureMessage
{
    const char *cKey  = [token cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [signatureMessage cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    NSString *retString = [HMAC base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];

    return retString;
}

+ (NSString *)signatureMessageWithURI:(NSString *)uri Date:(NSString *)date LxpId:(NSInteger)lxpId Query:(NSDictionary *)qureyDic Body:(NSDictionary *)bodyDic
{
    NSMutableString *retString = [[NSMutableString alloc] init];
    [retString appendFormat:@"URI=%@", uri];

    NSMutableString *headerString = [[NSMutableString alloc] init];
    [headerString appendFormat:@"date="];
    
    [headerString appendString:[[date urlEncodeUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"%20" withString:@"+"]];
    
    [headerString appendFormat:@"&x-lvxingpai-id=%ld", lxpId];
    [retString appendFormat:@",Headers=%@", headerString];
    
    if (qureyDic) {
        
        NSArray *allKeys = [qureyDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
        NSMutableString *queryString = [[NSMutableString alloc] init];
        for (NSString *key in allKeys) {
            NSString *value = [qureyDic objectForKey:key];
            if (![key isEqualToString:[allKeys lastObject]]) {
                if ([value isKindOfClass:[NSString class]]) {
                    [queryString appendFormat:@"%@=%@&", key, [[value urlEncodeUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"%20" withString:@"+"]];
                } else {
                    [queryString appendFormat:@"%@=%@&", key, value];
                }
            } else {
                if ([value isKindOfClass:[NSString class]]) {
                    [queryString appendFormat:@"%@=%@", key, [[value urlEncodeUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"%20" withString:@"+"]];
                } else {
                    [queryString appendFormat:@"%@=%@", key, value];
                }
            }
        }
        [retString appendFormat:@",QueryString=%@", queryString];
    }
    
    if (bodyDic) {
        NSString *jsonString = [self convertJsonObject2Json:bodyDic];
        
        NSData *data = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *bodyString = [NSString base64StringFromData:data length:[jsonString lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];

//        NSString *bodyString = [QNUrlSafeBase64 encodeString:jsonString];
        [retString appendFormat:@",Body=%@", bodyString];
    }
    
    NSLog(@"signature%@", retString);
    
    return retString;
}

+ (NSString *)convertJsonObject2Json:(id)object
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:0 error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end
