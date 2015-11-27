//
//  GoodsRecommendCollectionViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/6/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsRecommendCollectionViewCell.h"

@implementation GoodsRecommendCollectionViewCell

- (void)awakeFromNib {
    _headerImageView.layer.cornerRadius = 3.0;
    _headerImageView.clipsToBounds = YES;
}

@end
