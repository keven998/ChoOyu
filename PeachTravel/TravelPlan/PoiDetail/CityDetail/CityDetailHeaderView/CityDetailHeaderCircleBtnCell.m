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

@end

@implementation CityDetailHeaderCircleBtnCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUpViews];
    }
    return self;
}

- (void)setUpViews {
    
    [self.contentView addSubview:self.imageBtn];
    [self.contentView addSubview:self.titleLabel];
    
    self.imageBtn.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* dict = @{@"image":self.imageBtn,@"title":self.titleLabel};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[image]-0-|" options:0 metrics:nil views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[title]-0-|" options:0 metrics:nil views:dict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[image]-10-[title]-0-|" options:0 metrics:nil views:dict]];
    
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

#pragma mark - setter & getter
- (void)setPicH:(UIImage *)picH{
    [self.imageBtn setImage:picH forState:UIControlStateHighlighted];
}
- (void)setPicN:(UIImage *)picN{
    [self.imageBtn setImage:picN forState:UIControlStateNormal];
}
- (void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
}
- (UIButton *)imageBtn{
    if (_imageBtn == nil) {
        _imageBtn = [[UIButton alloc] init];
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
