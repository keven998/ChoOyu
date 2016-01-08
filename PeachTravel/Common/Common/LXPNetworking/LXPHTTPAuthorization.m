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
    
    NSLog(@"headerString: %@", headerString);
    
    if (qureyDic) {
        NSMutableString *queryString = [[NSMutableString alloc] init];
        for (NSString *key in qureyDic.allKeys) {
            NSString *value = [qureyDic objectForKey:key];
            if (![key isEqualToString:[qureyDic.allKeys lastObject]]) {
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
        [retString appendFormat:@",QueryString=%@", headerString];
    }
    
    if (bodyDic) {
        NSString *jsonString = [self convertJsonObject2Json:bodyDic];
        NSString *bodyString = [QNUrlSafeBase64 encodeString:jsonString];
        [retString appendFormat:@",QueryString=%@", bodyString];

    }
    
    return retString;
}

+ (NSString *)convertJsonObject2Json:(id)object
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
@end
