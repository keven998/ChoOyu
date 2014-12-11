//
//  RestaurantListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RestaurantListTableViewCell.h"
#import "AXRatingView.h"

@interface RestaurantListTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *ratingBackgroundView;
@property (weak, nonatomic) IBOutlet AXRatingView *ratingView;


@end

@implementation RestaurantListTableViewCell

- (void)awakeFromNib {
    _ratingBackgroundView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    _ratingView.userInteractionEnabled = NO;
    _ratingView.markImage = [UIImage imageNamed:@"ic_star_gray.png"];
    [_ratingView sizeToFit];
}

- (void)setIsEditing:(BOOL)isEditing
{
    if (isEditing) {
        _mapViewBtn.hidden = YES;
        _titleLabelConstraint.constant = 0;
        _addressLabelConstraint.constant = 0;
        
    } else {
        _mapViewBtn.hidden = NO;
        _titleLabelConstraint.constant = 60;
        _addressLabelConstraint.constant = 60;

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
    _ratingView.value = tripPoi.rating;
}

@end





