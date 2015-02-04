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
    _ratingView.starImage = [UIImage imageNamed:@"ic_star_gray.png"];
    _ratingView.starHighlightedImage = [UIImage imageNamed:@"ic_star_yellow.png"];
    _ratingView.maxRating = 5.0;
    _ratingView.editable = NO;
    _ratingView.horizontalMargin = 7;
    _ratingView.displayMode = EDStarRatingDisplayAccurate;
    _bkgFrame.layer.cornerRadius = 2.0;
    _headerImageView.layer.cornerRadius = 2.0;
    _headerImageView.clipsToBounds = YES;
//    _headerImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
//    _headerImageView.layer.borderWidth = 0.5;
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _deleteBtn.hidden = YES;


    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setTripPoi:(PoiSummary *)tripPoi
{
    _tripPoi = tripPoi;
    _titleLabel.text = _tripPoi.zhName;
    TaoziImage *image = [tripPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _ratingView.rating = tripPoi.rating;
    if (_tripPoi.poiType == kRestaurantPoi) {
        _propertyLabel.text = _tripPoi.priceDesc;
    }
    _addressLabel.text = _tripPoi.address;
    
}

- (void)didTransitionToState:(UITableViewCellStateMask)state
{
    [super didTransitionToState:state];
    if (state == UITableViewCellStateDefaultMask) {
        _mapBtn.hidden = NO;
        _deleteBtn.hidden = YES;
        _distanceLabel.hidden = NO;
    } else {
        _mapBtn.hidden = YES;
        _distanceLabel.hidden = YES;
        _deleteBtn.hidden = NO;
    }
}

@end





