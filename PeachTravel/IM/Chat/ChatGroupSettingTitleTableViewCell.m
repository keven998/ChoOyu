//
//  ChatGroupSettingTitleTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 1/14/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "ChatGroupSettingTitleTableViewCell.h"

@implementation ChatGroupSettingTitleTableViewCell

- (void)awakeFromNib {
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
