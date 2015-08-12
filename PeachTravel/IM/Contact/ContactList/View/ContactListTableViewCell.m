//
//  ContactListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/8.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ContactListTableViewCell.h"

@implementation ContactListTableViewCell

+ (id)contactListCellWithTableView:(UITableView *)tableView
{
    static NSString * ID = @"contactCell";
    
    UINib * nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    
    [tableView registerNib:nib forCellReuseIdentifier:ID];
    
    return [tableView dequeueReusableCellWithIdentifier:ID];
}

- (void)awakeFromNib {
    _avatarImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _avatarImageView.layer.cornerRadius = 20;
    _avatarImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
