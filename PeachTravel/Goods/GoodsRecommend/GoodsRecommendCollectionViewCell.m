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
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:@"http://images.taozilvxing.com/28c2d1ef35c12100e99fecddb63c436a?imageView2/2/w/1200"] placeholderImage:nil];}

@end
