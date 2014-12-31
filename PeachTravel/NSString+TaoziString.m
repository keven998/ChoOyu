//
//  NSString+TaoziString.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "NSString+TaoziString.h"

@implementation NSString (TaoziString)

- (BOOL)isBlankString
{
    if (self == nil || self == NULL) {
        return YES;
    }
    if ([self isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([self respondsToSelector:@selector(stringByTrimmingCharactersInSet:)]) {
        if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
            return YES;
        }
    }
    
    return NO;
}

- (NSAttributedString *)stringByAddLineSpacingAndTextColor:(UIColor *)textColor
{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4.0;
    [attributeString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributeString.length)];
    [attributeString addAttributes:@{NSForegroundColorAttributeName:textColor} range:NSMakeRange(0, attributeString.length)];
    return attributeString;
}


@end
