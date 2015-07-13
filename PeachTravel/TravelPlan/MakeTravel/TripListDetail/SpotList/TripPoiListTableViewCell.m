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
    
    [_actionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_actionBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forState:UIControlStateNormal];
    [_actionBtn setBackgroundImage:[ConvertMethods createImageWithColor:TEXT_COLOR_TITLE_DESC] forState:UIControlStateSelected];
    _actionBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    _actionBtn.layer.cornerRadius = 5;
    _actionBtn.clipsToBounds = YES;
    [_actionBtn setTitle:@"添加" forState:UIControlStateNormal];
    [_actionBtn setTitle:@"已添加" forState:UIControlStateSelected];
    _actionBtn.hidden = YES;
}

- (void)setTripPoi:(SuperPoi *)tripPoi
{
    _tripPoi = tripPoi;
    TaoziImage *image = [_tripPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _titleLabel.text = tripPoi.zhName;
    NSString *property = nil;
    NSString *rankStr = nil;
    if (_tripPoi.rank <= 200 && _tripPoi.rank > 0) {
        rankStr = [NSString stringWithFormat:@"%d", _tripPoi.rank];
    } else if (_tripPoi.rank > 200) {
        rankStr = @"200+";
    } else {
        rankStr = @"  ";
    }
    
    if (_tripPoi.poiType == kSpotPoi) {
        if ([((SpotPoi *)tripPoi).timeCostStr isBlankString]) {
            
        } else {
            NSString *timeStr = [NSString stringWithFormat:@"建议游玩%@", ((SpotPoi *)tripPoi).timeCostStr];
            property = [NSString stringWithFormat:@"%@  %@", rankStr, timeStr];
        }
    } else {
        property = [NSString stringWithFormat:@"%@  %@", rankStr, @"小吃快餐"];
    }
    [_propertyBtn setImage:[UIImage imageNamed:@"plan_bottom_flower.png"] forState:UIControlStateNormal];
    if (property != nil && ![property isBlankString]) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:property];
        [string addAttributes:@{NSForegroundColorAttributeName : COLOR_TEXT_III} range:NSMakeRange(rankStr.length+1, property.length-rankStr.length-1)];
        [_propertyBtn setAttributedTitle:string forState:UIControlStateNormal];
    }
}

@end






