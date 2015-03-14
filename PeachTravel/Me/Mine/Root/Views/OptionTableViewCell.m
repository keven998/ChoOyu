//
//  OptionTableViewCell.m
//  PeachTravel
//
//  Created by Luo Yong on 14/11/18.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "OptionTableViewCell.h"

@implementation OptionTableViewCell

- (void)awakeFromNib {
    _titleView.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0];

    self.contentView.layer.borderColor = APP_DIVIDER_COLOR.CGColor;
    self.contentView.layer.borderWidth = 0.25;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)layoutSubviews {
//    self.selectedBackgroundView.frame = CGRectMake(10.0, 0, self.frame.size.width - 20.0, 44.0);
//}

@end
