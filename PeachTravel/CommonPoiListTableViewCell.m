//
//  RestaurantListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CommonPoiListTableViewCell.h"
#import "EDStarRating.h"

@interface CommonPoiListTableViewCell ()

@end

@implementation CommonPoiListTableViewCell

- (void)awakeFromNib {
    _titleLabel.backgroundColor = APP_THEME_COLOR;
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"rating_star.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    
    _headerImageView.layer.cornerRadius = 2.0;
    _headerImageView.clipsToBounds = YES;
    _headerImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _headerImageView.layer.borderWidth = 0.5;
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    self.backgroundColor = [UIColor whiteColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setShouldEditing:(BOOL)shouldEditing
{
    _shouldEditing = shouldEditing;
    if (_shouldEditing) {
        _mapBtn.hidden = YES;
        _distanceLabel.hidden = YES;
    } else {
        _mapBtn.hidden = NO;
        _distanceLabel.hidden = NO;
    }
}

- (void)setTripPoi:(TripPoi *)tripPoi
{
    _tripPoi = tripPoi;
    _titleLabel.text = [NSString stringWithFormat:@"  %@", tripPoi.zhName];
    TaoziImage *image = [tripPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _ratingView.rating = tripPoi.rating;
    if (_tripPoi.poiType == kRestaurantPoi) {
        _propertyLabel.text = _tripPoi.priceDesc;
    }
    _addressLabel.text = _tripPoi.address;
}

@end





