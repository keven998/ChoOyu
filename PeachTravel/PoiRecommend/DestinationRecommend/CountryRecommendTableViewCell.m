//
//  CountryRecommendTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/5/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "CountryRecommendTableViewCell.h"

@implementation CountryRecommendTableViewCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setCountryModel:(CountryModel *)countryModel
{
    _countryModel = countryModel;
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[_countryModel.images firstObject].imageUrl] placeholderImage:nil];
    _zhNameLabel.text = _countryModel.zhName;
    _enNameLabel.text = _countryModel.enName;
}

@end
