//
//  GuiderProfileHeaderView.m
//  PeachTravel
//
//  Created by 王聪 on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderProfileHeaderView.h"


@implementation GuiderProfileHeaderView

#pragma mark - 初始化

//+ (id)profileHeaderView
//{
//    return [[[NSBundle mainBundle] loadNibNamed:@"GuiderProfileHeaderView" owner:nil options:nil] lastObject];
//}

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
    self.sexImage.backgroundColor = [UIColor redColor];
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
    friendBtn.backgroundColor = [UIColor purpleColor];
    self.friendBtn = friendBtn;
    [self addSubview:friendBtn];
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    sendBtn.backgroundColor = [UIColor blueColor];
    self.sendBtn = sendBtn;
    [self addSubview:sendBtn];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.age.frame = CGRectMake(20, 0, 40, 40);
    self.sexImage.frame = CGRectMake(CGRectGetMaxX(self.age.frame), 0, 40, 40);
    self.constellation.frame = CGRectMake(CGRectGetMaxX(self.sexImage.frame), 0, 60, 40);
    self.city.frame = CGRectMake(CGRectGetMaxX(self.constellation.frame), 0, 200, 40);
    
    self.friendBtn.frame = CGRectMake(10, CGRectGetMaxY(self.age.frame), kWindowWidth * 0.5 - 20, 40);
    self.sendBtn.frame = CGRectMake(kWindowWidth * 0.5 + 10, CGRectGetMaxY(self.age.frame), kWindowWidth * 0.5 - 20, 40);
}

@end
