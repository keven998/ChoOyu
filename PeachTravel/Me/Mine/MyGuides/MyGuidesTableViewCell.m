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
//    _headerImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
//    _headerImageView.layer.borderWidth = 1;
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _headerImageView.clipsToBounds = YES;
//    _headerImageView.layer.cornerRadius = 4.0;
    _titleBtn.font = [UIFont systemFontOfSize:14.0];
    _descLabel.font = [UIFont systemFontOfSize:12.0];
    _sendBtn.layer.cornerRadius = 2.0;
    _mockImageView.image = [[UIImage imageNamed:@"ic_mock_up.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    _titleBkgImage.image = [UIImage imageNamed:@"titleImageBackground"];
//resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 5)];
    _sendBtn.backgroundColor = APP_THEME_COLOR;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setGuideSummary:(MyGuideSummary *)guideSummary
{
    _guideSummary = guideSummary;
    _countBtn.text = [NSString stringWithFormat:@"%ld", (long)_guideSummary.dayCount];
    _descLabel.text = [NSString stringWithFormat:@"目的地：%@", _guideSummary.summary];
    TaoziImage *image = [_guideSummary.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    [_timeBtn setTitle:[NSString stringWithFormat:@"%@", _guideSummary.updateTimeStr] forState:UIControlStateNormal];
    _titleBtn.text = _guideSummary.title;
}

- (void)setIsCanSend:(BOOL)isCanSend
{
    _isCanSend = isCanSend;
    if (_isCanSend) {
        _sendBtn.hidden = NO;
        _sendBtnBkgImageView.hidden = NO;
    } else {
        _sendBtnBkgImageView.hidden = YES;
        _sendBtn.hidden = YES;
    }
}

@end
