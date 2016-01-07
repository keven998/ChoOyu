//
//  LXPNetworking.h
//  PeachTravel
//
//  Created by liangpengshuai on 1/7/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXPNetworking : NSObject

+ (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(nullable id)parameters
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


+ (nullable AFHTTPRequestOperation *)DELETE:(NSString *)URLString
                                 parameters:(nullable id)parameters
                                    success:(nullable void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                    failure:(nullable void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (nullable AFHTTPRequestOperation *)PATCH:(NSString *)URLString
                                parameters:(nullable id)parameters
                                   success:(nullable void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                   failure:(nullable void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

+ (nullable AFHTTPRequestOperation *)PUT:(NSString *)URLString
                              parameters:(nullable id)parameters
                                 success:(nullable void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                 failure:(nullable void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


+ (nullable AFHTTPRequestOperation *)POST:(NSString *)URLString
                               parameters:(nullable id)parameters
                                  success:(nullable void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                  failure:(nullable void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

NS_ASSUME_NONNULL_END

@end
