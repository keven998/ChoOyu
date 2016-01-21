//
//  GoodsDetailCommonSectionHeaderView.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/20/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsDetailCommonSectionHeaderView.h"

@implementation GoodsDetailCommonSectionHeaderView

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
    self.backgroundColor = [UIColor whiteColor];
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5)];
    spaceView.backgroundColor = COLOR_LINE;
    [self addSubview:spaceView];

    _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 8, 24, 24)];
    [self addSubview:_headerImageView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_headerImageView.frame)+8, 0, self.bounds.size.width-70, self.bounds.size.height)];
    _titleLabel.textColor = COLOR_TEXT_I;
    _titleLabel.font = [UIFont systemFontOfSize:17.0];
    [self addSubview:_titleLabel];
    
    UIView *buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-2, self.bounds.size.width, 2)];
    buttomView.backgroundColor = APP_THEME_COLOR;
    [self addSubview:buttomView];
}

@end

