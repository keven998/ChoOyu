//
//  SpotsListTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SpotsListTableViewCell.h"

@implementation SpotsListTableViewCell

- (void)awakeFromNib {
    _nearBy.layer.borderColor = APP_PAGE_COLOR.CGColor;
    _nearBy.layer.borderWidth = 1.0;
    _nearBy.layer.cornerRadius = 1.0;
}

- (void)setIsEditing:(BOOL)isEditing
{
    if (isEditing) {
        _pictureHorizontalSpace.constant = 8;
        _nearBy.hidden = YES;
        _spaceView.hidden = YES;
        _timeCostConstraint.constant = 40;
        _titleContstraint.constant = 40;
    } else
    {
        _pictureHorizontalSpace.constant = 28;
        _nearBy.hidden = NO;
        _spaceView.hidden = NO;
        _timeCostConstraint.constant = 78;
        _titleContstraint.constant = 77;
    }
}

- (void)setTripPoi:(TripPoi *)tripPoi
{
    _tripPoi = tripPoi;
    TaoziImage *image = [_tripPoi.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _titleLabel.text = tripPoi.zhName;
    [_timeCostBtn setTitle:tripPoi.timeCost forState:UIControlStateNormal];
}

@end
