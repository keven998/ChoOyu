//
//  BaseProfileHeaderView.m
//  PeachTravel
//
//  Created by 王聪 on 15/9/6.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "BaseProfileHeaderView.h"

@implementation BaseProfileHeaderView

+ (BaseProfileHeaderView *)profileHeaderView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"BaseProfileHeaderView" owner:nil options:nil] lastObject];
}

#pragma mark - 初始化视图
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupMainView];
    }
    return self;
}

- (void)setupMainView
{
    // 1.年龄
    UILabel *age = [[UILabel alloc] init];
    age.text = @"年龄";
    age.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    age.textColor = UIColorFromRGB(0x969696);
    self.age = age;
    [self addSubview:age];
    
    // 2.性别
    UIImageView *sexImage = [[UIImageView alloc] init];
    self.sexImage = sexImage;
    [self addSubview:sexImage];
    
    // 3.星座
    UILabel *constellation = [[UILabel alloc] init];
    constellation.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    constellation.textColor = UIColorFromRGB(0x969696);
    constellation.text = @"星座";
    self.constellation = constellation;
    [self addSubview:constellation];
    
    // 4.城市
    UILabel *city = [[UILabel alloc] init];
    city.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    city.textColor = UIColorFromRGB(0x969696);
    city.text = @"北京市";
    self.city = city;
    [self addSubview:city];
}

@end
