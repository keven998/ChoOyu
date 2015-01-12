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
    self.layer.cornerRadius = 2.0;
    self.clipsToBounds = YES;
    _ratingBackgroundView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"rating_star.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _headerImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _headerImageView.layer.borderWidth = 0.5;
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setIsShouldEditing:(BOOL)isShouldEditing
{
    _isShouldEditing = isShouldEditing;
    if (_isShouldEditing) {
        _pictureHorizontalSpace.constant = 8;
        _spaceView.hidden = YES;
    } else
    {
        _pictureHorizontalSpace.constant = 28;
        _spaceView.hidden = NO;
    }
}

- (void)setTripPoi:(TripPoi *)tripPoi
{
    _tripPoi = tripPoi;
    TaoziImage *image = [_tripPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _titleLabel.text = tripPoi.zhName;
    if (_tripPoi.poiType == kSpotPoi) {
        NSString *timeStr = [NSString stringWithFormat:@"参考游玩  %@", tripPoi.timeCost];
        [_property setTitle:timeStr forState:UIControlStateNormal];
        _ratingBackgroundView.hidden = YES;
    } else {
        _ratingBackgroundView.hidden = NO;
        _ratingView.rating = tripPoi.rating;
        
        [_property setImage:nil forState:UIControlStateNormal];
        if (_tripPoi.poiType == kRestaurantPoi) {
            [_property setTitle:tripPoi.priceDesc forState:UIControlStateNormal];
        }
        if (_tripPoi.poiType == kHotelPoi) {
            [_property setTitle:@"" forState:UIControlStateNormal];
        }
    }
   
}

@end
