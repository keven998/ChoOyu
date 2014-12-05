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
//    _editTitleBtn.alpha = 0;
    self.countBtn.layer.cornerRadius = 25.0;
    self.countBtn.clipsToBounds = YES;
    self.countBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    self.countBtn.layer.borderWidth = 2.0;
    self.countBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.deleteBtn.layer.cornerRadius = 15.0;
//    self.editTitleBtn.layer.cornerRadius = 10.0;
    
    _frameView.layer.cornerRadius = 2.0;
    _frameView.layer.shadowColor = UIColorFromRGB(0xdcdcdc).CGColor;
    _frameView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    _frameView.layer.shadowRadius = 1.0;
    _frameView.layer.shadowOpacity = 1.0;
    
}

//- (void)layoutSubviews {
//    UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRoundedRect:_headerImageView.frame
//                                                      byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
//                                                            cornerRadii:CGSizeMake(2, 2)];
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.frame = _headerImageView.layer.frame;
//    maskLayer.path = bezierPath.CGPath;
//    _headerImageView.layer.mask = maskLayer;
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setIsEditing:(BOOL)isEditing
{
    _isEditing = isEditing;
    if (_isEditing) {
        [_titleBtn setImage:[UIImage imageNamed:@"ic_clear_cache.png"] forState:UIControlStateNormal];
        _titleBtn.imageView.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            _deleteBtn.alpha = 0.7;
            _titleBtn.imageView.alpha = 0.7;
        } completion:^(BOOL finished) {
            _deleteBtn.alpha = 1;
            _titleBtn.imageView.alpha = 1.0;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            _deleteBtn.alpha = 0;
//            _editTitleBtn.alpha = 0;
            _titleBtn.imageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [_titleBtn setImage:nil forState:UIControlStateNormal];
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
