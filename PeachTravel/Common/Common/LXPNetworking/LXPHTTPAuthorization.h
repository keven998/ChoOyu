//
//  LXPHTTPAuthorization.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/7/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LXPHTTPAuthorization : NSObject

/**
 *  请求签名 Signature = url_safe_base64_encode(HMAC(token, SignatureMessage))
 *
 *  @param token            登录时候获取的 token
 *  @param signatureMessage 生成签名的字符串
 *
 *  @return
 */
+ (NSString *)authorizationSignatureWithToken:(NSString *)token signatureMessage:(NSString *)signatureMessage;

/**
 *  生成签名字符串
 *
 *  @param uri         请求的canonical uri，比如：/app/marketplace/commodities
 *  @param date        请求 header 参数里的 date
 *  @param lxpId       请求 header 参数里的 用户 ID
 *  @param Query
 *  @param Body
 *
 *  @return 用于生成签名的字符串
 */
+ (NSString *)signatureMessageWithURI:(NSString *)uri Date:(NSString *)date LxpId:(NSInteger)lxpId Query:(NSDictionary *)qureyDic Body:(NSDictionary *)bodyDic;

@end
