//
//  UIImage+resized.m
//  PeachTravel
//
//  Created by dapiao on 15/5/26.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "UIImage+resized.h"

@implementation UIImage (resized)
+ (UIImage *)resizedImageWithName:(NSString *)name
{
    UIImage *image = [self imageNamed:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}
@end
