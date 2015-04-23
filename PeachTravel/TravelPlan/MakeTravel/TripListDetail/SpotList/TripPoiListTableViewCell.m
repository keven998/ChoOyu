//
//  TripPoiListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TripPoiListTableViewCell.h"

@implementation TripPoiListTableViewCell

- (void)awakeFromNib {
//    _headerImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
//    _headerImageView.layer.borderWidth = 0.5;
//    _headerImageView.layer.cornerRadius = 1.0;
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    
    UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(36, 0, CGRectGetWidth(self.bounds) - 46, 1)];
    dividerView.backgroundColor = APP_PAGE_COLOR;
    dividerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:dividerView];

    _titleLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    _propertyLabel.textColor = TEXT_COLOR_TITLE_HINT;
    _valueLabel.textColor = APP_THEME_COLOR;
    
    _timeLineView.backgroundColor = APP_DIVIDER_COLOR;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
    _timeLineView.hidden = (state != UITableViewCellStateDefaultMask);
}

- (void)setTripPoi:(SuperPoi *)tripPoi
{
    _tripPoi = tripPoi;
    TaoziImage *image = [_tripPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _titleLabel.text = tripPoi.zhName;
    
    NSString *rankStr;
    switch (_tripPoi.poiType) {
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
    
    NSString *property = _tripPoi.locality.zhName;
    if (_tripPoi.rank == 0) {
        
    } else if (_tripPoi.rank <= 500) {
        property = [NSString stringWithFormat:@"%@ %@:%d", property, rankStr, _tripPoi.rank];
    } else {
        property = [NSString stringWithFormat:@"%@", property];
    }
    _propertyLabel.text = property;
    
    if (_tripPoi.poiType == kSpotPoi) {
        NSString *timeStr = [NSString stringWithFormat:@"参考游玩时间:%@", ((SpotPoi *)tripPoi).timeCostStr];
        _valueLabel.text = timeStr;
    } else {
        _valueLabel.text = nil;
    }
//    else {
//        if (_tripPoi.poiType == kRestaurantPoi || _tripPoi.poiType == kHotelPoi || _tripPoi.poiType == kShoppingPoi) {
//            _valueLabel.text = _tripPoi.address;
//        }
//    }   
}

@end
