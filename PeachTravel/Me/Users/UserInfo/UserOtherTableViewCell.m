//
//  UserOtherTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/15.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "UserOtherTableViewCell.h"

@implementation UserOtherTableViewCell

- (void)awakeFromNib {
    _cellTitle.font = [UIFont systemFontOfSize:14.0];
    _cellDetail.font = [UIFont systemFontOfSize:13.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
