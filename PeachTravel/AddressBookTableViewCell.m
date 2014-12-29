//
//  AddressBookTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/29/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "AddressBookTableViewCell.h"

@implementation AddressBookTableViewCell

- (void)awakeFromNib {
    self.backgroundColor = APP_PAGE_COLOR;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
