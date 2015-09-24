//
//  ExpertTourView.m
//  PeachTravel
//
//  Created by 王聪 on 9/7/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "ExpertTourView.h"

@implementation ExpertTourView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupMainView];
    }
    return self;
}

#pragma mark - 初始化界面
- (void)setupMainView
{
    // 1.图片
    UIImageView *iconImage = [[UIImageView alloc] init];
    iconImage.contentMode = UIViewContentModeScaleAspectFit;
    self.iconImage = iconImage;
    [self addSubview:iconImage];
    
    // 2.标题
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.font = [UIFont boldSystemFontOfSize:10.0];
    titleLab.textColor = UIColorFromRGB(0x323232);
    titleLab.numberOfLines = 0;
    titleLab.textAlignment = NSTextAlignmentCenter;
    self.titleLab = titleLab;
    [self addSubview:titleLab];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat selfW = self.frame.size.width;
    
    CGFloat iconImageW = 43;
    CGFloat iconImageH = 43;
    CGFloat iconImageX = (selfW-iconImageW)*0.5;
    CGFloat iconImageY = 30;
    self.iconImage.frame = CGRectMake(iconImageX, iconImageY, iconImageW, iconImageH);
    
    CGFloat titleLabW = selfW;
    CGFloat titleLabH = 24;
    CGFloat titleLabX = 0;
    CGFloat titleLabY = CGRectGetMaxY(self.iconImage.frame)+5;
    self.titleLab.frame = CGRectMake(titleLabX, titleLabY, titleLabW, titleLabH);
}

@end
