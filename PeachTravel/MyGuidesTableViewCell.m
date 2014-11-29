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
    _deleteBtn.alpha = 0;
    _editTitleBtn.alpha = 0;
    self.countBtn.layer.cornerRadius = 25.0;
    self.countBtn.clipsToBounds = YES;
    self.deleteBtn.layer.cornerRadius = 15.0;
    self.editTitleBtn.layer.cornerRadius = 10.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setIsEditing:(BOOL)isEditing
{
    _isEditing = isEditing;
    if (_isEditing) {
        [UIView animateWithDuration:0.3 animations:^{
            _deleteBtn.alpha = 0.7;
            _editTitleBtn.alpha = 0.7;
        } completion:^(BOOL finished) {
            _deleteBtn.alpha = 1;
            _editTitleBtn.alpha = 1;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            _deleteBtn.alpha = 0;
            _editTitleBtn.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)setGuideSummary:(MyGuideSummary *)guideSummary
{
    _guideSummary = guideSummary;
    [_titleBtn setTitle:[NSString stringWithFormat:@"%d天", _guideSummary.dayCount] forState:UIControlStateNormal];
    _descLabel.text = _guideSummary.summary;
    TaoziImage *image = [_guideSummary.images firstObject];
    [_headerImageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:nil];
    _timeLabel.text = [NSString stringWithFormat:@"%@", _guideSummary.updateTimeStr];
    [_titleBtn setTitle:_guideSummary.title forState:UIControlStateNormal];
    
}
@end
