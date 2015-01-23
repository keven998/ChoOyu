//
//  UserOtherTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/15.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "UserOtherTableViewCell.h"

@implementation UserOtherTableViewCell

- (void)awakeFromNib {
    self.contentView.layer.borderWidth = 0.25;
    _cellTitle.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0];
    _cellDetail.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
    self.contentView.layer.borderColor = APP_DIVIDER_COLOR.CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
