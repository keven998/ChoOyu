//
//  CityDetailHeaderCircleBtnCell.m
//  CityDetailHeaderView
//
//  Created by 冯宁 on 15/9/22.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import "CityDetailHeaderCircleBtnCell.h"
#import "Constants.h"
#import "ArgumentsOfCityDetailHeaderView.h"

@interface CityDetailHeaderCircleBtnCell ()

@property (nonatomic, strong) UIButton* imageBtn;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) NSLayoutConstraint* imageWidth;
@property (nonatomic, strong) NSLayoutConstraint* imageHeight;


@end

@implementation CityDetailHeaderCircleBtnCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUpViews];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size{
    
    [self.imageBtn sizeToFit];
    [self.titleLabel sizeToFit];
    
    CGFloat width = CGRectGetMaxX(self.imageBtn.frame) > CGRectGetMaxX(self.titleLabel.frame) ? CGRectGetMaxX(self.imageBtn.frame): CGRectGetMaxX(self.titleLabel.frame);
    CGFloat height = CGRectGetMaxY(self.titleLabel.frame);
    
    return CGSizeMake(width, height);
    
}

- (void)setUpViews {
    
    [self.contentView addSubview:self.imageBtn];
    [self.contentView addSubview:self.titleLabel];
    
    self.imageBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* dict = @{@"image":self.imageBtn,@"title":self.titleLabel};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[image]" options:0 metrics:nil views:dict]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[title]-0-|" options:0 metrics:nil views:dict]];
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
//    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imageBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.imageBtn attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    self.imageWidth = [NSLayoutConstraint constraintWithItem:self.imageBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:42];
    self.imageHeight = [NSLayoutConstraint constraintWithItem:self.imageBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:42];
    [self.contentView addConstraint:self.imageWidth];
    [self.contentView addConstraint:self.imageHeight];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[image]-10-[title]" options:0 metrics:nil views:dict]];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
//    [self.imageBtn touchesBegan:touches withEvent:event];
    self.imageBtn.highlighted = YES;
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
//    [self.imageBtn touchesEnded:touches withEvent:event];
    self.imageBtn.highlighted = NO;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView* hitView = [super hitTest:point withEvent:event];
    if (hitView == self.imageBtn) {
        return self;
    }
    return nil;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer{
    [super layoutSublayersOfLayer:layer];
}

#pragma mark - setter & getter
- (void)setPicH:(UIImage *)picH{
    
    [self.imageBtn setImage:picH forState:UIControlStateHighlighted];
}
- (void)setPicN:(UIImage *)picN{
    [self.imageBtn setImage:picN forState:UIControlStateNormal];
    self.imageHeight.constant = picN.size.height;
    self.imageWidth.constant = picN.size.width;
    [self.contentView layoutIfNeeded];
}
- (void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
}
- (UIButton *)imageBtn{
    if (_imageBtn == nil) {
        _imageBtn = [[UIButton alloc] init];
        _imageBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageBtn;
}
- (UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        _titleLabel.font = [UIFont systemFontOfSize:DESCRIPTION_FONT_SIZE];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end
