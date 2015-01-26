//
//  PoisOfCityTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "PoisOfCityTableViewCell.h"
#import "CommentDetail.h"
#import "EDStarRating.h"

@interface PoisOfCityTableViewCell ()

@end

@implementation PoisOfCityTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"rating_star.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _distanceLabel.hidden = YES;
    _titleLabel.backgroundColor = UIColorFromRGB(0xeaeaea);
    _headerImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _headerImageView.layer.borderWidth = 0.5;
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    self.backgroundColor = APP_PAGE_COLOR;
}

- (void)setPoi:(PoiSummary *)poi
{
    _poi = poi;
    NSString *title = [NSString stringWithFormat:@"  %@", _poi.zhName];
    _titleLabel.text = title;
    if (_poi.poiType == kRestaurantPoi || _poi.poiType == kHotelPoi) {
        _propertyLabel.text = _poi.priceDesc;

    }
    if (_poi.poiType == kSpotPoi) {
        if (_poi.timeCost) {
            _propertyLabel.text = [NSString stringWithFormat:@"游玩 %@", _poi.timeCost];
        } else {
            _propertyLabel.text = @"";
        }
    }
    TaoziImage *image = [_poi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];;
    _ratingView.rating = _poi.rating;
    _addressLabel.text = _poi.address;
    if (_poi.distanceStr) {
        _distanceLabel.hidden = NO;
        _distanceLabel.text = _poi.distanceStr;
    } else {
        _distanceLabel.hidden = YES;
    }
    if (_poi.poiType == kSpotPoi) {
        _authorNameLabel.text = @"简介";
        _commentLabel.text = _poi.desc;
    } else {
        CommentDetail *comment = [poi.comments firstObject];
        _authorNameLabel.text = comment.nickName;
        _commentLabel.text = comment.commentDetails;
    }
}

- (void)setShouldEdit:(BOOL)shouldEdit
{
    _shouldEdit = shouldEdit;

    if (_shouldEdit) {
        _actionBtn.backgroundColor = APP_THEME_COLOR;
        _actionBtn.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11.0];
        [_actionBtn setTitle:@"收集" forState:UIControlStateNormal];
        [_actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_actionBtn setImage:nil forState:UIControlStateNormal];
        _actionBtn.layer.cornerRadius = 2.0;

    } else {
        [_actionBtn setTitle:nil forState:UIControlStateNormal];
        [_actionBtn setImage:[UIImage imageNamed:@"ic_map.png"] forState:UIControlStateNormal];
    }
}

- (void)setIsAdded:(BOOL)isAdded
{
    _isAdded = isAdded;
    if (_isAdded) {
        [_actionBtn setTitle:@"已收集" forState:UIControlStateNormal];
        _actionBtn.backgroundColor = [UIColor grayColor];
    } else {
        _actionBtn.backgroundColor = APP_THEME_COLOR;
        [_actionBtn setTitle:@"收集" forState:UIControlStateNormal];
    }
}


@end
