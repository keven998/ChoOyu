//
//  GuiderDetailInfoCell.m
//  PeachTravel
//
//  Created by 王聪 on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderDetailInfoCell.h"
#import "GuiderProfileHeaderView.h"
#import "GuiderProfileImageView.h"
#import "PeachTravel-Swift.h"
@interface GuiderDetailInfoCell ()

@property (nonatomic, weak)UICollectionView *collectionView;

@end

@implementation GuiderDetailInfoCell

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
    GuiderProfileImageView *profileHeader = [[GuiderProfileImageView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, kWindowWidth)];
    self.profileHeader = profileHeader;
    profileHeader.backgroundColor = [UIColor yellowColor];
    [self addSubview:profileHeader];
    
    
    // 2.添加用户信息
    UILabel *name = [[UILabel alloc] init];
    name.text = @"特罗迪亚";
    name.font = [UIFont boldSystemFontOfSize:26.0];
    name.textColor = TEXT_COLOR_TITLE;
    self.name = name;
    name.frame = CGRectMake(20, CGRectGetMaxY(profileHeader.frame), 200, 50);
    [self addSubview:name];
    
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(name.frame), kWindowWidth, 100) collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor whiteColor];
    [self addSubview:collectionView];
    
    
    //3.加载年龄,星座,城市等信息
    GuiderProfileHeaderView *profileView = [[GuiderProfileHeaderView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(collectionView.frame), kWindowWidth, 90)];
    self.profileView = profileView;
    [self addSubview:profileView];
    
}

#pragma mark - 设置数据
- (void)setUserInfo:(FrendModel *)userInfo
{
    _userInfo = userInfo;
    
    self.profileView.userInfo = userInfo;
    
    // 设置数据
    NSURL *url = [NSURL URLWithString:userInfo.avatar];
    [self.profileHeader.imageView sd_setImageWithURL:url];
    self.name.text = userInfo.nickName;

}

@end
