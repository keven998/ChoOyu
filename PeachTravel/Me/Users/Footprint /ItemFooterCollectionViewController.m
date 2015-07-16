//
//  ItemFooterCollectionViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "ItemFooterCollectionViewController.h"
#import "ItemFooterCollectionViewCell.h"
#import "CityDestinationPoi.h"

@interface ItemFooterCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ItemFooterCollectionViewController

static NSString * const reuseIdentifier = @"footerCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44) collectionViewLayout:aFlowLayout];
    aFlowLayout.headerReferenceSize = CGSizeZero;

    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    [self.view addSubview:_collectionView];
    self.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ItemFooterCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ItemFooterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    SuperPoi *poi = [_dataSource objectAtIndex:indexPath.row];
    cell.titleLabel.text = poi.zhName;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegate didSelectedItem:indexPath.row];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CityDestinationPoi *tripPoi = [_dataSource objectAtIndex:indexPath.row];
    NSString *txt = [NSString stringWithFormat:@"%ld %@", (long)(indexPath.row + 1), tripPoi.zhName];
    CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    return CGSizeMake(size.width, 30);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 15.0;
}

@end
