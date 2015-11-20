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
}

- (void)setCityPoi:(CityPoi *)cityPoi
{
    _cityPoi = cityPoi;
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:[_cityPoi.images firstObject].imageUrl] placeholderImage:nil];
    _zhNameLabel.text = _cityPoi.zhName;
    _enNameLabel.text = _cityPoi.enName;
    
}
@end
