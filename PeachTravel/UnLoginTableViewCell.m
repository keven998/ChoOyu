//
//  UnLoginTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/13.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "UnLoginTableViewCell.h"
#import "LoginViewController.h"

@implementation UnLoginTableViewCell

- (void)awakeFromNib {
    
    _avatarPlaceholder.layer.cornerRadius = 31.0;
    [_loginBtn setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateHighlighted];
    [_registerBtn setTitleColor:UIColorFromRGB(0x000000) forState:UIControlStateHighlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
