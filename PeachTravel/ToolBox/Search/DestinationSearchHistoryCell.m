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
    _titleLabel.layer.cornerRadius = 2.0;
    _titleLabel.backgroundColor = COLOR_TEXT_II;
    _titleLabel.clipsToBounds = YES;
}

@end
