//
//  FormatCheck.h
//  PeachTravel
//
//  Created by liangpengshuai on 9/1/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormatCheck : NSObject

/**
 *  是否是手机号
 *
 *  @param mobile
 *
 *  @return 
 */
+ (BOOL)isMobileFormat:(NSString *)mobile;


@end
