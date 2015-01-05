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

@property (weak, nonatomic) IBOutlet UIView *ratingBackgroundView;
@property (weak, nonatomic) IBOutlet EDStarRating *ratingView;


@end

@implementation CommonPoiListTableViewCell

- (void)awakeFromNib {
    
    _ratingBackgroundView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"rating_star.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    
    _photoImageView.layer.cornerRadius = 2.0;
    _photoImageView.clipsToBounds = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setIsEditing:(BOOL)isEditing
{
    if (isEditing) {
        _mapViewBtn.hidden = YES;
        _titleLabelConstraint.constant = 0;
        _addressLabelConstraint.constant = 0;
        
    } else {
        _mapViewBtn.hidden = NO;
        _titleLabelConstraint.constant = 40;
        _addressLabelConstraint.constant = 40;

    }
}

- (void)setTripPoi:(TripPoi *)tripPoi
{
    _tripPoi = tripPoi;
    [_titleBtn setTitle:tripPoi.zhName forState:UIControlStateNormal];
    TaoziImage *image = [tripPoi.images firstObject];
    [_photoImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    [_priceBtn setTitle:tripPoi.priceDesc forState:UIControlStateNormal];
    _addressLabel.text = tripPoi.address;
    _ratingView.rating = tripPoi.rating;
}

@end





