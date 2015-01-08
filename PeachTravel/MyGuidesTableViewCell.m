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
    self.backgroundColor = APP_PAGE_COLOR;
    _deleteBtn.alpha = 0;
    self.countBtn.layer.cornerRadius = 25.0;
    self.countBtn.clipsToBounds = YES;
    self.countBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    self.countBtn.layer.borderWidth = 2.0;
    self.countBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.deleteBtn.layer.cornerRadius = 15.0;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _headerImageView.layer.borderColor = APP_BORDER_COLOR.CGColor;
    _headerImageView.layer.borderWidth = 0.5;
    _headerImageView.backgroundColor = APP_IMAGEVIEW_COLOR;
    _headerImageView.clipsToBounds = YES;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setIsEditing:(BOOL)isEditing
{
    _isEditing = isEditing;
    if (_isEditing) {
        [_titleBtn setImage:[UIImage imageNamed:@"ic_plan_title_edit.png"] forState:UIControlStateNormal];
        _titleBtn.imageView.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            _deleteBtn.alpha = 1;
            _titleBtn.imageView.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            _deleteBtn.alpha = 0;
            _titleBtn.imageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [_titleBtn setImage:nil forState:UIControlStateNormal];
        }];
    }
}

- (void)setGuideSummary:(MyGuideSummary *)guideSummary
{
    _guideSummary = guideSummary;
    [_countBtn setTitle:[NSString stringWithFormat:@"%ld天", (long)_guideSummary.dayCount] forState:UIControlStateNormal];
    _descLabel.text = _guideSummary.summary;
    TaoziImage *image = [_guideSummary.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _timeLabel.text = [NSString stringWithFormat:@"%@", _guideSummary.updateTimeStr];
    [_titleBtn setTitle:_guideSummary.title forState:UIControlStateNormal];
}

@end
