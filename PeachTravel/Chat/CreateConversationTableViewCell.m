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
    _selectImageView.layer.cornerRadius = 10;
    _selectImageView.clipsToBounds = YES;
    _avatarImageView.layer.cornerRadius = 20.0;
    _avatarImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setCheckStatus:(CheckStatus)checkStatus
{
    _checkStatus = checkStatus;
    switch (_checkStatus) {
        case unChecked:
            _selectImageView.backgroundColor = [UIColor greenColor];
            break;
            
        case checked:
            _selectImageView.backgroundColor = [UIColor redColor];

            break;
            
        case disable:
            _selectImageView.backgroundColor = [UIColor grayColor];
            
            break;
            
        default:
            break;
    }
}

@end
