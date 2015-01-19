//
//  MyGuidesTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/28/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "MyGuidesTableViewCell.h"

@implementation MyGuidesTableViewCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _headerImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _headerImageView.layer.borderWidth = 0.5;
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _headerImageView.clipsToBounds = YES;    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setGuideSummary:(MyGuideSummary *)guideSummary
{
    _guideSummary = guideSummary;
    _countBtn.text = [NSString stringWithFormat:@"%ld", (long)_guideSummary.dayCount];
    _descLabel.text = _guideSummary.summary;
    TaoziImage *image = [_guideSummary.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _timeLabel.text = [NSString stringWithFormat:@"%@", _guideSummary.updateTimeStr];
    _titleBtn.text = _guideSummary.title;
}

@end
