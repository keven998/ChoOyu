//
//  UserOtherTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/15.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "UserOtherTableViewCell.h"

@implementation UserOtherTableViewCell

- (void)awakeFromNib
{
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.cellTitle.font = [UIFont systemFontOfSize:16];
    self.cellTitle.textColor = COLOR_TEXT_I;
    
    self.cellDetail.font = [UIFont systemFontOfSize:15];
    self.cellDetail.textColor = COLOR_TEXT_II;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
