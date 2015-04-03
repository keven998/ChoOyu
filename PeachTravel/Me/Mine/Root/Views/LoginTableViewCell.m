//
//  LoginTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/7.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "LoginTableViewCell.h"

@implementation LoginTableViewCell

- (void)awakeFromNib {
    _userName.font = [UIFont systemFontOfSize:15.0];
    _userSign.font = [UIFont systemFontOfSize:12.0];
    _userPhoto.layer.cornerRadius = 31.0;
    _userPhoto.clipsToBounds = YES;
    _userGender.layer.cornerRadius = 8.5;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
