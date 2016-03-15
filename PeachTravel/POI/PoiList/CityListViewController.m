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
#import "CityDetailViewController.h"

@interface CityListViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<CityPoi *> *dataSource;
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_cityList"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_cityList"];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CityDetailViewController *ctl = [[CityDetailViewController alloc] init];
    ctl.cityId = [_dataSource objectAtIndex:indexPath.row].poiId;
    ctl.cityName = [_dataSource objectAtIndex:indexPath.row].zhName;
    [self.navigationController pushViewController:ctl animated:YES];
}
@end


