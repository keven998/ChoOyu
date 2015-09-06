//
//  ExpertProfileTagViewCell.m
//  PeachTravel
//
//  Created by 王聪 on 15/9/6.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "ExpertProfileTagViewCell.h"
#import "TaoziCollectionLayout.h"
#import "PeachTravel-Swift.h"
#import "GuiderDetailCollectionCell.h"
@interface ExpertProfileTagViewCell ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,TaoziLayoutDelegate>

@property (nonatomic, weak)UICollectionView *collectionView;

@end

@implementation ExpertProfileTagViewCell

#pragma mark - 初始化方法
+ (id)expertDetailInfo
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
    
    self.collectionView.frame = CGRectMake(10, 0, kWindowWidth-20, self.frame.size.height);
}

#pragma mark - 设置数据
- (void)setUserInfo:(FrendModel *)userInfo
{
    _userInfo = userInfo;
    
    // 设置collectionView的数据
    NSArray *collectionArray = _userInfo.tags;
    self.collectionArray = collectionArray;
    [self.collectionView reloadData];
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