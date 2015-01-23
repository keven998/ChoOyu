//
//  AccountManagerTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/10.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "AccountManagerTableViewCell.h"

@implementation AccountManagerTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.contentView.layer.borderColor = APP_DIVIDER_COLOR.CGColor;
    self.contentView.layer.borderWidth = 0.25;
    _snsTitle.font = [UIFont fontWithName:@"MicrosoftYaHei" size:16.0];
    [_snsSwitch setOnTintColor:APP_THEME_COLOR];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
