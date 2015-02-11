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
    _bkgFrame.layer.cornerRadius = 2.0;
    _headerImageView.layer.cornerRadius = 2.0;
    _headerImageView.clipsToBounds = YES;
//    _headerImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
//    _headerImageView.layer.borderWidth = 0.5;
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _deleteBtn.hidden = YES;


//    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _seperatorView.backgroundColor = APP_SUB_THEME_COLOR;
    
    UIView *bv = [[UIView alloc] initWithFrame:self.frame];
    bv.backgroundColor = [UIColor whiteColor];
    UIView *sv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 4)];
    sv.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    sv.backgroundColor = APP_SUB_THEME_COLOR;
    [bv addSubview:sv];
    self.backgroundView = bv;
}

- (void)setTripPoi:(PoiSummary *)tripPoi
{
    _tripPoi = tripPoi;
    _titleLabel.text = _tripPoi.zhName;
    TaoziImage *image = [tripPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _ratingView.rating = tripPoi.rating;
    NSString *rankStr;
    if (_tripPoi.poiType == kRestaurantPoi) {
        _propertyLabel.text = _tripPoi.priceDesc;
        rankStr = @"美食排名";
    }
    if (_tripPoi.poiType == kShoppingPoi) {
        rankStr = @"购物排名";
    }
    if (_tripPoi.rank <= 100 && _tripPoi.rank > 0) {
        _rankingLabel.text = [NSString stringWithFormat:@"%@: %d",rankStr, _tripPoi.rank];
    } else {
        _rankingLabel.text = [NSString stringWithFormat:@"%@: >100", rankStr];
    }
    NSAttributedString *localStr = [[NSAttributedString alloc] initWithString:_tripPoi.address attributes:@{NSForegroundColorAttributeName : TEXT_COLOR_TITLE_SUBTITLE}];
    NSMutableAttributedString *allStr = [[NSMutableAttributedString alloc] init];

    if (_tripPoi.locality.zhName) {
        NSAttributedString *localityStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@]", _tripPoi.locality.zhName] attributes:@{NSForegroundColorAttributeName : APP_THEME_COLOR}];
        [allStr appendAttributedString:localityStr];
    }
    [allStr appendAttributedString:localStr];

    _addressLabel.attributedText = allStr;
    
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





