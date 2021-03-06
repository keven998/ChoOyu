//
//  RestaurantListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CommonPoiListTableViewCell.h"
#import "EDStarRating.h"
#import "CommentDetail.h"

@interface CommonPoiListTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *bkgFrame;

@end

@implementation CommonPoiListTableViewCell

- (void)awakeFromNib {
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray_small.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"ic_star_yellow_small.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 7;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 1.0)];
    spaceView.backgroundColor = APP_DIVIDER_COLOR;
    spaceView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:spaceView];
    
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _titleLabel.textColor = TEXT_COLOR_TITLE;
    _propertyLabel.textColor = TEXT_COLOR_TITLE_HINT;
    _valueLabel.textColor = APP_THEME_COLOR;
    
    [_cellAction setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    [_cellAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _cellAction.titleLabel.font = [UIFont systemFontOfSize:14];
    _cellAction.layer.cornerRadius = 5;
}

- (void)setTripPoi:(SuperPoi *)tripPoi
{
    _tripPoi = tripPoi;
    if ([_tripPoi.zhName isBlankString]||_tripPoi.zhName.length == 0 || _tripPoi.zhName == nil) {
        _titleLabel.text = @"  ";
    } else {
        _titleLabel.text = _tripPoi.zhName;
    }
    
    TaoziImage *image = [tripPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    
    _ratingView.rating = tripPoi.rating;
    
    if (_tripPoi.rank <= 200 && _tripPoi.rank > 0) {
        _propertyLabel.text = [NSString stringWithFormat:@"%@ %@排名第%d", _tripPoi.locality.zhName, _tripPoi.poiTypeName, _tripPoi.rank];
    } else {
        if (_tripPoi.locality.zhName == nil || _tripPoi.locality.zhName.length == 0) {
            _propertyLabel.text = @"";
        } else {
            _propertyLabel.text = [NSString stringWithFormat:@"%@", _tripPoi.locality.zhName];
        }
    }
    
    switch (_tripPoi.poiType) {
        case kSpotPoi:
            _valueLabel.text = [NSString stringWithFormat:@"建议游玩%@", ((SpotPoi *)_tripPoi).timeCostStr];
            break;
            
        case kRestaurantPoi:
            _valueLabel.text = ((RestaurantPoi *)_tripPoi).priceDesc;
            break;
            
        case kShoppingPoi:
            
            break;
            
        case kHotelPoi:
            _valueLabel.text = ((HotelPoi *)_tripPoi).priceDesc;
            break;
            
        default:
            break;
    }
    
}

- (void)didTransitionToState:(UITableViewCellStateMask)state
{
    [super didTransitionToState:state];
}

@end





