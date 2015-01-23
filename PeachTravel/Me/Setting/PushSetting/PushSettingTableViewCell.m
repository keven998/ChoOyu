//
//  PushSettingTableViewCell.m
//  PeachTravel
//
//  Created by Luo Yong on 14/11/29.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "PushSettingTableViewCell.h"

@implementation PushSettingTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.contentView.layer.borderWidth = 0.25f;
    self.contentView.layer.borderColor = APP_DIVIDER_COLOR.CGColor;
    _titleView.font = [UIFont fontWithName:@"MicrosoftYaHei" size:15.0];
    [_switchButton setOnTintColor:APP_THEME_COLOR];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
