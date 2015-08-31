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
#import "TaoziCollectionLayout.h"
#import "DestinationSearchHistoryCell.h"
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
    
    
    // 添加UICollectionView
    TaoziCollectionLayout *layout = [[TaoziCollectionLayout alloc] init];
    layout.delegate = self;
    layout.showDecorationView = NO;
    layout.spacePerItem = 12;
    layout.spacePerLine = 15;
    layout.margin = 10;
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(name.frame), kWindowWidth-20, 100) collectionViewLayout:layout];
    self.collectionView = collectionView;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.scrollEnabled = NO;
    collectionView.backgroundColor = APP_PAGE_COLOR;
    collectionView.showsVerticalScrollIndicator = NO;
    [collectionView registerNib:[UINib nibWithNibName:@"DestinationSearchHistoryCell" bundle:nil] forCellWithReuseIdentifier:@"searchHistoryCell"];
    [collectionView registerNib:[UINib nibWithNibName:@"SearchDestinationHistoryCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"searchDestinationHeader"];
    
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
    DestinationSearchHistoryCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"searchHistoryCell" forIndexPath:indexPath];
    cell.titleLabel.text = _collectionArray[indexPath.row];
    
    return cell;
}


#pragma mark - TaoziLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [_collectionArray objectAtIndex:indexPath.row];
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0]}];
    return CGSizeMake(size.width+20, 30);
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
