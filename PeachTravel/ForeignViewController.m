//
//  ForeignViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/19/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "ForeignViewController.h"
#import "TaoziCollectionLayout.h"
#import "ForeignDestinationCell.h"
#import "ForeignDestinationCollectionHeaderView.h"
#import "CountryDestination.h"
#import "CityDestinationPoi.h"

@interface ForeignViewController () <TaoziLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) NSInteger showCitiesIndex;

@property (weak, nonatomic) IBOutlet UICollectionView *foreignCollectionView;

@end

@implementation ForeignViewController

static NSString *reuseableHeaderIdentifier  = @"foreignHeader";
static NSString *reuseableCellIdentifier  = @"foreignCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    _showCitiesIndex = -1;
    [self.foreignCollectionView registerNib:[UINib nibWithNibName:@"ForeignDestinationCell" bundle:nil]  forCellWithReuseIdentifier:reuseableCellIdentifier];
    [self.foreignCollectionView registerNib:[UINib nibWithNibName:@"ForeignDestinationCollectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseableHeaderIdentifier];
    
    [(TaoziCollectionLayout *)_foreignCollectionView.collectionViewLayout setDelegate:self];
    _foreignCollectionView.dataSource = self;
    _foreignCollectionView.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDestinationsSelected:) name:updateDestinationsSelectedNoti object:nil];
    [self loadForeignDataFromServer];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 * 获取国外目的地数据
 */
- (void)loadForeignDataFromServer
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:1] forKey:@"abroad"];
    [SVProgressHUD show];
    
    [manager GET:API_GET_DESTINATIONS parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [_destinations initForeignCountriesWithJson:[responseObject objectForKey:@"result"]];
            [_foreignCollectionView reloadData];
            
        } else {
            [SVProgressHUD showErrorWithStatus:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - IBAction Methods

- (IBAction)showCities:(UIButton *)sender
{
//    if (_showCitiesIndex != -1 && _showCitiesIndex != sender.tag) {
//        [self.foreignCollectionView performBatchUpdates:^{
//            [self.foreignCollectionView reloadSections:[NSIndexSet indexSetWithIndex:_showCitiesIndex]];
//        } completion:nil];
//    }
    
    if (_showCitiesIndex == sender.tag) {
        _showCitiesIndex = -1;
    } else {
        _showCitiesIndex = sender.tag;
    }
    [self.foreignCollectionView reloadData];
    
//    _showCitiesIndex = 1;

//    [self.foreignCollectionView performBatchUpdates:^{
//        [self.foreignCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
//        [self.foreignCollectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:1]]];
//        [self.foreignCollectionView reloadData];
//    } completion:nil];

}

#pragma mark - notification

- (void) updateDestinationsSelected:(NSNotification *)noti
{
    CityDestinationPoi *city = [noti.userInfo objectForKey:@"city"];
    for (int i=0; i<[_destinations.foreignCountries count]; i++) {
        CountryDestination *country = _destinations.foreignCountries[i];
        for (int j=0; j<country.cities.count; j++) {
            CityDestinationPoi *cityPoi = country.cities[j];
            if ([cityPoi.cityId isEqualToString:city.cityId]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                [self.foreignCollectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }
    }
    if (self.destinations.destinationsSelected.count == 0) {
        [self.makePlanCtl hideDestinationBar];
    }
}

#pragma mark - TaoziLayoutDelegate

- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
    CountryDestination *country = _destinations.foreignCountries[indexPath.section];
    country.desc = @"hellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohello";
    CGSize size = [country.desc sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:13.0]}];
    NSInteger lineCount = size.width/(self.foreignCollectionView.frame.size.width - 20) + 1 ;
    CGFloat height = lineCount*size.height + 120.0 + 20 + 12.0;
    return CGSizeMake(self.foreignCollectionView.frame.size.width, height);
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CountryDestination *country = _destinations.foreignCountries[indexPath.section];
    CityDestinationPoi *city = country.cities[indexPath.row];
    CGSize size = [city.zhName sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15.0]}];
    return CGSizeMake(size.width+30, size.height + 10);
}

- (NSInteger)numberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
{
    return _destinations.foreignCountries.count;
}

- (NSInteger)tzcollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == _showCitiesIndex) {
        return ((CountryDestination *)_destinations.foreignCountries[section]).cities.count;
    }
    return 0;
}

- (CGFloat)tzcollectionLayoutWidth
{
    return self.foreignCollectionView.frame.size.width;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    if (section == _showCitiesIndex) {
        return ((CountryDestination *)_destinations.foreignCountries[section]).cities.count;
    }
    return 0;

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _destinations.foreignCountries.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CountryDestination *country = [_destinations.foreignCountries objectAtIndex:indexPath.section];
    ForeignDestinationCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseableHeaderIdentifier forIndexPath:indexPath];
//    [headerView.titleBtn setTitle:country.zhName forState:UIControlStateNormal];
    headerView.titleBtn.text = country.zhName;
    
    country.desc = @"hellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohellohello";
    headerView.descLabel.text = country.desc;
    
    CGSize size = [country.desc sizeWithAttributes:@{NSFontAttributeName: headerView.descLabel.font}];
    CGRect frame = headerView.descLabel.frame;
    frame.size.height = size.height;
    headerView.descLabel.frame = frame;
    [headerView.descLabel sizeToFit];
    CGRect frame1 = headerView.contentBtn.frame;
    frame1.size.height = frame.origin.y + frame.size.height + 10.0;
    headerView.contentBtn.frame = frame1;
    
//    NSInteger lineCount = size.width/(self.foreignCollectionView.frame.size.width-20)+1;
//    headerView.descLabel.numberOfLines = lineCount;
    if (indexPath.section != _showCitiesIndex) {
        headerView.spaceLineView.hidden = YES;
    } else {
        headerView.spaceLineView.hidden = NO;
    }
    headerView.contentBtn.tag = indexPath.section;
    [headerView.contentBtn addTarget:self action:@selector(showCities:) forControlEvents:UIControlEventTouchUpInside];
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CountryDestination *country = _destinations.foreignCountries[indexPath.section];
    CityDestinationPoi *city = country.cities[indexPath.row];
    ForeignDestinationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseableCellIdentifier forIndexPath:indexPath];
    cell.titleLabel.text = city.zhName;
    for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
        if ([cityPoi.cityId isEqualToString:city.cityId]) {
            cell.layer.borderColor = APP_THEME_COLOR.CGColor;
            cell.titleLabel.textColor = APP_THEME_COLOR;
            return  cell;
        }
    }
    cell.layer.borderColor = UIColorFromRGB(0xb3b3b3).CGColor;
    cell.titleLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    return  cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CountryDestination *country = _destinations.foreignCountries[indexPath.section];
    CityDestinationPoi *city = country.cities[indexPath.row];
    BOOL find = NO;
    for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
        if ([city.cityId isEqualToString:cityPoi.cityId]) {
            NSInteger index = [_destinations.destinationsSelected indexOfObject:cityPoi];
            [_makePlanCtl.destinationToolBar removeUnitAtIndex:index];
            find = YES;
            break;
        }
    }
    if (!find) {
        if (_destinations.destinationsSelected.count == 0) {
            [_makePlanCtl showDestinationBar];
        }
        [_destinations.destinationsSelected addObject:city];
        [_makePlanCtl.destinationToolBar addNewUnitWithName:city.zhName];
        [self.foreignCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    }

}

@end




