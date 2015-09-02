//
//  MineHeaderView.m
//  PeachTravel
//
//  Created by 王聪 on 15/9/2.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "MineHeaderView.h"

@implementation MineHeaderView

#pragma mark - lifeCycle
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
    // 1.头像
    UIImageView *avatar = [[UIImageView alloc] init];
    self.avatar = avatar;
    [self addSubview:avatar];
    
    // 2.昵称
    UILabel *nickName = [[UILabel alloc] init];
    nickName.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0];
    nickName.textColor = UIColorFromRGB(0xFFFFFF);
    nickName.text = @"小明";
    self.nickName = nickName;
    [self addSubview:nickName];
    
    // 3.用户Id
    UILabel *userId = [[UILabel alloc] init];
    userId.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0];
    userId.textColor = UIColorFromRGB(0xFFFFFF);
    userId.text = @"小明";
    self.userId = userId;
    [self addSubview:userId];
    
    // 4.性别
    UILabel *sex = [[UILabel alloc] init];
    sex.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0];
    sex.textColor = UIColorFromRGB(0xFFFFFF);
    sex.text = @"小明";
    self.sex = sex;
    [self addSubview:sex];
    
    // 5.星座
    UILabel *costellation = [[UILabel alloc] init];
    costellation.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0];
    costellation.textColor = UIColorFromRGB(0xFFFFFF);
    costellation.text = @"小明";
    self.costellation = costellation;
    [self addSubview:costellation];
    
    // 6.等级
    UILabel *level = [[UILabel alloc] init];
    level.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0];
    level.textColor = UIColorFromRGB(0xFFFFFF);
    level.text = @"小明";
    self.level = level;
    [self addSubview:level];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat contentH = self.frame.size.height;
    
    CGFloat avatarW = 65;
    self.avatar.frame = CGRectMake(15, contentH-avatarW-13, avatarW, avatarW);
    
//    CGSize size = [self.nickName.text boundingRectWithSize:<#(CGSize)#> options:<#(NSStringDrawingOptions)#> attributes:<#(NSDictionary *)#> context:<#(NSStringDrawingContext *)#>];
    self.nickName.frame = CGRectMake(CGRectGetMaxX(self.avatar.frame), contentH-16-46, 100, 16);
}

@end
