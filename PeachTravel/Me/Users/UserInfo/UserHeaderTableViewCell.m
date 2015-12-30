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
    _userPhoto.layer.cornerRadius = 10;
    _userPhoto.clipsToBounds = YES;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

@end
