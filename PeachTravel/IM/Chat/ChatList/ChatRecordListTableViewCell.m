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
    
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(15, 63.4, CGRectGetWidth(self.bounds), 0.6)];
    divider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    divider.backgroundColor = COLOR_LINE;
    [self.contentView addSubview:divider];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
