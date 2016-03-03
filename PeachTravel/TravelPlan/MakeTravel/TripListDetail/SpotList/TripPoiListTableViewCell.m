//
//  TripPoiListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TripPoiListTableViewCell.h"

@implementation TripPoiListTableViewCell

- (void)awakeFromNib
{
    _headerImageView.backgroundColor = APP_PAGE_COLOR;
    _headerImageView.clipsToBounds = YES;
    [_actionBtn setTitleColor: APP_THEME_COLOR forState:UIControlStateNormal];
    [_actionBtn setTitleColor:COLOR_TEXT_III forState:UIControlStateSelected];
    _actionBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_actionBtn setBackgroundImage:[ConvertMethods createImageWithColor:COLOR_DISABLE] forState:UIControlStateSelected];
    [_actionBtn setBackgroundImage:[UIImage imageNamed:@"sent_bg.png"] forState:UIControlStateNormal];
    _actionBtn.layer.cornerRadius = 3;
    _actionBtn.clipsToBounds = YES;
    _actionBtn.hidden = YES;
    
    _ratingView.starImage = [UIImage imageNamed:@"icon_rating_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"icon_rating_yellow.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 1;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _ratingView.userInteractionEnabled = NO;
    
    [_hotImageView setImage:[UIImage imageNamed:@"icon_poiList_hot"]];
}

- (void)setTripPoi:(SuperPoi *)tripPoi
{
    _tripPoi = tripPoi;
    
    TaoziImage *image = [_tripPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _titleLabel.text = tripPoi.zhName;
    
    NSString *property = nil;

    if (_tripPoi.poiType == kSpotPoi) {
        if ([((SpotPoi *)tripPoi).timeCostStr isBlankString]) {
            
        } else {
            NSString *timeStr = [NSString stringWithFormat:@"建议游玩%@", ((SpotPoi *)tripPoi).timeCostStr];
            property = timeStr;
        }
    } else {
        property = [_tripPoi.style firstObject];
    }
    _propertyLabel.text = property;
    
    _ratingView.rating = _tripPoi.rating;
    
    _hotImageView.hidden = (_tripPoi.rank > 3 || !_tripPoi.rank);
    _hotLabel.hidden = _hotImageView.hidden;
}

@end






