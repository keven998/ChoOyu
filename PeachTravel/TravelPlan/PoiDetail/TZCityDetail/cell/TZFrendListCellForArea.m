//
//  TZFrendListCellForArea.m
//  PeachTravel
//
//  Created by 冯宁 on 15/9/21.
//  Copyright © 2015年 com.aizou.www. All rights reserved.
//

#import "TZFrendListCellForArea.h"

@interface TZFrendListCellForArea ()
@property (nonatomic, strong) UILabel* cityAndAgeLabel;
@end

@implementation TZFrendListCellForArea

//- (instancetype)initWithFrame:(CGRect)frame{
//    if (self = [super initWithFrame:frame]) {
//        [self prepareSubViewsForArea];
//    }
//    return self;
//}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self prepareSubViewsForArea];
}

- (void)prepareSubViewsForArea{

    [self.contentView addSubview:self.cityAndAgeLabel];
    
    self.cityAndAgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cityAndAgeLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cityAndAgeLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.cityAndAgeLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.tagCollectionView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    
}

- (void)setModel:(ExpertModel *)model{
    [super setModel:model];
    
    self.cityAndAgeLabel.text = [NSString stringWithFormat:@"%@  %ld岁",model.residence,model.age];
}

- (UILabel *)cityAndAgeLabel{
    if (_cityAndAgeLabel == nil) {
        _cityAndAgeLabel = [[UILabel alloc] init];
        _cityAndAgeLabel.font = [UIFont systemFontOfSize:8];
        _cityAndAgeLabel.textColor = COLOR_TEXT_II;
    }
    return _cityAndAgeLabel;
}

@end
