//
//  MakeOrderSelectDateTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/9/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "MakeOrderSelectDateTableViewCell.h"

@implementation MakeOrderSelectDateTableViewCell

- (void)awakeFromNib {
    [_choseDateBtn setBackgroundColor:APP_PAGE_COLOR];
    _choseDateBtn.layer.cornerRadius = 2.0;
    _choseDateBtn.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _choseDateBtn.layer.borderWidth = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
