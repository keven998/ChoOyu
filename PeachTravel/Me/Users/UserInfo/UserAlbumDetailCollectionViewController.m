//
//  UserAlbumDetailCollectionViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "UserAlbumDetailCollectionViewController.h"
#import "UserAlbumSelectCollectionViewCell.h"
#import "UserAlbumPreviewViewController.h"

@interface UserAlbumDetailCollectionViewController ()

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation UserAlbumDetailCollectionViewController

static NSString * const reuseIdentifier = @"userAlbumSelectCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"UserAlbumSelectCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    layout.itemSize = CGSizeMake(self.view.bounds.size.width/4, (self.view.bounds.size.width/4));
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    [self loadDataSource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (void)loadDataSource {
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        
        if (asset) {
            [self.dataSource addObject:asset];
            
        } else if (self.dataSource.count > 0) {
            [self.collectionView reloadData];
        }
    };
    
    [self.assetsGroup enumerateAssetsUsingBlock:resultsBlock];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UserAlbumSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.asset = _dataSource[indexPath.row];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserAlbumPreviewViewController *ctl = [[UserAlbumPreviewViewController alloc] init];
    ctl.currentIndex = indexPath.row;
    ctl.dataSource = _dataSource;
    [self.navigationController pushViewController: ctl animated:YES];
}

@end
