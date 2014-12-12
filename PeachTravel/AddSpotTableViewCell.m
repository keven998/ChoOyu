//
//  AddSpotTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "AddSpotTableViewCell.h"

@implementation AddSpotTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setTripPoi:(TripPoi *)tripPoi
{
    TaoziImage *image = [tripPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _titleLabel.text = tripPoi.zhName;
    [_timeCostBtn setTitle:tripPoi.timeCost forState:UIControlStateNormal];
    _descLabel.text = tripPoi.desc;
}

- (void)setSholdEdit:(BOOL)shouldEdit
{
    _shouldEdit = shouldEdit;
    if (_shouldEdit) {
        _addBtn.backgroundColor = APP_THEME_COLOR;
        [_addBtn setTitle:@"添加" forState:UIControlStateNormal];
        [_addBtn setImage:nil forState:UIControlStateNormal];
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    } else {
        _addBtn.backgroundColor = [UIColor whiteColor];
        [_addBtn setTitle:nil forState:UIControlStateNormal];
        [_addBtn setImage:[UIImage imageNamed:@"ic_navigation_normal.png"] forState:UIControlStateNormal];
        [_addBtn setImage:[UIImage imageNamed:@"ic_navigation_highlight.png"] forState:UIControlStateHighlighted];
    }

}
@end
