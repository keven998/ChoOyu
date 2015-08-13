//
//  SearchDestinationHistoryCollectionReusableView.m
//  PeachTravel
//
//  Created by liangpengshuai on 8/13/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "SearchDestinationHistoryCollectionReusableView.h"

@implementation SearchDestinationHistoryCollectionReusableView

- (void)awakeFromNib {
    _titleLabel.textColor = COLOR_TEXT_II;
    [_actionButton setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
}

@end
