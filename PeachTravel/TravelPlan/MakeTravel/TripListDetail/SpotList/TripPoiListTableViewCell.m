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
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    
    CGRect rect = _spaceview.frame;
    rect.size.height = 0.5;
    _spaceview.frame = rect;

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setTripPoi:(PoiSummary *)tripPoi
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
    if (_tripPoi.rank == 0) {
        _rankLabel.text = @"";
    } else if (_tripPoi.rank <= 100) {
        _rankLabel.text = [NSString stringWithFormat:@"%@ %d", rankStr, _tripPoi.rank];
    } else {
        _rankLabel.text = [NSString stringWithFormat:@"%@ >100", rankStr];
    }
    
    _tripPoi.priceDesc = @"人均10元";
    if (_tripPoi.poiType == kSpotPoi) {
        NSString *timeStr = [NSString stringWithFormat:@"参考游玩  %@", tripPoi.timeCost];
        [_property setTitle:timeStr forState:UIControlStateNormal];
    } else {
        [_property setImage:nil forState:UIControlStateNormal];
        if (_tripPoi.poiType == kRestaurantPoi || _tripPoi.poiType == kHotelPoi || _tripPoi.poiType == kShoppingPoi) {
            [_property setTitle:_tripPoi.address forState:UIControlStateNormal];
        }
    }
   
}

@end
