//
//  HotDestinationCollectionViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "HotDestinationCollectionViewCell.h"

@implementation HotDestinationCollectionViewCell

- (void)awakeFromNib {
    self.layer.cornerRadius = 5.0;
    _cellTitleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0];
    _cellDescLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:8.0];
    _cellImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _cellImageView.layer.borderWidth = 0.5;
    _cellImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
}

@end
