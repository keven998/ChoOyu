//
//  ForeignViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/19/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "ForeignViewController.h"
#import "TaoziCollectionLayout.h"
#import "DomesticDestinationCell.h"
#import "DestinationCollectionHeaderView.h"
#import "CountryDestination.h"
#import "CityDestinationPoi.h"

@interface ForeignViewController () <TaoziLayoutDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) NSInteger showCitiesIndex;

@property (weak, nonatomic) IBOutlet UICollectionView *foreignCollectionView;
@property (nonatomic, strong) TZProgressHUD *hud;

@end

@implementation ForeignViewController

static NSString *reuseableHeaderIdentifier  = @"domesticHeader";
static NSString *reuseableCellIdentifier  = @"cell";


- (void)viewDidLoad {
    [super viewDidLoad];
    _showCitiesIndex = 0;
    [self.foreignCollectionView registerNib:[UINib nibWithNibName:@"DomesticDestinationCell" bundle:nil]  forCellWithReuseIdentifier:reuseableCellIdentifier];
    [self.foreignCollectionView registerNib:[UINib nibWithNibName:@"DestinationCollectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseableHeaderIdentifier];
    
    TaoziCollectionLayout *layout = (TaoziCollectionLayout *)_foreignCollectionView.collectionViewLayout;
    layout.delegate = self;
    layout.showDecorationView = YES;
    layout.margin = 10;
    layout.spacePerItem = 10;
    layout.spacePerLine = 10;
    
    _foreignCollectionView.dataSource = self;
    _foreignCollectionView.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDestinationsSelected:) name:updateDestinationsSelectedNoti object:nil];

    [self initData];
}

- (void) initData {
    [[TMCache sharedCache] objectForKey:@"destination_foreign" block:^(TMCache *cache, NSString *key, id object)  {
        if (object != nil) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                [_destinations initForeignCountriesWithJson:[object objectForKey:@"result"]];
                [_foreignCollectionView reloadData];
                [self loadForeignDataFromServerWithLastModified:[object objectForKey:@"lastModified"]];
            } else {
                [self loadForeignDataFromServerWithLastModified:@""];
            }
        } else {
            _hud = [[TZProgressHUD alloc] init];
            [_hud showHUD];
            [self loadForeignDataFromServerWithLastModified:@""];
            
        }
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _foreignCollectionView.delegate = nil;
    _foreignCollectionView.dataSource = nil;
    _foreignCollectionView = nil;
}

/**
 * 获取国外目的地数据
 */
