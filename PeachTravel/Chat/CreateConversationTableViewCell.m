//
//  CreateConversationTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/4.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "CreateConversationTableViewCell.h"

@implementation CreateConversationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.avatarImageView.layer.cornerRadius = 20.0;
    self.avatarImageView.clipsToBounds = YES;
    
    _selectView.strokeColor = UIColorFromRGB(0xdddddd);
    _selectView.strokeWidth = 1.0;
    _selectView.uncheckedColor = [UIColor whiteColor];
    _selectView.radius = 12.0;
    _selectView.checkColor = [UIColor whiteColor];
    _selectView.tintColor = [UIColor yellowColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
