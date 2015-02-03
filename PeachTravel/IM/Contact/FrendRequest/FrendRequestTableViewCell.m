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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
