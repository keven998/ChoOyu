//
//  ForeignDestinationCollectionHeaderView.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/19/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "ForeignDestinationCollectionHeaderView.h"

@implementation ForeignDestinationCollectionHeaderView

- (void)awakeFromNib {
    _headerImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _headerImageView.layer.borderWidth = 0.5;
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
}

@end
