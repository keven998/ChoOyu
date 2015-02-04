//
//  ChatRecordListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/1/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "ChatRecordListTableViewCell.h"

@implementation ChatRecordListTableViewCell

- (void)awakeFromNib {
    _headerImageView.layer.cornerRadius = 20;
    _headerImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end