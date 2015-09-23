//
//  TopImageView.m
//  CityDetailHeaderView
//
//  Created by 冯宁 on 15/9/21.
//  Copyright © 2015年 PeachTravel. All rights reserved.
//

#import "TopImageView.h"
#import "ArgumentsOfCityDetailHeaderView.h"
#import "Constants.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface TopImageView ()

@property (nonatomic, strong) NSArray* imageViewArray;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UILabel* detailLabel;

@end

@implementation TopImageView

- (void)layoutSubviews{
    [super layoutSubviews];
    [self setUpViews];
    [self setUpShadows];
}

- (void)setUpShadows {
    
//    self.backgroundColor = [UIColor whiteColor];
    self.layer.backgroundColor = [UIColor whiteColor].CGColor;
    
    self.layer.cornerRadius = 4;
//    self.clipsToBounds = YES;
    
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowRadius = 0.5;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.2;
    
}



- (void)setUpViews{
    
    for (UIImageView* imageView in self.imageViewArray) {
        [self addSubview:imageView];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    }
    NSDictionary* metrics = @{@"margins":[NSNumber numberWithInteger:MARGIN_S],@"marginm":[NSNumber numberWithInteger:MARGIN_M],@"titleSize":@TITLE_FONT_SIZE,@"detailSize":@DETAIL_FONT_SIZE};
    
    for (int i = 0; i < 2; i++) {
        NSDictionary* dict = @{@"a":self.imageViewArray[i * 3],@"b":self.imageViewArray[i * 3 + 1],@"c":self.imageViewArray[i * 3 + 2]};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==marginm)-[a]-(==margins)-[b(a)]-(==margins)-[c(a)]-(==marginm)-|" options:0 metrics:metrics views:dict]];
        
        if (i == 0) {
            for (int x = 0 ; x < 3; x++) {
                [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageViewArray[i * 3 + x] attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:MARGIN_S]];
            }
            continue;
        }
        for (int x = 0 ; x < 3; x++) {
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.imageViewArray[i * 3 + x] attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-MARGIN_S]];
        }
    }
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.detailLabel];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary* dict = @{@"a":self.imageViewArray[0],@"b":self.imageViewArray[3],@"title":self.titleLabel,@"detail":self.detailLabel};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[a]-[title(==titleSize)]-[detail(==detailSize)]-[b]" options:0 metrics:metrics views:dict]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.detailLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
}

#pragma mark - setter & getter

- (UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:TITLE_FONT_SIZE];
        _titleLabel.textColor = TEXT_COLOR_TITLE;
        _titleLabel.text = @"中国 · 甘肃 · 那然色不似太尹布拉格";
    }
    return _titleLabel;
}

- (UILabel *)detailLabel{
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:DETAIL_FONT_SIZE];
        _detailLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
        _detailLabel.text = @"~参考游玩时间 · 2天~";
    }
    return _detailLabel;
}

- (NSArray *)imageViewArray{
    if (_imageViewArray == nil) {
        NSMutableArray* tempArray = [NSMutableArray array];
        for (int i = 0; i < 6; i++) {
            UIImageView* imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.layer.cornerRadius = 4;
            imageView.clipsToBounds = YES;
            imageView.backgroundColor = RANDOMCOLOR;
            [tempArray addObject:imageView];
        }
        _imageViewArray = [tempArray copy];
    }
    return _imageViewArray;
}

- (void)setCityPoi:(CityPoi *)cityPoi{
    _cityPoi = cityPoi;
    //
    //    albumView.title = _cityPoi.zhName;
    //    albumView.subTitle = [NSString stringWithFormat:@"~建议旅行 · %@~", _cityPoi.timeCostDesc];
    //    albumView.images = _cityPoi.images;
    self.titleLabel.text = _cityPoi.zhName;
    self.detailLabel.text = [NSString stringWithFormat:@"~建议旅行 · %@~", _cityPoi.timeCostDesc];
    NSLog(@"%@",_cityPoi.images);
    for (int i = 0; i < self.imageViewArray.count; i++) {
        UIImageView* imageView = self.imageViewArray[i];
        TaoziImage* image = _cityPoi.images[i];
        [imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl] placeholderImage:[UIImage imageNamed:@"city_bg_photo_default.png"]];
    }
}

@end
