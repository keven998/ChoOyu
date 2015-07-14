//
//  GuiderCell.m
//  PeachTravel
//
//  Created by dapiao on 15/7/8.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "GuiderCell.h"

@implementation GuiderCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = APP_PAGE_COLOR;
    self.contentView.layer.borderWidth = 0.5;
    self.contentView.layer.borderColor = COLOR_LINE.CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
