//
//  FavoriteTableViewCell.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/2.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "FavoriteTableViewCell.h"

@implementation FavoriteTableViewCell


- (void)awakeFromNib {
    _deleteBtn.alpha = 0;
    self.deleteBtn.layer.cornerRadius = 15.0;
    
    _frameView.layer.cornerRadius = 2.0;
    _frameView.layer.shadowColor = APP_DIVIDER_COLOR.CGColor;
    _frameView.layer.shadowOffset = CGSizeMake(0.0, 0.5);
    _frameView.layer.shadowOpacity = 1.0;
    _frameView.layer.shadowRadius = 0.5;

    _standardImageView.clipsToBounds = YES;
    _contentDescExpandView.titleLabel.numberOfLines = 0;
    [_contentDescExpandView setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    [_contentDescExpandView setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateSelected];
    _contentDescExpandView.clipsToBounds = YES;
    _contentDescExpandView.selected = NO;
    [_contentDescExpandView.titleLabel sizeToFit];
}

- (void)setIsEditing:(BOOL)isEditing
{
    _isEditing = isEditing;
    if (_isEditing) {
        [UIView animateWithDuration:0.3 animations:^{
            _deleteBtn.alpha = 0.7;

        } completion:^(BOOL finished) {
            _deleteBtn.alpha = 1;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            _deleteBtn.alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
    }
}


- (void) resizeHeight:(BOOL)resize {
    if (resize) {
        _contentDescExpandView.titleLabel.numberOfLines = 0;
        CGSize size = [_contentDescExpandView.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : _contentDescExpandView.titleLabel.font}];
        _contentDescExpandView.frame = CGRectMake(_contentDescExpandView.frame.origin.x, _contentDescExpandView.frame.origin.y, _contentDescExpandView.frame.size.width, size.height);
        [_contentDescExpandView.titleLabel sizeToFit];
        self.contentView.frame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, _contentDescExpandView.frame.origin.y + _contentDescExpandView.frame.size.height + 10.0);
    } else {
        _contentDescExpandView.titleLabel.numberOfLines = 2;
        self.contentView.frame = CGRectMake(0.0, 0.0, self.contentView.frame.size.width, 200.0);
    }
}

@end
