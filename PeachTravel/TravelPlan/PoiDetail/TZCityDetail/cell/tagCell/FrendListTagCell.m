//
//  FrendListTagCell.m
//  PeachTravel
//
//  Created by 冯宁 on 15/9/21.
//  Copyright © 2015年 com.aizou.www. All rights reserved.
//

#import "FrendListTagCell.h"

@interface FrendListTagCell ()

@property (nonatomic, strong) UIView* backView;
@property (nonatomic, strong) UILabel* tagLabel;

@end

@implementation FrendListTagCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self prepareSubviews];
    }
    return self;
}

- (void)prepareSubviews{
    [self.contentView addSubview:self.backView];
    [self.backView addSubview:self.tagLabel];
    
    self.backView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tagLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* dict = @{@"back":self.backView,@"tag":self.tagLabel};
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[back]-0-|" options:0 metrics:nil views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[back]-0-|" options:0 metrics:nil views:dict]];
    [self.backView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4-[tag]-4-|" options:0 metrics:nil views:dict]];
    [self.backView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[tag]-1-|" options:0 metrics:nil views:dict]];
    
    
}


#pragma mark - setter & getter
- (void)setTintColor:(UIColor *)tintColor{
    _tintColor = tintColor;
    
    self.backView.layer.borderColor = tintColor.CGColor;
    self.tagLabel.textColor = tintColor;
    
}
- (void)setTagString:(NSString *)tagString{
    _tagString = tagString;
    self.tagLabel.text = tagString;
}

- (UIView *)backView{
    if (_backView == nil) {
        _backView = [[UIView alloc] init];
        _backView.layer.cornerRadius = 4;
        _backView.layer.borderWidth = 0.5;
    }
    return _backView;
}
- (UILabel *)tagLabel{
    if (_tagLabel == nil) {
        _tagLabel = [[UILabel alloc] init];
        _tagLabel.font = [UIFont systemFontOfSize:10];
    }
    return _tagLabel;
}

@end
