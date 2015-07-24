//
//  FrendRequestTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/1.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "FrendRequestTableViewCell.h"

@implementation FrendRequestTableViewCell

- (void)awakeFromNib {
    _avatarImageView.layer.cornerRadius = 20.0;
    _avatarImageView.clipsToBounds = YES;
    
    [_requestBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [_requestBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    [_requestBtn setTitleColor:COLOR_DISABLE forState:UIControlStateDisabled];
    [_requestBtn setTitle:@"已添加" forState:UIControlStateDisabled];
    [_requestBtn setTitle:@"同意" forState:UIControlStateNormal];
    _requestBtn.layer.borderColor = APP_THEME_COLOR.CGColor;
    _requestBtn.layer.cornerRadius = 3.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
