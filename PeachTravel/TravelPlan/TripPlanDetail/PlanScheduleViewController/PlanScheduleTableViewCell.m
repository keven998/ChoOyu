//
//  PlanScheduleTableViewCell.m
//  PeachTravel
//
//  Created by Luo Yong on 15/6/12.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "PlanScheduleTableViewCell.h"

@implementation PlanScheduleTableViewCell

- (void)awakeFromNib {
    _headerImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
