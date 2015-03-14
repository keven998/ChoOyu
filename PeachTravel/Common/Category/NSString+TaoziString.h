//
//  NSString+TaoziString.h
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TaoziString)

- (BOOL)isBlankString;

- (NSAttributedString *)stringByAddLineSpacingAndTextColor:(UIColor *)textColor;

@end
