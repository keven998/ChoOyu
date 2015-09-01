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
//    CGFloat height = self.frame.size.height;
    
    CGRect newRect = rect;
    newRect.origin.y = rect.origin.y + 15;
    newRect.size.height = rect.size.height - 15;
    // 1.获得上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 2.画矩形
//    CGContextAddRect(ctx, CGRectMake(0, 15, width, height));
    
    // 画圆角矩形
    CGFloat radius = 5.0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1);
    CGFloat minx = CGRectGetMinX(newRect), midx = CGRectGetMidX(newRect), maxx = CGRectGetMaxX(newRect);
    CGFloat miny = CGRectGetMinY(newRect), midy = CGRectGetMidY(newRect), maxy = CGRectGetMaxY(newRect);
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFill);
    
    
    CGContextMoveToPoint(ctx, width * 0.5, 10);
    CGContextAddLineToPoint(ctx, width * 0.5 - 5, 15);
    CGContextAddLineToPoint(ctx, width * 0.5 + 5, 15);
    CGContextClosePath(ctx);
    
    // set : 同时设置为实心和空心颜色
    // setStroke : 设置空心颜色
    // setFill : 设置实心颜色
    [[[UIColor blackColor] colorWithAlphaComponent:0.8] set];
    
    //    CGContextSetRGBFillColor(ctx, 0, 0, 1, 1);
    
    // 3.绘制图形
    CGContextFillPath(ctx);
}


@end
