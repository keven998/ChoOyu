//
//  GoodsDetailSoldOutView.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/31/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsDetailSoldOutView.h"

@implementation GoodsDetailSoldOutView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self renderContentView];
    }
    return self;
}

- (void)renderContentView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_orderDetail_soldout"]];
    imageView.center = CGPointMake(self.frame.size.width/2, 10+imageView.bounds.size.height/2);
    [self addSubview:imageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height+imageView.frame.origin.y+20, self.frame.size.width, 20)];
    label.textColor = COLOR_TEXT_III;
    label.font = [UIFont systemFontOfSize:15.0];
    label.text = @"您查看的商品已经下架啦!";
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
}

@end
