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
//    [_contentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_contentBtn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
//    [_contentBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
//    [_contentBtn setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xcccccc)] forState:UIControlStateSelected];
    [_contentBtn setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xcccccc)] forState:UIControlStateNormal];
    _contentBtn.layer.cornerRadius = 2.0;
    _contentBtn.clipsToBounds = YES;
    _contentBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _contentBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 80);
    _contentBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:13.0];
    _contentBtn.userInteractionEnabled = NO;
    
//    _cellAccessoryView.contentMode = UIViewContentModeCenter;
    _cellAccessoryView.hidden = YES;
}

@end
