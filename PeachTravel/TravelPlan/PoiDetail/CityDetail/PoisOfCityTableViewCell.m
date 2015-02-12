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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceBottomConstraint;

@end

@implementation PoisOfCityTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray_small.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"ic_star_yellow_small.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 3;
    _headerImageView.layer.cornerRadius = 2.0;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _distanceLabel.hidden = YES;
    
    _pAddBtn.layer.cornerRadius = 4.0;
    [_pAddBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_SUB_THEME_COLOR] forState:UIControlStateNormal];
    [_pAddBtn setBackgroundImage:[ConvertMethods createImageWithColor:TEXT_COLOR_TITLE_PH] forState:UIControlStateSelected];
    
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _headerImageView.clipsToBounds = YES;
    _bkgFrame.layer.cornerRadius = 2.0;
    _bkgFrame.clipsToBounds = YES;
    
    _spaceBottomConstraint.constant = -0.5;
    
    self.backgroundColor = APP_PAGE_COLOR;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setIsNearByCell:(BOOL)isNearByCell
{
    _isNearByCell = isNearByCell;
    if (_isNearByCell) {
        [_naviBtn setBackgroundImage:[UIImage imageNamed:@"ic_nav_button_figure.png"] forState:UIControlStateNormal];
    } else {
        [_naviBtn setBackgroundImage:[UIImage imageNamed:@"ic_nav_button_non.png"] forState:UIControlStateNormal];
    }

}

- (void)setPoi:(PoiSummary *)poi
{
    _poi = poi;
    NSString *title = [NSString stringWithFormat:@"%@", _poi.zhName];
    _titleLabel.text = title;
    if (_poi.poiType == kRestaurantPoi || _poi.poiType == kHotelPoi) {
        _propertyLabel.text = _poi.priceDesc;

    }
    
    if (_poi.poiType == kShoppingPoi) {
        _propertyLabel.text = @"";
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
    
    NSString *rankStr;
    switch (_poi.poiType) {
        case kSpotPoi:
            rankStr = @"景点排名";
            break;
            
        case kRestaurantPoi:
            rankStr = @"美食排名";
            break;
            
        case kShoppingPoi:
            rankStr = @"购物排名";
            break;
            
        case kHotelPoi:
            rankStr = @"酒店排名";
            break;
            
        default:
            break;
    }
    
    if (_poi.rank > 0 && _poi.rank <= 100) {
        _rankingLabel.text = [NSString stringWithFormat:@"%@ %d", rankStr, _poi.rank];
    } else {
        _rankingLabel.text = [NSString stringWithFormat:@"%@ >100", rankStr];
    }

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
    _pAddBtn.selected = isAdded;
//    if (_isAdded) {
//        [_pAddBtn setTitle:@"已收集" forState:UIControlStateNormal];
//        _pAddBtn.titleLabel.font = [UIFont fontWithName:@"MicroSoftYahei" size:13.0];
//        _pAddBtn.backgroundColor = [UIColor grayColor];
//    } else {
//        _pAddBtn.backgroundColor = APP_SUB_THEME_COLOR;
//        _pAddBtn.titleLabel.font = [UIFont fontWithName:@"MicroSoftYahei" size:14.0];
//        [_pAddBtn setTitle:@"收集" forState:UIControlStateNormal];
//    }
}


@end
