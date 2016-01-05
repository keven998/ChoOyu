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
    _headerImage.layer.cornerRadius = 17.5;
    _headerImage.contentMode = UIViewContentModeScaleAspectFill;
    _headerImage.clipsToBounds = YES;
    _nameLabel.textColor = COLOR_TEXT_I;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
