//
//  CWContainView.m
//  PeachTravel
//
//  Created by 王聪 on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "CWContainView.h"

@implementation CWContainView

- (void)drawRect:(CGRect)rect {
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    // 1.获得上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 2.画矩形
    CGContextAddRect(ctx, CGRectMake(0, 15, width, height));
    
    CGContextMoveToPoint(ctx, width * 0.5, 0);
    CGContextAddLineToPoint(ctx, width * 0.5 - 10, 15);
    CGContextAddLineToPoint(ctx, width * 0.5 + 10, 15);
    CGContextClosePath(ctx);
    
    // set : 同时设置为实心和空心颜色
    // setStroke : 设置空心颜色
    // setFill : 设置实心颜色
    [[UIColor blackColor] set];
    
    //    CGContextSetRGBFillColor(ctx, 0, 0, 1, 1);
    
    // 3.绘制图形
    CGContextFillPath(ctx);
}


@end
