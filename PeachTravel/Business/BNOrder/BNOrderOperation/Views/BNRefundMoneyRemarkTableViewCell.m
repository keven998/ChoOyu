//
//  BNRefundMoneyRemarkTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/11/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

#import "BNRefundMoneyRemarkTableViewCell.h"

@implementation BNRefundMoneyRemarkTableViewCell

- (void)awakeFromNib {
    _remarkTextView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _remarkTextView.layer.borderWidth = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
