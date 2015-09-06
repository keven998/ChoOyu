//
//  MineProfileTitleView.m
//  PeachTravel
//
//  Created by 王聪 on 15/9/6.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "MineProfileTitleView.h"

@implementation MineProfileTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupMainView];
    }
    return self;
}

#pragma mark - 主视图
- (void)setupMainView
{
    // 1.标题
    UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    titleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.titleBtn = titleBtn;
    [self addSubview:titleBtn];
    
    // 2.图片数量
    UILabel *countLab = [[UILabel alloc] init];
    countLab.textAlignment = NSTextAlignmentRight;
    countLab.textColor = TEXT_COLOR_TITLE;
    self.countLab = countLab;
    [self addSubview:countLab];
    
    // 3.下划线阴影
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor grayColor];
    line.alpha = 0.3;
    self.line = line;
    [self addSubview:line];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat selfH = self.frame.size.height;
    
    self.titleBtn.frame = CGRectMake(10, 0, 300, selfH);
    self.countLab.frame = CGRectMake(kWindowWidth-200-10, 0, 200, selfH);
    self.line.frame = CGRectMake(0, selfH - 1, kWindowWidth, 1);
}

@end
