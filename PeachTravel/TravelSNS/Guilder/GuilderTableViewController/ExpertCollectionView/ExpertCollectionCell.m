//
//  ExpertCollectionCell.m
//  PeachTravel
//
//  Created by 王聪 on 9/10/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "ExpertCollectionCell.h"
#import "PeachTravel-swift.h"
#import "GuiderDetailCollectionCell.h"
@implementation ExpertCollectionCell

- (void)awakeFromNib {
    [self setupBaseInfo];
    [self setupDetailInfo];
}

// 设置基本信息
- (void)setupBaseInfo
{
    self.backgroundColor = [UIColor whiteColor];
    self.avatarImage.clipsToBounds = YES;
    
    self.nickName.textColor = UIColorFromRGB(0x99CC66);
    self.nickName.font = [UIFont boldSystemFontOfSize:12.0];
    self.nickName.textAlignment = NSTextAlignmentLeft;
    
    self.city.textColor = UIColorFromRGB(0x969696);
    self.city.font = [UIFont boldSystemFontOfSize:12.0];
    self.city.textAlignment = NSTextAlignmentLeft;
    
    self.content.textColor = UIColorFromRGB(0x323232);
    self.content.font = [UIFont boldSystemFontOfSize:16.0];
    self.content.textAlignment = NSTextAlignmentLeft;
    self.content.numberOfLines = 0;
    
    [self.levelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.levelBtn setBackgroundImage:[UIImage imageNamed:@"level_bg"] forState:UIControlStateNormal];
}

#pragma mark - 加载View视图
- (void)setupDetailInfo {
    
    // 添加UICollectionView
    TaoziCollectionLayout *layout = [[TaoziCollectionLayout alloc] init];
    layout.delegate = self;
    layout.showDecorationView = NO;
    layout.spacePerItem = 6;
    layout.spacePerLine = 15;
    layout.margin = 10;
    
    self.collectionView.collectionViewLayout = layout;
    
    _collectionView.userInteractionEnabled = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.scrollEnabled = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.showsVerticalScrollIndicator = NO;
    [_collectionView registerNib:[UINib nibWithNibName:@"GuiderDetailCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"detailInfoCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"SearchDestinationHistoryCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"searchDestinationHeader"];
    
}


- (void)setGuiderModel:(ExpertModel *)guiderModel
{
    _guiderModel = guiderModel;
        
    _nickName.text = _guiderModel.nickName;
    [_levelBtn setTitle:[NSString stringWithFormat:@"V%ld", (long)_guiderModel.level] forState:UIControlStateNormal];
    
    [_avatarImage sd_setImageWithURL:[NSURL URLWithString:_guiderModel.avatar] placeholderImage:nil];
    
    NSString *cityContent = [NSString stringWithFormat:@"%@ %ld岁",_guiderModel.residence,_guiderModel.age];
    _city.text = cityContent;
    
    _content.text = _guiderModel.profile;
    
    NSString *levelBtnTitle = [NSString stringWithFormat:@"V%ld",_guiderModel.level];
    [_levelBtn setTitle:levelBtnTitle forState:UIControlStateNormal];
    
    NSLog(@"%@",_guiderModel);
    self.collectionArray = _guiderModel.tags;
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
    
    if (indexPath.item%5 == 0) {
        cell.titleLab.backgroundColor = UIColorFromRGB(0xB9DC96);
    } else if (indexPath.item%5 == 1) {
        cell.titleLab.backgroundColor = UIColorFromRGB(0xFF96A0);
    } else if (indexPath.item%5 == 2) {
        cell.titleLab.backgroundColor = UIColorFromRGB(0x8CC8FF);
    } else if (indexPath.item%5 == 3) {
        cell.titleLab.backgroundColor = UIColorFromRGB(0xFFBE64);
    } else {
        cell.titleLab.backgroundColor = UIColorFromRGB(0x82F0FA);
    }
    
    return cell;
}


#pragma mark - TaoziLayoutDelegate

- (CGSize)tzCollectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [_collectionArray objectAtIndex:indexPath.row];
    CGSize size = [title sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17.0]}];
    return CGSizeMake(size.width, 20);
}

- (CGSize)tzCollectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
    return CGSizeMake(kWindowWidth, 0);
}

- (NSInteger)tzNumberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)tzCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _collectionArray.count;
}

- (CGFloat)tzCollectionLayoutWidth
{
    return self.bounds.size.width-20;
}


@end
