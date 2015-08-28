//
//  GuiderProfileHeaderView.m
//  PeachTravel
//
//  Created by 王聪 on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderProfileHeaderView.h"
#import "PeachTravel-Swift.h"

@implementation GuiderProfileHeaderView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupDetailInfo];
    }
    return self;
}

#pragma mark - 设置视图
- (void)setupDetailInfo
{
    // 1.年龄
    UILabel *age = [[UILabel alloc] init];
    age.text = @"年龄";
    self.age = age;
    [self addSubview:age];
    
    // 2.性别
    UIImageView *sexImage = [[UIImageView alloc] init];
    self.sexImage = sexImage;
    [self addSubview:sexImage];
    
    // 3.星座
    UILabel *constellation = [[UILabel alloc] init];
    constellation.text = @"星座";
    self.constellation = constellation;
    [self addSubview:constellation];

    // 4.城市
    UILabel *city = [[UILabel alloc] init];
    city.text = @"北京市";
    self.city = city;
    [self addSubview:city];
    
    // 5.好友和发送
    UIButton *friendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [friendBtn setTitle:@"好友" forState:UIControlStateNormal];
    [friendBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [friendBtn setImage:[UIImage imageNamed:@"add_friend"] forState:UIControlStateNormal];
    self.friendBtn = friendBtn;
    self.friendBtn.layer.borderColor = APP_THEME_COLOR.CGColor;
    self.friendBtn.layer.borderWidth = 1.0;
    self.friendBtn.layer.cornerRadius = 7.0;
    self.friendBtn.layer.masksToBounds = YES;
    [self addSubview:friendBtn];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.backgroundColor = APP_THEME_COLOR;
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setImage:[UIImage imageNamed:@"plan"] forState:UIControlStateNormal];
    self.sendBtn = sendBtn;
    self.sendBtn.layer.cornerRadius = 7.0;
    self.sendBtn.layer.masksToBounds = YES;
    [self addSubview:sendBtn];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.age.frame = CGRectMake(20, 0, 30, 40);
    self.sexImage.frame = CGRectMake(CGRectGetMaxX(self.age.frame), 10, 20, 20);
    self.constellation.frame = CGRectMake(CGRectGetMaxX(self.sexImage.frame)+10, 0, 60, 40);
    self.city.frame = CGRectMake(CGRectGetMaxX(self.constellation.frame), 0, 200, 40);
    
    self.friendBtn.frame = CGRectMake(10, CGRectGetMaxY(self.age.frame), kWindowWidth * 0.5 - 20, 35);
    self.sendBtn.frame = CGRectMake(kWindowWidth * 0.5 + 10, CGRectGetMaxY(self.age.frame), kWindowWidth * 0.5 - 20, 35);
}

- (void)setUserInfo:(FrendModel *)userInfo
{
    _userInfo = userInfo;
    
    if ([userInfo.sex isEqualToString:@"M"]) {
        self.sexImage.image = [UIImage imageNamed:@"boy"];
    } else {
        self.sexImage.image = [UIImage imageNamed:@"girl"];
    }
    self.age.text = [NSString stringWithFormat:@"%ld",userInfo.age];
    
    self.constellation.text = userInfo.constellation;
    self.city.text = userInfo.residence;
}

@end
