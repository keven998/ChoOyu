//
//  MyGuidesTableViewCell.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/28/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "MyGuidesTableViewCell.h"
#import "UIImage+resized.h"
@implementation MyGuidesTableViewCell

- (void)awakeFromNib
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = APP_PAGE_COLOR;
    
    _headerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(18, 0, CGRectGetWidth(self.frame)-36, 158)];
    _headerImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _headerImageView.clipsToBounds = YES;
    _sendBtn.layer.cornerRadius = 2.0;
    [_sendBtn setTitleColor:COLOR_TEXT_III forState:UIControlStateNormal];
    // 设置发送按钮的边框
    _sendBtn.layer.borderColor = COLOR_LINE.CGColor;
    _sendBtn.layer.borderWidth = 1;
    
    _playedImage = [[UIImageView alloc]initWithFrame:CGRectMake(kWindowWidth-180, 55, 80, 80)];
    NSLog(@"%lf", _headerImageView.bounds.size.width-180);
    _playedImage.contentMode = UIViewContentModeScaleAspectFill;
    _playedImage.image = [UIImage imageNamed:@"plan_bg_page_qian"];
    [_headerImageView addSubview:_playedImage];

    _deleteBtn.hidden = YES;
    _playedBtn.hidden = YES;
    [self insertSubview:_headerImageView atIndex:0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setGuideSummary:(MyGuideSummary *)guideSummary
{
    _guideSummary = guideSummary;
    _countBtn.text = [NSString stringWithFormat:@"%ld天", (long)_guideSummary.dayCount];
    _descLabel.text = _guideSummary.summary;
    _titleBtn.text = guideSummary.title;
    if ([_guideSummary.status isEqualToString:@"planned"]) {
        _headerImageView.image = [[UIImage imageNamed:@"plan_bg_page_default"]resizableImageWithCapInsets:UIEdgeInsetsMake(41, 12, 2, 187)];
        _playedImage.hidden = YES;
    } else {
        _headerImageView.image = [[UIImage imageNamed:@"plan_bg_page_grey"]resizableImageWithCapInsets:UIEdgeInsetsMake(41, 12, 2, 187)];
        _playedImage.hidden = NO;
    }

    _timeLabel.text = [NSString stringWithFormat:@"创建：%@", _guideSummary.updateTimeStr];
}

- (void)setIsCanSend:(BOOL)isCanSend
{
    _isCanSend = isCanSend;
    if (_isCanSend) {
        _sendBtn.hidden = NO;
        _deleteBtn.hidden = YES;
        _playedBtn.hidden = YES;
    } else {
        _sendBtn.hidden = YES;
    }
}

@end
