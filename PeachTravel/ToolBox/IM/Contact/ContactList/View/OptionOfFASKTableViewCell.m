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
    
    _cellFrameBg.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
    _cellFrameBg.layer.borderWidth = 0.5;
    
    _notifyFlag.layer.cornerRadius = 5.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    self.selectedBackgroundView.frame = CGRectMake(10.0, 0, self.frame.size.width - 20.0, 44.0);
}

@end
