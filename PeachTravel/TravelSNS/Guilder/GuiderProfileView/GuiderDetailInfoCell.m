//
//  GuiderDetailInfoCell.m
//  PeachTravel
//
//  Created by 王聪 on 8/28/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderDetailInfoCell.h"
#import "GuiderProfileImageView.h"
#import "PeachTravel-Swift.h"
#import "TaoziCollectionLayout.h"
#import "GuiderDetailCollectionCell.h"
@interface GuiderDetailInfoCell () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,TaoziLayoutDelegate>

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
    
    
    // 添加UICollectionView
    TaoziCollectionLayout *layout = [[TaoziCollectionLayout alloc] init];
    layout.delegate = self;
    layout.showDecorationView = NO;
    layout.spacePerItem = 12;
    layout.spacePerLine = 15;
    layout.margin = 10;
    
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.scrollEnabled = NO;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.showsVerticalScrollIndicator = NO;
    [collectionView registerNib:[UINib nibWithNibName:@"GuiderDetailCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"detailInfoCell"];
    [collectionView registerNib:[UINib nibWithNibName:@"SearchDestinationHistoryCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"searchDestinationHeader"];
    
    [self addSubview:collectionView];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.profileHeader.frame = CGRectMake(0, 0, kWindowWidth, kWindowWidth);
    self.name.frame = CGRectMake(26.7, CGRectGetMaxY(self.profileHeader.frame)+12, 200, 25);
    self.collectionView.frame = CGRectMake(10, CGRectGetMaxY(self.name.frame), kWindowWidth-20, 85);
}

#pragma mark - 设置数据
- (void)setUserInfo:(FrendModel *)userInfo
{
    _userInfo = userInfo;
    
    // 设置数据
    NSURL *url = [NSURL URLWithString:userInfo.avatar];
    [self.profileHeader.imageView sd_setImageWithURL:url];
    self.name.text = userInfo.nickName;

    // 设置collectionView的数据
    NSArray *collectionArray = userInfo.tags;
    self.collectionArray = collectionArray;
    [self.collectionView reloadData];
}

- (void)setAccountModel:(AccountModel *)accountModel
{
    _accountModel = accountModel;
    
    // 设置数据
    NSURL *url = [NSURL URLWithString:accountModel.avatar];
    [self.profileHeader.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    self.name.text = accountModel.nickName;
    
    // 隐藏collectionView
    self.collectionView.hidden = YES;
}

- (void)setCollectionArray:(NSArray *)collectionArray
{
    _collectionArray = collectionArray;
    
    [self.collectionView reloadData];
    
}

#pragma mark - 实现UICollectionView的数据源以及代理方法

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _collectionArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GuiderDetailCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"detailInfoCell" forIndexPath:indexPath];
    cell.titleLab.text = _collectionArray[indexPath.row];
    
    return cell;
}


#pragma mark - TaoziLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [_collectionArray objectAtIndex:indexPath.row];
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0]}];
    return CGSizeMake(size.width, 20);
}

- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
    return CGSizeMake(kWindowWidth, 0);
}

- (NSInteger)numberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)tzcollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _collectionArray.count;
}

- (CGFloat)tzcollectionLayoutWidth
{
    return self.bounds.size.width-20;
}


@end
