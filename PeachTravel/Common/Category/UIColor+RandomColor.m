//
//  UIColor+RandomColor.m
//  PeachTravel
//
//  Created by 冯宁 on 15/9/17.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "UIColor+RandomColor.h"

@implementation UIColor (RandomColor)

+ (UIColor*)randomColor{
    return [[UIColor alloc] initWithRed:arc4random_uniform(255) / 255.0 green:arc4random_uniform(255) / 255.0 blue:arc4random_uniform(255) / 255.0 alpha:1.0];
}

@end
