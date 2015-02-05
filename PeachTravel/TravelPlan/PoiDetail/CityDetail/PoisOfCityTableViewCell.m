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
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"ic_star_yellow.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _distanceLabel.hidden = YES;
    _pAddBtn.layer.cornerRadius = 2.0;
    _pAddBtn.titleLabel.font = [UIFont fontWithName:@"MicroSoftYahei" size:14.0];
//    _headerImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
//    _headerImageView.layer.borderWidth = 0.5;
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _bkgFrame.layer.cornerRadius = 2.0;
//    _titleLabel.font = [UIFont fontWithName:@"MicroSoftYahei" size:15.0];
//    _addressLabel.font = [UIFont fontWithName:@"MicroSoftYahei" size:14.0];
//    _propertyLabel.font = [UIFont fontWithName:@"MicroSoftYahei" size:11.0];
//    _rankingLabel.font = [UIFont fontWithName:@"MicroSoftYahei" size:11.0];

    self.backgroundColor = APP_PAGE_COLOR;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setPoi:(PoiSummary *)poi
{
    _poi = poi;
    NSString *title = [NSString stringWithFormat:@"%@", _poi.zhName];
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
}

- (void)setHideActionBtn:(BOOL)hideActionBtn
{
    _hideActionBtn = hideActionBtn;
    _naviBtn.hidden = _hideActionBtn;
    _addBtn.hidden = _hideActionBtn;
    _pAddBtn.hidden = _hideActionBtn;
}

- (void)setShouldEdit:(BOOL)shouldEdit
{
    _shouldEdit = shouldEdit;

    if (_shouldEdit) {
        _naviBtn.hidden = YES;
        _distanceLabel.hidden = YES;
    } else {
        _addBtn.hidden = YES;
        _pAddBtn.hidden = YES;
    }
}

- (void)setIsAdded:(BOOL)isAdded
{
    _isAdded = isAdded;
    if (_isAdded) {
        [_pAddBtn setTitle:@"已收集" forState:UIControlStateNormal];
        _pAddBtn.titleLabel.font = [UIFont fontWithName:@"MicroSoftYahei" size:13.0];
        _pAddBtn.backgroundColor = [UIColor grayColor];
    } else {
        _pAddBtn.backgroundColor = APP_SUB_THEME_COLOR;
        _pAddBtn.titleLabel.font = [UIFont fontWithName:@"MicroSoftYahei" size:14.0];
        [_pAddBtn setTitle:@"收集" forState:UIControlStateNormal];
    }
}


@end
