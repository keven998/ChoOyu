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
    self.backgroundColor = [UIColor whiteColor];
    
    _titleBtn.font = [UIFont systemFontOfSize:11.0];
    _descLabel.font = [UIFont boldSystemFontOfSize:15.0];
    _sendBtn.layer.cornerRadius = 2.0;
    [_sendBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    // 设置发送按钮的边框
    _sendBtn.layer.borderColor = APP_THEME_COLOR.CGColor;
    _sendBtn.layer.borderWidth = 1;
    
    [_deleteBtn setImage:[UIImage imageNamed:@"plan_delete.png"] forState:UIControlStateNormal];
    _deleteBtn.hidden = YES;
    [_playedBtn setImage:[UIImage imageNamed:@"plan_traveled.png"] forState:UIControlStateNormal];
    _playedBtn.hidden = YES;
    
    _markImageView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setGuideSummary:(MyGuideSummary *)guideSummary
{
    _guideSummary = guideSummary;
    _countBtn.text = [NSString stringWithFormat:@"%ld天", (long)_guideSummary.dayCount];

    _descLabel.text = _guideSummary.summary;
    _titleBtn.text = _guideSummary.title;
    if ([_guideSummary.status isEqualToString:@"planned"]) {
        _playedImage.hidden = YES;
    } else {
        _playedImage.hidden = NO;
    }
    
    _timeLabel.text = [NSString stringWithFormat:@"创建：%@", _guideSummary.updateTimeStr];
    
    NSLog(@"%ld,%@,%@,%@,%@",_guideSummary.dayCount,_guideSummary.summary,_guideSummary.title,_guideSummary.status,_guideSummary.updateTimeStr);
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
