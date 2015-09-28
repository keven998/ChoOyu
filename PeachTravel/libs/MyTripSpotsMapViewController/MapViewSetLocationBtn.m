//
//  MapViewSetLocationBtn.m
//  PeachTravel
//
//  Created by 冯宁 on 15/9/24.
//  Copyright © 2015年 com.aizou.www. All rights reserved.
//

#import "MapViewSetLocationBtn.h"

@interface MapViewSetLocationBtn ()
@property (nonatomic, strong) UIImageView* iconImageView;
@property (nonatomic, strong) UILabel* textLabel;
@property (nonatomic, strong) UIView* maskView;
@end


@implementation MapViewSetLocationBtn

- (instancetype)init{
    if (self = [super init]) {
        [self setUpView];
        self.layer.cornerRadius = 3;
        self.clipsToBounds = YES;
        
    }
    return self;
}

- (void)setUpView{
    [self addSubview:self.maskView];
    [self addSubview:self.iconImageView];
    [self addSubview:self.textLabel];
    
    self.maskView.translatesAutoresizingMaskIntoConstraints = NO;
    self.iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[mask]-0-|" options:0 metrics:nil views:@{@"mask":self.maskView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[mask]-0-|" options:0 metrics:nil views:@{@"mask":self.maskView}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.iconImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:10]];
    
}
- (void)setIsCancelBtn:(BOOL)isCancelBtn{
    if (isCancelBtn) {
        self.textLabel.text = @"取消";
    }else{
        self.textLabel.text = @"定位";
    }
}

- (UIImageView *)iconImageView{
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = [UIImage imageNamed:@"mapMark_GPS"];
    }
    return _iconImageView;
}
- (UILabel *)textLabel{
    if (_textLabel == nil) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:10];
        _textLabel.text = @"定位";
        _textLabel.textColor = [UIColor whiteColor];
    }
    return _textLabel;
}
- (UIView *)maskView{
    if (_maskView == nil) {
        _maskView = [[UIView alloc] init];
        _maskView.alpha = 0.5;
        _maskView.backgroundColor = [UIColor blackColor];
    }
    return _maskView;
}

@end
