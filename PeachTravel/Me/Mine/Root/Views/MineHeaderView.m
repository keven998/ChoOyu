//
//  MineHeaderView.m
//  PeachTravel
//
//  Created by 王聪 on 15/9/2.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "MineHeaderView.h"
#import "PeachTravel-swift.h"
@implementation MineHeaderView

#pragma mark - lifeCycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
        self.account = [AccountManager shareAccountManager].account;
        [self setupMainView];
    }
    return self;
}

- (void)setupMainView
{
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:_contentView];
    // 1.头像
    UIImageView *avatar = [[UIImageView alloc] init];
    avatar.layer.cornerRadius = 65*0.5;
    avatar.layer.masksToBounds = YES;
    self.avatar = avatar;
    NSURL *url = [NSURL URLWithString:self.account.avatar];
    [self.avatar sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"ic_home_avatar_unknown.png"]];
    [_contentView addSubview:avatar];
    
    // 2.昵称
    UILabel *nickName = [[UILabel alloc] init];
    nickName.font = [UIFont boldSystemFontOfSize:16.0];
    nickName.textColor = UIColorFromRGB(0xFFFFFF);
    nickName.text = self.account.nickName;
    self.nickName = nickName;
    [_contentView addSubview:nickName];
    
    // 3.用户Id
    UILabel *userId = [[UILabel alloc] init];
    userId.font = [UIFont boldSystemFontOfSize:12.0];
    userId.textColor = UIColorFromRGB(0xFFFFFF);
    userId.text = [NSString stringWithFormat:@"%ld",self.account.userId];
    self.userId = userId;
    [_contentView addSubview:userId];
    
    // 4.性别
    UILabel *sex = [[UILabel alloc] init];
    sex.font = [UIFont boldSystemFontOfSize:12.0];
    sex.textColor = UIColorFromRGB(0xFFFFFF);
    if (self.account.gender == Male) {
        sex.text = @"男";
    } else {
        sex.text = @"女";
    }
    self.sex = sex;
    [_contentView addSubview:sex];
    
    // 5.星座
    UILabel *costellation = [[UILabel alloc] init];
    costellation.font = [UIFont boldSystemFontOfSize:12.0];
    costellation.textColor = UIColorFromRGB(0xFFFFFF);
    costellation.text = [FrendModel costellationDescWithBirthday:self.account.birthday];
    self.costellation = costellation;
    [_contentView addSubview:costellation];
    
    // 6.等级
    UILabel *level = [[UILabel alloc] init];
    level.font = [UIFont boldSystemFontOfSize:12.0];
    level.textColor = UIColorFromRGB(0xFFFFFF);
    level.text = @"LV1";
    self.level = level;
    [_contentView addSubview:level];
    
    [self updateSubviewsFrame];

}

- (void)updateSubviewsFrame
{
    CGFloat contentH = self.frame.size.height;
    
    CGFloat avatarW = 65;
    self.avatar.frame = CGRectMake(15, contentH-avatarW-13, avatarW, avatarW);
    
    CGSize size = CGSizeMake(kWindowWidth - 40,CGFLOAT_MAX);//LableWight标签宽度，固定的
    //计算实际frame大小，并将label的frame变成实际大小
    NSDictionary *dict = @{NSFontAttributeName: [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0]};
    CGSize nickNameSize = [self.account.nickName boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
    self.nickName.frame = CGRectMake(CGRectGetMaxX(self.avatar.frame)+5, contentH-16-46, nickNameSize.width, 16);
    
    self.userId.frame = CGRectMake(CGRectGetMaxX(self.nickName.frame)+10, contentH-12-46, 100, 12);
    self.sex.frame = CGRectMake(CGRectGetMaxX(self.avatar.frame)+5, CGRectGetMaxY(self.nickName.frame)+10, 12, 12);
    self.costellation.frame = CGRectMake(CGRectGetMaxX(self.sex.frame)+12, CGRectGetMaxY(self.nickName.frame)+10, 36, 12);
    self.level.frame = CGRectMake(CGRectGetMaxX(self.costellation.frame)+12, CGRectGetMaxY(self.nickName.frame)+10, 21+16, 12);
}

- (void)setAccount:(AccountModel *)account
{
    _account = account;
}

@end
