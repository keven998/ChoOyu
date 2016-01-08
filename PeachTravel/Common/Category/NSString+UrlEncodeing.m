//
//  NSString+UrlEncodeing.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/8/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "NSString+UrlEncodeing.h"

@implementation NSString (UrlEncodeing)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                               (CFStringRef)self,
                                                               NULL,
                                                               (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                               CFStringConvertNSStringEncodingToEncoding(encoding)));
}

@end
