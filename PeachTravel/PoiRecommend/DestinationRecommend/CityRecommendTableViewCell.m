//
//  CityRecommendTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/5/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "CityRecommendTableViewCell.h"

@implementation CityRecommendTableViewCell

- (void)awakeFromNib {
    _goodsCountBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _goodsCountBtn.layer.borderWidth = 0.5;
    _headerImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setCityPoi:(CityPoi *)cityPoi
{
    _cityPoi = cityPoi;
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[_cityPoi.images firstObject].imageUrl] placeholderImage:nil];
    _zhNameLabel.text = _cityPoi.zhName;
    _enNameLabel.text = _cityPoi.enName;
    [_goodsCountBtn setTitle:[NSString stringWithFormat:@"%ld", _cityPoi.goodsCount] forState: UIControlStateNormal];
}

@end
