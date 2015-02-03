//
//  RecommendCollectionViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RecommendCollectionViewCell.h"

@implementation RecommendCollectionViewCell

- (void)awakeFromNib {
    _titleLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    self.layer.cornerRadius = 1.0;
    self.clipsToBounds = YES;
    self.layer.borderColor = UIColorFromRGB(0xeeeeee).CGColor;
    self.layer.borderWidth = 1.0;
    
    _backGroundImage.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _backGroundImage.layer.borderWidth = 0.5;
    _backGroundImage.backgroundColor = APP_IMAGEVIEW_COLOR;
}

@end
