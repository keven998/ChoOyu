//
//  TripPoiListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TripPoiListTableViewCell.h"

@implementation TripPoiListTableViewCell

- (void)awakeFromNib {
    _nearBy.layer.borderColor = UIColorFromRGB(0x797979).CGColor;
    _nearBy.layer.borderWidth = 1.0;
    _nearBy.layer.cornerRadius = 2.0;
    self.layer.cornerRadius = 2.0;
    self.clipsToBounds = YES;
    _ratingBackgroundView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    _ratingBackgroundView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"rating_star.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;

}

- (void)setIsEditing:(BOOL)isEditing
{
    if (isEditing) {
        _pictureHorizontalSpace.constant = 8;
        _nearBy.hidden = YES;
        _spaceView.hidden = YES;
        _timeCostConstraint.constant = 40;
        _titleContstraint.constant = 40;
    } else
    {
        _pictureHorizontalSpace.constant = 28;
        _nearBy.hidden = NO;
        _spaceView.hidden = NO;
        _timeCostConstraint.constant = 78;
        _titleContstraint.constant = 77;
    }
}

- (void)setTripPoi:(TripPoi *)tripPoi
{
    _tripPoi = tripPoi;
    TaoziImage *image = [_tripPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _titleLabel.text = tripPoi.zhName;
    if (_tripPoi.poiType == TripSpotPoi) {
        NSString *timeStr = [NSString stringWithFormat:@"参考游玩  %@", tripPoi.timeCost];
        [_property setTitle:timeStr forState:UIControlStateNormal];
        _ratingBackgroundView.hidden = YES;
    } else {
        _ratingBackgroundView.hidden = NO;
        _ratingView.rating = tripPoi.rating;
        [_property setImage:nil forState:UIControlStateNormal];
        if (_tripPoi.poiType == TripRestaurantPoi) {
            [_property setTitle:tripPoi.priceDesc forState:UIControlStateNormal];
        }
        if (_tripPoi.poiType == TripHotelPoi) {
            [_property setTitle:@"" forState:UIControlStateNormal];
        }
    }
   
}

@end
