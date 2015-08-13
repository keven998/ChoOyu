//
//  DestinationSearchHistoryCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 8/12/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "DestinationSearchHistoryCell.h"

@implementation DestinationSearchHistoryCell

- (void)awakeFromNib {
    _titleLabel.layer.cornerRadius = 5.0;
    _titleLabel.layer.borderColor = APP_THEME_COLOR.CGColor;
    _titleLabel.textColor = APP_THEME_COLOR;
    _titleLabel.layer.borderWidth = 1.0;
    _titleLabel.clipsToBounds = YES;
}

@end
