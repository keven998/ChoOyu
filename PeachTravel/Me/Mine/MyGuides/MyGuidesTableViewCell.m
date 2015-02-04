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
    self.backgroundColor = APP_PAGE_COLOR;
    _headerImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _headerImageView.layer.borderWidth = 1;
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _headerImageView.clipsToBounds = YES;
    _headerImageView.layer.cornerRadius = 4.0;
    _titleBtn.font = [UIFont fontWithName:@"MicroSoftYahei" size:14.0];
    _descLabel.font = [UIFont fontWithName:@"MicroSoftYahei" size:12.0];

    _titleBkgImage.image = [[UIImage imageNamed:@"bg_guide_title.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 5)];
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
    [_timeBtn setTitle:[NSString stringWithFormat:@"%@", _guideSummary.updateTimeStr] forState:UIControlStateNormal];
    _titleBtn.text = _guideSummary.title;
}

@end