//
//  OptionOfFASKTableViewCell.m
//  PeachTravel
//
//  Created by Luo Yong on 14/11/19.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "OptionOfFASKTableViewCell.h"

@implementation OptionOfFASKTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = APP_PAGE_COLOR;
    
    _cellFrameBg.layer.cornerRadius = 2.0;
    _cellFrameBg.layer.shadowColor = APP_PAGE_COLOR.CGColor;
    _cellFrameBg.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    _cellFrameBg.layer.shadowOpacity = 1.0;
    _cellFrameBg.layer.shadowRadius = 1.0;
    
    _notifyFlag.layer.cornerRadius = 5.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    self.selectedBackgroundView.frame = CGRectMake(0, 0, self.frame.size.width, 44.0);
}

@end
