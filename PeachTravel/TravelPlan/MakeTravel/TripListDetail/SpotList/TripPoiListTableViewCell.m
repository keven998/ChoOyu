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
    _headerImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _headerImageView.layer.borderWidth = 0.5;
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;

    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setTripPoi:(PoiSummary *)tripPoi
{
    _tripPoi = tripPoi;
    TaoziImage *image = [_tripPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _titleLabel.text = tripPoi.zhName;
    if (_tripPoi.poiType == kSpotPoi) {
        NSString *timeStr = [NSString stringWithFormat:@"参考游玩  %@", tripPoi.timeCost];
        [_property setTitle:timeStr forState:UIControlStateNormal];
    } else {
        [_property setImage:nil forState:UIControlStateNormal];
        if (_tripPoi.poiType == kRestaurantPoi) {
            [_property setTitle:tripPoi.priceDesc forState:UIControlStateNormal];
        }
        if (_tripPoi.poiType == kHotelPoi) {
            [_property setTitle:@"" forState:UIControlStateNormal];
        }
    }
   
}

@end
