//
//  ContactListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/8.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "ContactListTableViewCell.h"

@implementation ContactListTableViewCell

- (void)awakeFromNib {
    _avatarImageView.clipsToBounds = YES;
    _avatarImageView.layer.cornerRadius = 21.0;
    
    self.backgroundColor = APP_PAGE_COLOR;
    _frameBg.layer.borderColor = UIColorFromRGB(0xeeeeee).CGColor;
    _frameBg.layer.borderWidth = 0.5;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)layoutSubviews {
    self.selectedBackgroundView.frame = CGRectMake(10.0, 0, self.frame.size.width - 20.0, self.frame.size.height);
}

@end
