//
//  ChatGroupSettingCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/7/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "ChatGroupSettingCell.h"

@implementation ChatGroupSettingCell

- (void)awakeFromNib {
    _switchBtn.onTintColor = APP_THEME_COLOR;
    _titleLabel.textColor = COLOR_TEXT_I;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
