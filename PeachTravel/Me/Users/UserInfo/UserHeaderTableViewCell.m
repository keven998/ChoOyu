//
//  UserHeaderTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/14.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "UserHeaderTableViewCell.h"

@implementation UserHeaderTableViewCell

- (void)awakeFromNib
{
    _userPhoto.layer.cornerRadius = 20.5;
    _userPhoto.clipsToBounds = YES;
    _cellLabel.font = [UIFont systemFontOfSize:14.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
