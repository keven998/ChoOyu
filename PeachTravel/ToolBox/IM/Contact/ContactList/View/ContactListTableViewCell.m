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
//    _frameBg.layer.borderColor = UIColorFromRGB(0xeeeeee).CGColor;
//    _frameBg.layer.borderWidth = 0.5;
    _frameBg.layer.cornerRadius = 2.0;
//    _frameBg.layer.shadowColor = APP_PAGE_COLOR.CGColor;
//    _frameBg.layer.shadowOffset = CGSizeMake(0.0, 1.0);
//    _frameBg.layer.shadowOpacity = 1.0;
//    _frameBg.layer.shadowRadius = 1.0;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)layoutSubviews {
    self.selectedBackgroundView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}

@end
