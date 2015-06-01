//
//  SearchDestinationTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SearchDestinationTableViewCell.h"

@implementation SearchDestinationTableViewCell

- (void)awakeFromNib {
    _statusBtn.layer.cornerRadius = 2.0;
    _statusBtn.clipsToBounds = YES;
    [_statusBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    [_statusBtn setBackgroundImage:[ConvertMethods createImageWithColor:UIColorFromRGB(0xa8a8a8)] forState:UIControlStateSelected];
    [_statusBtn setTitle:@"添加" forState:UIControlStateNormal];
    [_statusBtn setTitle:@"已添加" forState:UIControlStateSelected];
    [_statusBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_statusBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
