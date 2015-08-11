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
    self.categoryLabel.font = [UIFont systemFontOfSize:13];
    self.categoryLabel.textColor = COLOR_TEXT_III;
    self.infomationLabel.font = [UIFont systemFontOfSize:16];
    self.infomationLabel.textColor = COLOR_TEXT_I;
    self.noTelLabel.hidden = YES;
    
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(18, 66 * kWindowHeight/736 - 0.6, CGRectGetWidth(self.bounds) - 18, 0.6)];
    divider.backgroundColor = COLOR_LINE;
    divider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:divider];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
