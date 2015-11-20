//
//  CityListViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/2/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "CityListViewController.h"
#import "CityListCollectionViewCell.h"
#import "PoiManager.h"

@interface CityListViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation CityListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = _countryName;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"CityListCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cityListCollectionCell"];
    UICollectionViewFlowLayout*layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    CGFloat itemWidth = (kWindowWidth-20-6)/2;
    _collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 6;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth*0.7);
    [PoiManager asyncLoadCitiesOfCountry:_countryId completionBlcok:^(BOOL isSuccess, NSArray *poiList) {
        _dataSource = poiList;
        [_collectionView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CityListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cityListCollectionCell" forIndexPath:indexPath];
    cell.cityPoi = [_dataSource objectAtIndex:indexPath.row];
    return cell;
}

@end


