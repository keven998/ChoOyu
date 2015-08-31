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
    
    // 5.好友和发送
    UIButton *friendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [friendBtn setTitle:@"好友" forState:UIControlStateNormal];
    [friendBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [friendBtn setImage:[UIImage imageNamed:@"add_friend"] forState:UIControlStateNormal];
    [friendBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5.7, 0, 0)];
    self.friendBtn = friendBtn;
    self.friendBtn.layer.borderColor = APP_THEME_COLOR.CGColor;
    self.friendBtn.layer.borderWidth = 1.0;
    self.friendBtn.layer.cornerRadius = 7.0;
    self.friendBtn.layer.masksToBounds = YES;
    [self addSubview:friendBtn];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendBtn.backgroundColor = APP_THEME_COLOR;
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setImage:[UIImage imageNamed:@"massage"] forState:UIControlStateNormal];
    [sendBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5.7, 0, 0)];
    self.sendBtn = sendBtn;
    self.sendBtn.layer.cornerRadius = 7.0;
    self.sendBtn.layer.masksToBounds = YES;
    [self addSubview:sendBtn];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.age.frame = CGRectMake(20, 0, 20, 40);
    self.sexImage.frame = CGRectMake(CGRectGetMaxX(self.age.frame), 14, 12.6, 12.9);
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
    
    [self setNeedsDisplay];
}

- (void)setAccountModel:(AccountModel *)accountModel
{
    _accountModel = accountModel;
    
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
    
    self.age.text = [NSString stringWithFormat:@"%d",age];
    self.constellation.text = [FrendModel costellationDescWithBirthday:accountModel.birthday];
    self.city.text = accountModel.residence;
    
    [self setNeedsDisplay];

}

@end
