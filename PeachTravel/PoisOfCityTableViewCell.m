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
    _headerImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _headerImageView.layer.borderWidth = 0.5;
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setPoi:(PoiSummary *)poi
{
    _poi = poi;
    _titleLabel.text = _poi.zhName;
    if (_poi.poiType == kRestaurantPoi) {
        _propertyLabel.text = _poi.priceDesc;

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
    
    CommentDetail *comment = [poi.comments firstObject];
    _authorNameLabel.text = comment.nickName;
    _commentLabel.text = comment.commentDetails;
}

- (void)setShouldEdit:(BOOL)shouldEdit
{
    _shouldEdit = shouldEdit;

    if (_shouldEdit) {
        _actionBtn.backgroundColor = APP_THEME_COLOR;
        [_actionBtn setTitle:@"收集" forState:UIControlStateNormal];
        [_actionBtn setImage:nil forState:UIControlStateNormal];
        [_actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    } else {
        _actionBtn.backgroundColor = [UIColor whiteColor];
        [_actionBtn setTitle:nil forState:UIControlStateNormal];
        [_actionBtn setImage:[UIImage imageNamed:@"ic_navigation_normal.png"] forState:UIControlStateNormal];
        [_actionBtn setImage:[UIImage imageNamed:@"ic_navigation_highlight.png"] forState:UIControlStateHighlighted];
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
