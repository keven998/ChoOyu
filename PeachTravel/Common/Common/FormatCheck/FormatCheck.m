//
//  FormatCheck.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/1/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "FormatCheck.h"

@implementation FormatCheck

+ (BOOL)isMobileFormat:(NSString *)mobile
{
    NSString * regex0 = @"^1\\d{10}$";
    
    NSPredicate *pred0 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex0];
    if (![pred0 evaluateWithObject: mobile]) {
        return NO;
    }
    return YES;
}



@end
