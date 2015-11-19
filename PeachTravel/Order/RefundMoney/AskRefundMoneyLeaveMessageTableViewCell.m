//
//  AskRefundMoneyLeaveMessageTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/19/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "AskRefundMoneyLeaveMessageTableViewCell.h"

@implementation AskRefundMoneyLeaveMessageTableViewCell

- (void)awakeFromNib {
    _contentTextView.layer.borderColor = COLOR_LINE.CGColor;
    _contentTextView.layer.borderWidth = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