- (void)loadForeignDataFromServerWithLastModified:(NSString *)modifiedTime
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"Cache-Control" forHTTPHeaderField:@"private"];
    [manager.requestSerializer setValue:modifiedTime forHTTPHeaderField:@"If-Modified-Since"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:(kWindowWidth-22)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (_hud) {
        [_hud showHUD];
    }
    
    [manager GET:API_GET_FOREIGN_DESTINATIONS parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_hud) {
            [_hud hideTZHUD];
        }
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {

            id result = [responseObject objectForKey:@"result"];
            [_destinations initForeignCountriesWithJson:result];
            [_foreignCollectionView reloadData];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSMutableDictionary *dic = [responseObject mutableCopy];
                [dic setObject:[operation.response.allHeaderFields objectForKey:@"Date"] forKey:@"lastModified"];
                [[TMCache sharedCache] setObject:dic forKey:@"destination_foreign"];
            });
        } else {
            if (_hud) {
                if (self.isShowing) {
                    [SVProgressHUD showHint:@"呃～好像没找到网络"];
                }
            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_hud) {
            [_hud hideTZHUD];
            if (self.isShowing) {
                [SVProgressHUD showHint:@"呃～好像没找到网络"];
            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (void)reloadData
{
    [self.foreignCollectionView reloadData];
}

#pragma mark - IBAction Methods

- (IBAction)showCities:(UIButton *)sender
{
//    NSInteger pre = _showCitiesIndex;
    
    if (_showCitiesIndex == sender.tag) {
        _showCitiesIndex = -1;
    } else {
        _showCitiesIndex = sender.tag;
    }
    
    [self.foreignCollectionView reloadData];
    
//    [self.foreignCollectionView performBatchUpdates:^{
//        [self.foreignCollectionView insertItemsAtIndexPaths:indexpaths];
//        if (_showCitiesIndex == -1) {
//            [self.foreignCollectionView reloadSections:[NSIndexSet indexSetWithIndex:pre]];
//        } else if (pre == -1) {
//            [self.foreignCollectionView reloadSections:[NSIndexSet indexSetWithIndex:_showCitiesIndex]];
//        } else if (_showCitiesIndex > pre) {
//            [self.foreignCollectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(pre, _showCitiesIndex)]];
//        } else {
//            [self.foreignCollectionView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_showCitiesIndex, pre)]];
//        }
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
//    CountryDestination *country = _destinations.foreignCountries[indexPath.section];
//    CGSize size = [country.desc sizeWithAttributes:@{NSFontAttributeName :[UIFont fontWithName:@"MicrosoftYaHei" size:13.0]}];
//    NSInteger lineCount = size.width/(self.foreignCollectionView.frame.size.width - 20) + 1 ;
//    CGFloat height = lineCount*size.height + 120.0 + 20 + 12.0;
    return CGSizeMake(self.foreignCollectionView.frame.size.width, 55);
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CountryDestination *country = _destinations.foreignCountries[indexPath.section];
    CityDestinationPoi *city = country.cities[indexPath.row];
    CGSize size = [city.zhName sizeWithAttributes:@{NSFontAttributeName :[UIFont fontWithName:@"MicrosoftYaHei" size:15.0]}];
    return CGSizeMake(size.width + 23.0, 26);
}

- (NSInteger)numberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
{
    return _destinations.foreignCountries.count;
}

- (NSInteger)tzcollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    if (section == _showCitiesIndex) {
        return ((CountryDestination *)_destinations.foreignCountries[section]).cities.count;
//    }
//    return 0;
}

- (CGFloat)tzcollectionLayoutWidth
{
    return self.foreignCollectionView.frame.size.width;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    if (section == _showCitiesIndex) {
        return ((CountryDestination *)_destinations.foreignCountries[section]).cities.count;
//    }
//    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _destinations.foreignCountries.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CountryDestination *country = [_destinations.foreignCountries objectAtIndex:indexPath.section];
    DestinationCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseableHeaderIdentifier forIndexPath:indexPath];
    headerView.titleLabel.text = [NSString stringWithFormat:@"  %@", country.zhName];
    
//    [headerView.contentBtn setTitle:country.zhName forState:UIControlStateNormal];
//    headerView.contentBtn.tag = indexPath.section;
//    [headerView.contentBtn addTarget:self action:@selector(showCities:) forControlEvents:UIControlEventTouchUpInside];
//    if (_showCitiesIndex == indexPath.section) {
//        headerView.contentBtn.selected = YES;
//        headerView.cellAccessoryView.image = [UIImage imageNamed:@"cell_accessory_pink_up.png"];
//    } else {
//        headerView.contentBtn.selected = NO;
//        headerView.cellAccessoryView.image = [UIImage imageNamed:@"cell_accessory_pink_down.png"];
//    }
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CountryDestination *country = _destinations.foreignCountries[indexPath.section];
    CityDestinationPoi *city = country.cities[indexPath.row];
    DomesticDestinationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseableCellIdentifier forIndexPath:indexPath];
    cell.tiltleLabel.text = city.zhName;
    for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
        if ([cityPoi.cityId isEqualToString:city.cityId]) {
            cell.tiltleLabel.textColor = [UIColor whiteColor];
            UIImage *buttonBackgroundImage = [[UIImage imageNamed:@"destination_seleted_background.png"]
                                              resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
            cell.background.image = buttonBackgroundImage;
            return  cell;
        }
    }
    cell.tiltleLabel.textColor = APP_THEME_COLOR;
    cell.background.image = nil;
    
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
        [_makePlanCtl.destinationToolBar addUnit:@"ic_cell_item_unchoose" withName:city.zhName andUnitHeight:26];
        [self.foreignCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
}

@end



