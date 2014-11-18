//
//  DomesticViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "DomesticViewController.h"
#import "TaoziCollectionLayout.h"
#import "DestinationCollectionHeaderView.h"

@interface DomesticViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, TaoziLayoutDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *domesticCollectionView;

#warning 测试数据
@property (nonatomic, strong) NSMutableArray *testArray;

@end

@implementation DomesticViewController

static NSString *reusableIdentifier = @"cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [_domesticCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reusableIdentifier];
    [_domesticCollectionView registerClass:[DestinationCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"test"];
    _domesticCollectionView.dataSource = self;
    _domesticCollectionView.delegate = self;
    [(TaoziCollectionLayout *)_domesticCollectionView.collectionViewLayout setDelegate:self];
    
    NSArray *s = @[@"北京", @"上海", @"哈尔滨", @"浩", @"马六甲"];
    NSArray *s1 = @[@"北京", @"上海", @"哈尔滨", @"呼和浩特", @"马六甲海峡"];
    NSArray *s2 = @[@"北京", @"上海", @"哈尔滨", @"呼和浩特", @"马六甲海峡"];
    _testArray = [[NSMutableArray alloc] initWithObjects:s,s1,s2,nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  TaoziLayoutDelegate

- (NSInteger)tzcollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_testArray[section] count];
}

- (CGFloat)tzcollectionLayoutWidth
{
    return self.domesticCollectionView.frame.size.width-20;
}

- (NSInteger)numberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
{
    return _testArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = [_testArray[indexPath.section][indexPath.row] sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15.0]}];
    return CGSizeMake(size.width+20, size.height+10);
}

- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.domesticCollectionView.frame.size.width-20, 30);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    DestinationCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"test" forIndexPath:indexPath];
    headerView.headerLabel.text = @"我们的家";
    headerView.backgroundColor = [UIColor blackColor];
    return headerView;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusableIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blackColor];
    return  cell;
}

@end
