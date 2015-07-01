//
//  SpotDetailCell.m
//  PeachTravel
//
//  Created by dapiao on 15/7/1.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "SpotDetailCell.h"

@implementation SpotDetailCell

- (void)awakeFromNib {
    // Initialization code
    self.categoryLabel.font = [UIFont systemFontOfSize:14];
    self.categoryLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    self.infomationLabel.font = [UIFont systemFontOfSize:18];
    self.infomationLabel.textColor = TEXT_COLOR_TITLE;
    self.image.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
