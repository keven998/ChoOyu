//
//  CityDetailLoadMoreCell.m
//  PeachTravel
//
//  Created by 冯宁 on 15/9/21.
//  Copyright © 2015年 com.aizou.www. All rights reserved.
//

#import "CityDetailLoadMoreCell.h"

@interface CityDetailLoadMoreCell ()
@property (nonatomic, strong) UIView* leadView;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* allLabel;
@property (nonatomic, strong) UIImageView* arrowImageView;

@end




@implementation CityDetailLoadMoreCell

//- (instancetype)initWithFrame:(CGRect)frame{
//    if (self = [super initWithFrame:frame]) {
//        [self prepareViews];
//    }
//    return self;
//}
- (void)layoutSubviews{
    [self prepareViews];
}


- (void)prepareViews {
    [self.contentView addSubview:self.leadView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.allLabel];
    [self.contentView addSubview:self.arrowImageView];
    
    self.leadView.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.allLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.arrowImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* dict = @{@"lead":self.leadView,@"title":self.titleLabel,@"all":self.allLabel,@"arrow":self.arrowImageView};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0.7-[lead(3.3)]-18-[title]" options:0 metrics:nil views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[all]-6-[arrow]-11-|" options:0 metrics:nil views:dict]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.leadView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.allLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.arrowImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.leadView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:21]];
    
    
}

#pragma mark - setter & getter
- (UIView *)leadView{
    if (_leadView == nil) {
        _leadView = [[UIView alloc] init];
        _leadView.backgroundColor = APP_THEME_COLOR;
    }
    return _leadView;
}
- (UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = COLOR_TEXT_II;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.text = @"当地达人";
    }
    return _titleLabel;
}
- (UILabel *)allLabel{
    if (_allLabel == nil) {
        _allLabel = [[UILabel alloc] init];
        _allLabel.font = [UIFont systemFontOfSize:16];
        _allLabel.textColor = APP_THEME_COLOR;
        _allLabel.text = @"全部";
    }
    return _allLabel;
}
- (UIImageView *)arrowImageView{
    if (_arrowImageView == nil) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.image = [UIImage imageNamed:@"arrow"];
    }
    return _arrowImageView;
}

@end
