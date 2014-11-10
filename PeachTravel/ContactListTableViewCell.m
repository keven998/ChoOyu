//
//  ContactListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/8.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ContactListTableViewCell.h"

@implementation ContactListTableViewCell

- (void)awakeFromNib {
    _avatarImageView.clipsToBounds = YES;
    _avatarImageView.layer.cornerRadius = 22.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
