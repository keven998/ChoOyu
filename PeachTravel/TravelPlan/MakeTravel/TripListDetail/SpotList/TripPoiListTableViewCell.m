//
//  TripPoiListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TripPoiListTableViewCell.h"

@implementation TripPoiListTableViewCell

- (void)awakeFromNib
{
    _headerImageView.backgroundColor = APP_PAGE_COLOR;
    [_actionBtn setTitleColor: APP_THEME_COLOR forState:UIControlStateNormal];
    [_actionBtn setTitleColor:COLOR_TEXT_III forState:UIControlStateSelected];
    _actionBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_actionBtn setBackgroundImage:[ConvertMethods createImageWithColor:COLOR_DISABLE] forState:UIControlStateSelected];
    [_actionBtn setBackgroundImage:[UIImage imageNamed:@"sent_bg.png"] forState:UIControlStateNormal];
    _actionBtn.layer.cornerRadius = 3;
    _actionBtn.clipsToBounds = YES;
    _actionBtn.hidden = YES;
}

- (void)setTripPoi:(SuperPoi *)tripPoi
{
    _tripPoi = tripPoi;
    
    NSLog(@"%@",tripPoi);
    
    TaoziImage *image = [_tripPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _titleLabel.text = tripPoi.zhName;
    
    NSLog(@"%@",_tripPoi.style);
    
    NSString *property = nil;
    NSString *rankStr = nil;
    if (_tripPoi.rank <= 200 && _tripPoi.rank > 0) {
        rankStr = [NSString stringWithFormat:@"%d", _tripPoi.rank];
    } else if (_tripPoi.rank > 200) {
        rankStr = @"N";
    } else {
        rankStr = @"N";
    }

    _imageTitle.text = rankStr;
    [_imageTitle setTextColor:APP_THEME_COLOR];
    
    if (_tripPoi.poiType == kSpotPoi) {
        if ([((SpotPoi *)tripPoi).timeCostStr isBlankString]) {
            
        } else {
            NSString *timeStr = [NSString stringWithFormat:@"建议游玩%@", ((SpotPoi *)tripPoi).timeCostStr];
            property = timeStr;
        }
    } else {
        property = [_tripPoi.style firstObject];
    }
    self.foodNumber.text = property;
    
    if (self.actionBtn.hidden) {
        self.rightLengthContraint.constant = 30;
    }else{
        self.rightLengthContraint.constant = 100;
    }

}

@end






