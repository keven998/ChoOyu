//
//  BaseProfileHeaderView.m
//  PeachTravel
//
//  Created by 王聪 on 15/9/6.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "BaseProfileHeaderView.h"
#import "PeachTravel-Swift.h"

@implementation BaseProfileHeaderView

+ (BaseProfileHeaderView *)profileHeaderView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"BaseProfileHeaderView" owner:nil options:nil] lastObject];
}

#pragma mark - 初始化视图
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
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
    UIImageView *constellation = [[UIImageView alloc] init];
    self.constellation = constellation;
    [self addSubview:constellation];
    
    // 4.城市
    UILabel *city = [[UILabel alloc] init];
    city.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    city.textColor = UIColorFromRGB(0x969696);
    city.text = @"北京市";
    self.city = city;
//    [self addSubview:city];
    
    // 5.等级
    UIImageView *level = [[UIImageView alloc] init];
    self.level = level;
    [self addSubview:level];
    
    // 6.昵称
    UILabel *nickName = [[UILabel alloc] init];
    nickName.text = @"娜美";
    nickName.textAlignment = NSTextAlignmentCenter;
    nickName.font = [UIFont fontWithName:@"Helvetica-Bold" size:25.0];
    nickName.textColor = UIColorFromRGB(0x969696);
    self.nickName = nickName;
    [self addSubview:nickName];
    
    // 7.头像
    UIImageView *avatar = [[UIImageView alloc] init];
    avatar.contentMode = UIViewContentModeScaleAspectFill;
    self.avatar = avatar;
    [self addSubview:avatar];
}

// 布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    CGFloat selfH = self.frame.size.height;
    
    // 1.头像
    CGFloat avatarW = 90;
    CGFloat avatarH = avatarW;
    CGFloat avatarX = (kWindowWidth-avatarW)*0.5;
    CGFloat avatarY = 100;
    self.avatar.frame = CGRectMake(avatarX, avatarY, avatarW, avatarH);
    
    // 2.昵称
    CGFloat nickNameW = 100;
    CGFloat nickNameH = 21;
    CGFloat nickNameX = (kWindowWidth-avatarW)*0.5;
    CGFloat nickNameY = CGRectGetMaxY(self.avatar.frame)+10;
    self.nickName.frame = CGRectMake(nickNameX, nickNameY, nickNameW, nickNameH);
    
    // 3.年龄
    CGFloat ageW = 200;
    CGFloat ageH = 21;
    CGFloat ageX = (kWindowWidth-avatarW)*0.5;
    CGFloat ageY = CGRectGetMaxY(self.nickName.frame)+10;
    self.age.frame = CGRectMake(ageX, ageY, ageW, ageH);
    
    // 4.城市
    CGFloat cityW = 90;
    CGFloat cityH = cityW;
    CGFloat cityX = (kWindowWidth-avatarW)*0.5;
    CGFloat cityY = 100;
    self.city.frame = CGRectMake(cityX, cityY, cityW, cityH);
    
    // 5.等级
    CGFloat levelW = 90;
    CGFloat levelH = avatarW;
    CGFloat levelX = (kWindowWidth-avatarW)*0.5;
    CGFloat levelY = 100;
    self.level.frame = CGRectMake(levelX, levelY, levelW, levelH);
    
    // 6.性别
    CGFloat sexW = 90;
    CGFloat sexH = avatarW;
    CGFloat sexX = (kWindowWidth-avatarW)*0.5;
    CGFloat sexY = 100;
    self.sexImage.frame = CGRectMake(sexX, sexY, sexW, sexH);
    
    // 7.星座
    CGFloat constellationW = 90;
    CGFloat constellationH = avatarW;
    CGFloat constellationX = (kWindowWidth-avatarW)*0.5;
    CGFloat constellationY = 100;
    self.constellation.frame = CGRectMake(constellationX, constellationY, constellationW, constellationH);
}

- (void)setUserInfo:(FrendModel *)userInfo
{
    _userInfo = userInfo;
    
    // 设置数据
    NSURL *url = [NSURL URLWithString:userInfo.avatar];
    [self.avatar sd_setImageWithURL:url];
    
    self.nickName.text = userInfo.nickName;
    self.age.text = [NSString stringWithFormat:@"%ld岁 现居住在 %@",userInfo.age,userInfo.residence];
    
    if ([userInfo.sex isEqualToString:@"M"]) {
        self.sexImage.image = [UIImage imageNamed:@"boy"];
    } else {
        self.sexImage.image = [UIImage imageNamed:@"girl"];
    }
    
    NSString *constellationImageName = [FrendModel bigCostellationImageNameWithBirthday:userInfo.birthday];
    NSURL *constellationUrl = [NSURL URLWithString:constellationImageName];
    [self.constellation sd_setImageWithURL:constellationUrl];
}

@end
