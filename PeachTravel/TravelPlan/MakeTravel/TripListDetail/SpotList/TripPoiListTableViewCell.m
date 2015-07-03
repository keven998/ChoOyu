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
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    
    UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(36, 0, CGRectGetWidth(self.bounds) - 46, 1)];
    dividerView.backgroundColor = APP_PAGE_COLOR;
    dividerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.contentView addSubview:dividerView];

    _titleLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setTripPoi:(SuperPoi *)tripPoi
{
    _tripPoi = tripPoi;
    TaoziImage *image = [_tripPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _titleLabel.text = tripPoi.zhName;
    NSString *property = nil;
    NSString *rankStr = nil;
    if (_tripPoi.rank <= 500 && _tripPoi.rank > 0) {
        rankStr = [NSString stringWithFormat:@"%d", _tripPoi.rank];

    } else {
        rankStr = @">500";
    }
    
    if (_tripPoi.poiType == kSpotPoi) {
        if ([((SpotPoi *)tripPoi).timeCostStr isBlankString]) {
            
        }else{
            NSString *timeStr = [NSString stringWithFormat:@"建议游玩%@", ((SpotPoi *)tripPoi).timeCostStr];
            property = [NSString stringWithFormat:@"%@ %@", rankStr, timeStr];
        }
        
    } else {
        
    }
    [_propertyBtn setTitle:property forState:UIControlStateNormal];
}

@end






