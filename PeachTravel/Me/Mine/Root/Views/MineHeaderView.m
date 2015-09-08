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
    [_contentView addSubview:avatar];
    
    // 2.昵称
    UILabel *nickName = [[UILabel alloc] init];
    nickName.font = [UIFont boldSystemFontOfSize:16.0];
    nickName.textColor = UIColorFromRGB(0xFFFFFF);
    self.nickName = nickName;
    [_contentView addSubview:nickName];
    
    // 3.用户Id
    UILabel *userId = [[UILabel alloc] init];
    userId.font = [UIFont boldSystemFontOfSize:12.0];
    userId.textColor = UIColorFromRGB(0xFFFFFF);
    self.userId = userId;
    [_contentView addSubview:userId];
    
    // 4.性别
    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.font = [UIFont boldSystemFontOfSize:12.0];
    tempLabel.textColor = UIColorFromRGB(0xFFFFFF);
    self.subtitleLabel = tempLabel;
    [_contentView addSubview:self.subtitleLabel];

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
    self.nickName.frame = CGRectMake(CGRectGetMaxX(self.avatar.frame)+5, contentH-16-46, nickNameSize.width+2, 16);
    
    self.userId.frame = CGRectMake(CGRectGetMaxX(self.nickName.frame)+10, contentH-12-46, 100, 12);
    self.subtitleLabel.frame = CGRectMake(CGRectGetMaxX(self.avatar.frame)+5, CGRectGetMaxY(self.nickName.frame)+10, kWindowWidth-CGRectGetMaxX(self.avatar.frame)-10, 12);
}

- (void)updateContent
{
    NSURL *url = [NSURL URLWithString:self.account.avatar];
    [self.avatar sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avatar_default"]];

    _nickName.text = self.account.nickName;
    _userId.text = [NSString stringWithFormat:@"%ld",self.account.userId];

    NSMutableString *subtitleStr = [[NSMutableString alloc] init];
    
    if (_account.gender == Male) {
        [subtitleStr appendString:@"男  "];
    } else if (_account.gender == Female) {
        [subtitleStr appendString:@"女  "];
    }
    if (_account.birthday) {
        NSString *str = [FrendModel costellationDescWithBirthday:_account.birthday];
        [subtitleStr appendString:[NSString stringWithFormat:@"%@  ", str]];
    }
    if (_account.level) {
        [subtitleStr appendString:[NSString stringWithFormat:@"LV%ld", _account.level]];
    }
    
    self.subtitleLabel.text = subtitleStr;
}

- (void)setAccount:(AccountModel *)account
{
    _account = account;
    [self updateContent];
}

@end
