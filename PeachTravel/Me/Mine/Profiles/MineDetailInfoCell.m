//
//  MineDetailInfoCell.m
//  PeachTravel
//
//  Created by 王聪 on 8/31/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "MineDetailInfoCell.h"
#import "GuiderProfileHeaderView.h"
#import "GuiderProfileImageView.h"
#import "PeachTravel-Swift.h"
#import "TaoziCollectionLayout.h"
#import "GuiderDetailCollectionCell.h"

@implementation MineDetailInfoCell

#pragma mark - 初始化方法
+ (id)guiderDetailInfo
{
    return [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // 1.加载View视图
        [self setupDetailInfo];
    }
    return self;
}

#pragma mark - 加载View视图
- (void)setupDetailInfo {
    
    // 1.头部图片
    GuiderProfileImageView *profileHeader = [[GuiderProfileImageView alloc] init];
    self.profileHeader = profileHeader;
    [self addSubview:profileHeader];
    
    
    // 2.添加用户信息
    UILabel *name = [[UILabel alloc] init];
    name.text = @"特罗迪亚";
    name.font = [UIFont fontWithName:@"STHeitiSC-Light" size:24.0];
    name.textColor = UIColorFromRGB(0x646464);
    self.name = name;
    [self addSubview:name];
    
    //3.加载年龄,星座,城市等信息
    GuiderProfileHeaderView *profileView = [[GuiderProfileHeaderView alloc] init];
    profileView.sendBtn.hidden = YES;
    profileView.friendBtn.hidden = YES;
    self.profileView = profileView;
    [self addSubview:profileView];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.profileHeader.frame = CGRectMake(0, 0, kWindowWidth, kWindowWidth);
    self.name.frame = CGRectMake(26.7, CGRectGetMaxY(self.profileHeader.frame)+12, 200, 25);
    self.profileView.frame = CGRectMake(26.7, CGRectGetMaxY(self.name.frame), kWindowWidth - 26.7*2, 50);
}

#pragma mark - 设置数据
- (void)setAccountModel:(AccountModel *)accountModel
{
    _accountModel = accountModel;
    
    // 设置数据
    NSURL *url = [NSURL URLWithString:accountModel.avatar];
    [self.profileHeader.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"ic_home_avatar_unknown.png"]];
    self.name.text = accountModel.nickName;
}

@end
