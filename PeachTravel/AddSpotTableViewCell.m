//
//  AddSpotTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "AddSpotTableViewCell.h"

@implementation AddSpotTableViewCell

- (void)awakeFromNib {
    _distanceLabel.hidden = YES;
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"rating_star.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _addBtn.layer.cornerRadius = 2.0;
    _headerImageView.layer.cornerRadius = 2.0;
    _headerImageView.clipsToBounds = YES;
}

- (void)setTripPoi:(TripPoi *)tripPoi
{
    _tripPoi = tripPoi;
    TaoziImage *image = [_tripPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _titleLabel.text = _tripPoi.zhName;
    [_timeCostBtn setTitle:_tripPoi.timeCost forState:UIControlStateNormal];
    _descLabel.text = _tripPoi.desc;
    _ratingView.rating = _tripPoi.rating;
    if (_tripPoi.distanceStr) {
        _distanceLabel.hidden = NO;
        _distanceLabel.text = _tripPoi.distanceStr;
    }
    
}

- (void)setShouldEdit:(BOOL)shouldEdit
{
    _shouldEdit = shouldEdit;
    if (_shouldEdit) {
        _addBtn.backgroundColor = APP_THEME_COLOR;
        [_addBtn setTitle:@"添加" forState:UIControlStateNormal];
        [_addBtn setImage:nil forState:UIControlStateNormal];
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    } else {
        _addBtn.backgroundColor = [UIColor whiteColor];
        [_addBtn setTitle:nil forState:UIControlStateNormal];
        [_addBtn setImage:[UIImage imageNamed:@"ic_navigation_normal.png"] forState:UIControlStateNormal];
        [_addBtn setImage:[UIImage imageNamed:@"ic_navigation_highlight.png"] forState:UIControlStateHighlighted];
    }

}
@end
