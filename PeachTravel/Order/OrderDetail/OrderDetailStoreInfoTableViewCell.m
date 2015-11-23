//
//  OrderDetailStoreInfoTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "OrderDetailStoreInfoTableViewCell.h"

@implementation OrderDetailStoreInfoTableViewCell

- (void)awakeFromNib {
    [_chatBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_PAGE_COLOR] forState:UIControlStateNormal];
    [_chatBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    _chatBtn.layer.borderColor = COLOR_LINE.CGColor;
    _chatBtn.layer.borderWidth = 0.5;
    _chatBtn.layer.cornerRadius = 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
