//
//  AddHotelTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/27/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "AddHotelTableViewCell.h"

@implementation AddHotelTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setTripPoi:(TripPoi *)tripPoi
{
    _tripPoi = tripPoi;
    [_titleBtn setTitle:_tripPoi.zhName forState:UIControlStateNormal];
    _priceLabel.text = _tripPoi.priceDesc;
    [_teltephoneBtn setTitle:_tripPoi.telephone forState:UIControlStateNormal];
    [_addressBtn setTitle:_tripPoi.address forState:UIControlStateNormal];
    TaoziImage *image = [_tripPoi.images firstObject];
    [_pictureImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    
}
@end
