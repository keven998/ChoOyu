//
//  SearchResultTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/9/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SearchResultTableViewCell.h"

@implementation SearchResultTableViewCell

- (void)awakeFromNib {
    self.headerImageView.layer.cornerRadius = 2.0;
    self.headerImageView.clipsToBounds = YES;
    
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _sendBtn.layer.cornerRadius = 2.0;
    
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(15.0, CGRectGetHeight(self.frame) - 0.6, CGRectGetWidth(self.frame), 0.6)];
    divider.backgroundColor = COLOR_LINE;
    divider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.contentView addSubview:divider];
}

- (void)setIsCanSend:(BOOL)isCanSend
{
    _isCanSend = isCanSend;
    if (_isCanSend) {
        _sendBtn.hidden = NO;
    } else {
        _sendBtn.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
