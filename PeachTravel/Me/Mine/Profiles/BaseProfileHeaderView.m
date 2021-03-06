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
    age.textAlignment = NSTextAlignmentCenter;
    age.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0];
    age.textColor = UIColorFromRGB(0xFFFFFF);
    self.age = age;
    [self addSubview:age];
    
    // 2.性别
    UIImageView *sexImage = [[UIImageView alloc] init];
    self.sexImage = sexImage;
    [self addSubview:sexImage];
    
    // 3.等级
    UIImageView *level = [[UIImageView alloc] init];
    level.image = [UIImage imageNamed:@"level"];
    self.level = level;
    [self addSubview:level];
    
    // 等级内容
    UILabel *levelContent = [[UILabel alloc] init];
    levelContent.text = @"V9";
    levelContent.textAlignment = NSTextAlignmentCenter;
    levelContent.font = [UIFont fontWithName:@"Helvetica-Bold" size:9.0];
    levelContent.textColor = UIColorFromRGB(0xFFFFFF);
    self.levelContent = levelContent;
    [self addSubview:levelContent];
    
    // 4.星座
    UIImageView *constellation = [[UIImageView alloc] init];
    self.constellation = constellation;
    [self addSubview:constellation];
    
    // 5.城市
    UILabel *city = [[UILabel alloc] init];
    city.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    city.textColor = UIColorFromRGB(0x969696);
    city.text = @"北京市";
    self.city = city;
    
    // 6.昵称
    UILabel *nickName = [[UILabel alloc] init];
    nickName.text = @"娜美";
    nickName.textAlignment = NSTextAlignmentCenter;
    nickName.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
    nickName.textColor = UIColorFromRGB(0xFFFFFF);
    self.nickName = nickName;
    [self addSubview:nickName];
    
    // 7.头像
    UIImageView *avatar = [[UIImageView alloc] init];
    avatar.contentMode = UIViewContentModeScaleAspectFill;
    avatar.layer.cornerRadius = 44;
    avatar.layer.masksToBounds = YES;
    self.avatar = avatar;
    [self addSubview:avatar];
}

// 布局
- (void)layoutSubviews
{
    [super layoutSubviews];
        
    // 1.头像
    CGFloat avatarW = 88;
    CGFloat avatarH = 88;
    CGFloat avatarX = (kWindowWidth-avatarW)*0.5;
    CGFloat avatarY = 115;
    self.avatar.frame = CGRectMake(avatarX, avatarY, avatarW, avatarH);
    
    // 2.昵称
    CGFloat nickNameW = kWindowWidth;
    CGFloat nickNameH = 21;
    CGFloat nickNameX = 0;
    CGFloat nickNameY = CGRectGetMaxY(self.avatar.frame)+5;
    self.nickName.frame = CGRectMake(nickNameX, nickNameY, nickNameW, nickNameH);
    
    // 3.年龄
    CGFloat ageW = kWindowWidth;
    CGFloat ageH = 21;
    CGFloat ageX = 0;
    CGFloat ageY = CGRectGetMaxY(self.nickName.frame)+10;
    self.age.frame = CGRectMake(ageX, ageY, ageW, ageH);
    
    // 4.城市
    CGFloat cityW = 90;
    CGFloat cityH = cityW;
    CGFloat cityX = (kWindowWidth-avatarW)*0.5;
    CGFloat cityY = 100;
    self.city.frame = CGRectMake(cityX, cityY, cityW, cityH);
    
    // 5.性别
    CGFloat sexW = 18;
    CGFloat sexH = sexW;
    CGFloat sexX = (kWindowWidth-sexW)*0.5;
    CGFloat sexY = CGRectGetMaxY(self.age.frame)+10;
    self.sexImage.frame = CGRectMake(sexX, sexY, sexW, sexH);
    
    // 6.等级
    CGFloat levelW = 18;
    CGFloat levelH = levelW;
    CGFloat levelX = sexX-32;
    CGFloat levelY = sexY;
    self.level.frame = CGRectMake(levelX, levelY, levelW, levelH);
    self.levelContent.frame = self.level.frame;
    
    // 7.星座
    CGFloat constellationW = 18;
    CGFloat constellationH = constellationW;
    CGFloat constellationX = sexX+32;
    CGFloat constellationY = sexY;
    self.constellation.frame = CGRectMake(constellationX, constellationY, constellationW, constellationH);
}

- (void)setUserInfo:(FrendModel *)userInfo
{
    _userInfo = userInfo;
    
    // 设置数据
    NSURL *url = [NSURL URLWithString:userInfo.avatar];
    [self.avatar sd_setImageWithURL:url];
    
    self.nickName.text = userInfo.nickName;
    NSLog(@"%@",userInfo.residence);
    self.age.text = [NSString stringWithFormat:@"%ld岁 现居住在 %@",userInfo.age,userInfo.residence];
    
    if ([userInfo.sex isEqualToString:@"M"]) {
        self.sexImage.image = [UIImage imageNamed:@"boy"];
    } else {
        self.sexImage.image = [UIImage imageNamed:@"girl"];
    }
    
    NSString *constellationImageName = [FrendModel bigCostellationImageNameWithBirthday:userInfo.birthday];
    self.constellation.image = [UIImage imageNamed:constellationImageName];
    
    self.levelContent.text = [NSString stringWithFormat:@"V%ld",_userInfo.level];
}

- (void)setAccountModel:(AccountModel *)accountModel
{
    _accountModel = accountModel;
    // 设置数据
    NSURL *url = [NSURL URLWithString:accountModel.avatar];
    [self.avatar sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    
    self.nickName.text = accountModel.nickName;
    if (accountModel.gender == Male) {
        self.sexImage.image = [UIImage imageNamed:@"boy"];
    } else {
        self.sexImage.image = [UIImage imageNamed:@"girl"];
    }
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy/MM/dd";
    NSDate *date = [format dateFromString:accountModel.birthday];
    
    NSTimeInterval dateDiff = [date timeIntervalSinceNow];
    
    int age= -trunc(dateDiff/(60*60*24))/365;
    
    if (accountModel.residence == (id)[NSNull null] || accountModel.residence.length == 0) {
        self.age.text = [NSString stringWithFormat:@"%d岁 现居住在", age];
    } else {
        self.age.text = [NSString stringWithFormat:@"%d岁 现居住在%@",age,accountModel.residence];
    }
    
    
    NSString *constellationImageName = [FrendModel bigCostellationImageNameWithBirthday:accountModel.birthday];
    self.constellation.image = [UIImage imageNamed:constellationImageName];
    
    self.levelContent.text = [NSString stringWithFormat:@"V%ld",_accountModel.level];
}

@end
