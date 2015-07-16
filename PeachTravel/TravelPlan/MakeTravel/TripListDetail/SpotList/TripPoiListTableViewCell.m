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
    [_actionBtn setTitleColor: APP_THEME_COLOR forState:UIControlStateNormal];
    _actionBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    _actionBtn.layer.cornerRadius = 5;
    _actionBtn.clipsToBounds = YES;
    [_actionBtn setTitle:@"添加" forState:UIControlStateNormal];
    [_actionBtn setTitle:@"已添加" forState:UIControlStateSelected];
    _actionBtn.hidden = YES;
}

- (void)setTripPoi:(SuperPoi *)tripPoi
{
    _tripPoi = tripPoi;
    
    NSLog(@"%@",tripPoi);
    
    TaoziImage *image = [_tripPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _titleLabel.text = tripPoi.zhName;
    
    
    NSString *property = nil;
    NSString *rankStr = nil;
    if (_tripPoi.rank <= 200 && _tripPoi.rank > 0) {
        rankStr = [NSString stringWithFormat:@"%d", _tripPoi.rank];
    } else if (_tripPoi.rank > 200) {
        rankStr = @"N";
    } else {
        rankStr = @"N";
    }
    
//    [_propertyBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
//    [_propertyBtn setTitle:rankStr forState:UIControlStateNormal];
    _imageTitle.text = rankStr;
    [_imageTitle setTextColor:APP_THEME_COLOR];
    
    if (_tripPoi.poiType == kSpotPoi) {
        if ([((SpotPoi *)tripPoi).timeCostStr isBlankString]) {
            
        } else {
            NSString *timeStr = [NSString stringWithFormat:@"建议游玩%@", ((SpotPoi *)tripPoi).timeCostStr];
//            property = [NSString stringWithFormat:@"%@  %@", rankStr, timeStr];
            property = timeStr;
        }
    } else {
        property = [NSString stringWithFormat:@"%@%@", rankStr, @"小吃快餐"];
    }
    
    
    /*
    [_propertyBtn setImage:[UIImage imageNamed:@"plan_bottom_flower.png"] forState:UIControlStateNormal];
    if (property != nil && ![property isBlankString]) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:property];
        [string addAttributes:@{NSForegroundColorAttributeName : COLOR_TEXT_III} range:NSMakeRange(rankStr.length+1, property.length-rankStr.length-1)];
        [_propertyBtn setAttributedTitle:string forState:UIControlStateNormal];
    }
    */
    self.foodNumber.text = property;
//    [_actionBtn setTitle:property forState:UIControlStateNormal];


}

@end






