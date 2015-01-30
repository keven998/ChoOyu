//
//  OptionOfFASKTableViewCell.m
//  PeachTravel
//
//  Created by Luo Yong on 14/11/19.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "OptionOfFASKTableViewCell.h"

@implementation OptionOfFASKTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = APP_PAGE_COLOR;
    _titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:14.0];
    _cellFrameBg.layer.cornerRadius = 2.0;
    _cellFrameBg.layer.shadowColor = APP_DIVIDER_COLOR.CGColor;
    _cellFrameBg.layer.shadowOffset = CGSizeMake(0.0, 0.5);
    _cellFrameBg.layer.shadowOpacity = 1.0;
    _cellFrameBg.layer.shadowRadius = 0.5;
    _requestNoti.layer.cornerRadius = 7.5;
    _requestNoti.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    self.selectedBackgroundView.frame = CGRectMake(0, 0, self.frame.size.width, 44.0);
}

- (void)setNumberOfUnreadFrendRequest:(NSUInteger)numberOfUnreadFrendRequest
{
    _numberOfUnreadFrendRequest = numberOfUnreadFrendRequest;
    if (_numberOfUnreadFrendRequest == 0) {
        _requestNoti.hidden = YES;
    } else if (_numberOfUnreadFrendRequest > 0) {
        _requestNoti.hidden = NO;
        _requestNoti.text = [NSString stringWithFormat:@"%ld", (unsigned long)_numberOfUnreadFrendRequest];
    }
}

@end
