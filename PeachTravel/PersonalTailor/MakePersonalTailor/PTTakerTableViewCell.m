//
//  PTTakerTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 4/22/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "PTTakerTableViewCell.h"

@implementation PTTakerTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _avatarImageView.clipsToBounds = YES;
    _avatarImageView.layer.cornerRadius = 22.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

@end
