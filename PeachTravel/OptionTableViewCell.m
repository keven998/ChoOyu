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
    // Initialization code
    
    self.backgroundColor = APP_PAGE_COLOR;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = UIColorFromRGB(0xdddddd);
    self.selectedBackgroundView = view;
    
    _bgFrame.layer.borderColor = UIColorFromRGB(0xdddddd).CGColor;
    _bgFrame.layer.borderWidth = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    self.selectedBackgroundView.frame = CGRectMake(10.0, 0, self.frame.size.width - 20.0, 44.0);
}

@end
