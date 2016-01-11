//
//  DXChatBarMoreViewAddBtnCell.m
//  PeachTravel
//
//  Created by 冯宁 on 15/9/17.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "DXChatBarMoreViewAddBtnCell.h"

@interface DXChatBarMoreViewAddBtnCell ()

@property (nonatomic, strong) UIButton* imageBtn;
@property (nonatomic, strong) UILabel* titlelLbel;

@end

@implementation DXChatBarMoreViewAddBtnCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self prepareSubviews];
    }
    return self;
}

- (void)prepareSubviews{
    [self.contentView addSubview:self.imageBtn];
    [self.contentView addSubview:self.titlelLbel];
    self.imageBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.titlelLbel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* dict = @{@"btn":self.imageBtn,@"label":self.titlelLbel};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[btn]-0-[label(18)]-0-|" options:0 metrics:nil views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[label]-0-|" options:0 metrics:nil views:dict]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.imageBtn attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
}

- (void)btnClickEvent{
    if ([self.delegate respondsToSelector:@selector(CellClickEventWithTag:)]) {
        [self.delegate CellClickEventWithTag:self.tag];
    }
}

#pragma mark - setter & getter

- (void)setData:(NSDictionary *)data{
    _data = data;
    [self.imageBtn setImage:[UIImage imageNamed:_data[@"picN"]] forState:UIControlStateNormal];
    self.titlelLbel.text = _data[@"title"];
}

- (UIButton *)imageBtn{
    if (_imageBtn == nil) {
        _imageBtn = [[UIButton alloc] init];
//        _imageBtn.enabled = NO;
        [_imageBtn addTarget:self action:@selector(btnClickEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _imageBtn;
}

- (UILabel *)titlelLbel{
    if (_titlelLbel == nil) {
        _titlelLbel = [[UILabel alloc] init];
        _titlelLbel.textAlignment = NSTextAlignmentCenter;
        _titlelLbel.font = [UIFont systemFontOfSize:12];
        _titlelLbel.textColor = COLOR_TEXT_I;
    }
    return _titlelLbel;
}

@end
