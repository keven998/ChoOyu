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
//    _titleView.font = [UIFont systemFontOfSize:14.0];

//    self.contentView.layer.borderColor = APP_DIVIDER_COLOR.CGColor;
//    self.contentView.layer.borderWidth = 0.25;
    
//    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 0.5)];
    
    _titleView.textColor = COLOR_TEXT_II;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 70*kWindowHeight/736 - 0.6, CGRectGetWidth(self.bounds) + 30, 0.6)];
    line.backgroundColor = COLOR_LINE;
    line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:line];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
