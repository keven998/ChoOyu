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

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = APP_PAGE_COLOR;
    
    _headerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(18, 0, CGRectGetWidth(self.frame)-36, 158)];
    _headerImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _headerImageView.clipsToBounds = YES;
    _titleBtn.font = [UIFont systemFontOfSize:11.0];
    _descLabel.font = [UIFont boldSystemFontOfSize:15.0];
    _sendBtn.layer.cornerRadius = 2.0;
    [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    // 设置发送按钮的边框
    _sendBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _sendBtn.layer.borderWidth = 1;
    
    _playedImage = [[UIImageView alloc]initWithFrame:CGRectMake(kWindowWidth - 38 - 410/3, 144/3, 420/3, 396/3)];
    _playedImage.contentMode = UIViewContentModeScaleAspectFill;
    _playedImage.image = [UIImage imageNamed:@"plan_bg_page_qian"];
    [_headerImageView addSubview:_playedImage];
    
    UIImageView *moonImage = [[UIImageView alloc]initWithFrame:CGRectMake((kWindowWidth - 117/3)/2-18, 7, 117/3, 12)];
    moonImage.image = [UIImage imageNamed:@"plan_bg_page_spot_zhedang"];
    [_headerImageView addSubview:moonImage];
    
    [_deleteBtn setImage:[UIImage imageNamed:@"plan_delete.png"] forState:UIControlStateNormal];
    _deleteBtn.hidden = YES;
    [_playedBtn setImage:[UIImage imageNamed:@"plan_traveled.png"] forState:UIControlStateNormal];
    _playedBtn.hidden = YES;
    [self insertSubview:_headerImageView atIndex:0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setGuideSummary:(MyGuideSummary *)guideSummary
{
    _guideSummary = guideSummary;
    _countBtn.text = [NSString stringWithFormat:@"%ld天", (long)_guideSummary.dayCount];
    _descLabel.text = _guideSummary.summary;
    _titleBtn.text = guideSummary.title;
    UIImage *image = [[UIImage imageNamed:@"plan_bg_page_default"]resizableImageWithCapInsets:UIEdgeInsetsMake(30, 15, 70, 15)];
    if ([_guideSummary.status isEqualToString:@"planned"]) {
        _headerImageView.image = image;
        _playedImage.hidden = YES;
    } else {
        _headerImageView.image = [[UIImage imageNamed:@"plan_bg_page_grey"]resizableImageWithCapInsets:UIEdgeInsetsMake(30, 15, 70, 15)];
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
