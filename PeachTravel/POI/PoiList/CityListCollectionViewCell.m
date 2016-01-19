//
//  CityListCollectionViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/2/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "CityListCollectionViewCell.h"

@implementation CityListCollectionViewCell

- (void)awakeFromNib {
    _headerImageView.clipsToBounds = YES;
}

- (void)setCityPoi:(CityPoi *)cityPoi
{
    _cityPoi = cityPoi;
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[_cityPoi.images firstObject].imageUrl] placeholderImage:nil];
    _zhNameLabel.text = _cityPoi.zhName;
    _enNameLabel.text = _cityPoi.enName;
    if (_cityPoi.goodsCount) {
        _sellerCountLabel.text = [NSString stringWithFormat:@"%ld", _cityPoi.goodsCount];
        _sellerCountLabel.hidden = NO;
        _countBgView.hidden = NO;
        _countImageView.hidden = NO;
        
    } else {
        _sellerCountLabel.hidden = YES;
        _countBgView.hidden = YES;
        _countImageView.hidden = YES;
    }
}

@end
