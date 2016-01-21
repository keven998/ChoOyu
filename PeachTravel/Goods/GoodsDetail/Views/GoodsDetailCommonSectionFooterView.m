//
//  GoodsDetailCommonSectionFooterView.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/20/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "GoodsDetailCommonSectionFooterView.h"

@implementation GoodsDetailCommonSectionFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 50)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:bgView];
        
        UIImageView *dashedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, frame.size.width-40, 0.5)];
        dashedImageView.image = [UIImage imageNamed:@"icon_goodsDetail_dashed"];
        [self addSubview:dashedImageView];
        
        _showAllButton = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width-100)/2, 11, 100, 28)];
        _showAllButton.layer.borderColor = APP_THEME_COLOR.CGColor;
        _showAllButton.layer.borderWidth = 0.5;
        _showAllButton.layer.cornerRadius = 3.0;
        [_showAllButton setTitle:@"查看全部" forState:UIControlStateNormal];
        [_showAllButton setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        _showAllButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [self addSubview:_showAllButton];
        
        UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 50-0.5, frame.size.width, 0.5)];
        spaceView.backgroundColor = COLOR_LINE;
        [self addSubview:spaceView];
        
        UIView *spaceButtomView = [[UIView alloc] initWithFrame:CGRectMake(0, 50-0.5, frame.size.width, 0.5)];
        spaceButtomView.backgroundColor = COLOR_LINE;
        [self addSubview:spaceButtomView];
    }
    return self;
}

@end
