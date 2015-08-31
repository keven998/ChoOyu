//
//  GuiderProfileImageView.m
//  PeachTravel
//
//  Created by 王聪 on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderProfileImageView.h"

@interface GuiderProfileImageView ()

@end

@implementation GuiderProfileImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViewWithFrame:frame];
    }
    return self;
}

- (void)setupViewWithFrame:(CGRect)frame {
    // 添加imageView
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView = imageView;
    [self addSubview:imageView];
    
    // 添加label
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentRight;
    label.text = @"旅行派达人咨询师 LEVEL-3";
    label.textColor = UIColorFromRGB(0xFFFFFF);
    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    self.titleLab = label;
    [self addSubview:label];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    self.titleLab.frame = CGRectMake(0, kWindowWidth - 35, kWindowWidth - 10, 25);
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    NSLog(@"%@",NSStringFromCGRect(self.frame));
    
}

@end
