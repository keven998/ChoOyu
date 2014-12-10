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
}

@end
