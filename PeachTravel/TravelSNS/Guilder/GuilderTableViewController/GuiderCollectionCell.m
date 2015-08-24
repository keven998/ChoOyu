//
//  GuiderCollectionCell.m
//  PeachTravel
//
//  Created by dapiao on 15/7/8.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "GuiderCollectionCell.h"

@implementation GuiderCollectionCell

- (void)awakeFromNib
{
    _backGroundView.layer.cornerRadius = 4.0;
    _backGroundView.clipsToBounds = YES;
    
    [_costellationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_addressBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _headerImageView.layer.cornerRadius = CGRectGetWidth(_headerImageView.frame)/2.0;
}

@end
