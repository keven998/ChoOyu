//
//  ChatGroupCell.m
//  PeachTravel
//
//  Created by dapiao on 15/5/21.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "ChatGroupCell.h"

@implementation ChatGroupCell

- (void)awakeFromNib {
    // Initialization code
    _headerImage.layer.cornerRadius = 20;
    _headerImage.contentMode = UIViewContentModeScaleAspectFill;
    _headerImage.clipsToBounds = YES;
    _nameLabel.textColor = UIColorFromRGB(0x969696);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
