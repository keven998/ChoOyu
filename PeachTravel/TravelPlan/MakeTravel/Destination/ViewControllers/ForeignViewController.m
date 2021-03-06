
//  ForeignViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/19/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "ForeignViewController.h"
#import "TaoziCollectionLayout.h"
#import "DestinationCollectionHeaderView.h"
#import "AreaDestination.h"
#import "CityDestinationPoi.h"
#import "DomesticCell.h"
@interface ForeignViewController () <UICollectionViewDataSource, UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) NSInteger showCitiesIndex;

@property (weak, nonatomic) IBOutlet UICollectionView *foreignCollectionView;
@property (nonatomic, strong) TZProgressHUD *hud;

@property (weak, nonatomic) IBOutlet UITableView *foreignTableView;

// 下面定义一个CollectionView的数据源数组
@property (nonatomic, strong)NSArray * citiesArray;

@end

@implementation ForeignViewController

static NSString *reuseableHeaderIdentifier  = @"domesticHeader";
static NSString *reuseableCellIdentifier  = @"domesticCell";

// 懒加载
- (NSArray *)citiesArray
{
    if (_citiesArray == nil) {
        _citiesArray = [NSArray array];
    }
    return _citiesArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     *  定义CollectionView的内容
     */
    _showCitiesIndex = 0;
    [self.foreignCollectionView registerNib:[UINib nibWithNibName:@"DomesticCell" bundle:nil]  forCellWithReuseIdentifier:reuseableCellIdentifier];
    [self.foreignCollectionView registerNib:[UINib nibWithNibName:@"DestinationCollectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseableHeaderIdentifier];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.foreignCollectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake((kWindowWidth - 75)/3, (kWindowWidth - 75)/3);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    [self.foreignCollectionView setContentInset:UIEdgeInsetsMake(-5, 0, 100, 0)];
    self.foreignCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.foreignCollectionView setShowsVerticalScrollIndicator:NO];
    _foreignCollectionView.dataSource = self;
    _foreignCollectionView.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDestinationsSelected:) name:updateDestinationsSelectedNoti object:nil];
    
    
    self.foreignTableView.dataSource = self;
    self.foreignTableView.delegate = self;
    self.foreignTableView.showsVerticalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self initData];
    
}

- (void)initData
{
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

- (void)reloadData
{
    [self.foreignCollectionView reloadData];
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
    NSNumber *imageWidth = [NSNumber numberWithInt:450];
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

            [self.foreignTableView reloadData];
            
            // 默认选中第一组
            NSIndexPath *first = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.foreignTableView selectRowAtIndexPath:first animated:YES scrollPosition:UITableViewScrollPositionTop];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSMutableDictionary *dic = [responseObject mutableCopy];
                if ([operation.response.allHeaderFields objectForKey:@"Date"]) {
                    [dic setObject:[operation.response.allHeaderFields objectForKey:@"Date"]  forKey:@"lastModified"];
                    [[TMCache sharedCache] setObject:dic forKey:@"destination_foreign"];
                }
            });
            
            AreaDestination *country = _destinations.foreignCountries[0];
            self.citiesArray = country.cities;
            [_foreignCollectionView reloadData];
            
        } else {
            if (_hud) {
                if (self.isShowing) {
                    [SVProgressHUD showHint:HTTP_FAILED_HINT];
                }
            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_hud) {
            [_hud hideTZHUD];
            if (self.isShowing) {
                [SVProgressHUD showHint:HTTP_FAILED_HINT];
            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

#pragma mark - IBAction Methods

- (IBAction)showCities:(UIButton *)sender
{
    if (_showCitiesIndex == sender.tag) {
        _showCitiesIndex = -1;
    } else {
        _showCitiesIndex = sender.tag;
    }
    
    [self.foreignCollectionView reloadData];

}

#pragma mark - notification

- (void) updateDestinationsSelected:(NSNotification *)noti
{
    CityDestinationPoi *city = [noti.userInfo objectForKey:@"city"];
    for (int i=0; i<[_destinations.foreignCountries count]; i++) {
        AreaDestination *country = _destinations.foreignCountries[i];
        for (int j=0; j<country.cities.count; j++) {
            CityDestinationPoi *cityPoi = country.cities[j];
            if ([cityPoi.cityId isEqualToString:city.cityId]) {
                [_foreignCollectionView reloadData];
            }
        }
    }
    if (self.destinations.destinationsSelected.count == 0) {
        [self.makePlanCtl hideDestinationBar];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.citiesArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    AreaDestination *country = [_destinations.foreignCountries objectAtIndex:indexPath.section];
    DestinationCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseableHeaderIdentifier forIndexPath:indexPath];
    headerView.backgroundColor = APP_PAGE_COLOR;
    NSString * title = [NSString stringWithFormat:@"- %@ -",country.zhName];
    headerView.titleLabel.text = title;
    return headerView;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CityDestinationPoi *city = self.citiesArray[indexPath.item];
    
    DomesticCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseableCellIdentifier forIndexPath:indexPath];
    cell.tiltleLabel.text = city.zhName;

    BOOL find = NO;
    for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
        if ([cityPoi.cityId isEqualToString:city.cityId]) {
            cell.status.image = [UIImage imageNamed:@"dx_checkbox_selected"];
            find = YES;
        }
    }
    if (!find) {
        cell.status.image = nil;
    }
    
    TaoziImage *image = city.images.firstObject;
    
    [cell.backGroundImage sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
    
    return  cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CityDestinationPoi *city = self.citiesArray[indexPath.row];
    BOOL find = NO;
    for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
        if ([city.cityId isEqualToString:cityPoi.cityId]) {
            NSInteger index = [_destinations.destinationsSelected indexOfObject:cityPoi];
            NSIndexPath *lnp = [NSIndexPath indexPathForItem:index inSection:0];
            [_destinations.destinationsSelected removeObjectAtIndex:index];
            [_makePlanCtl.selectPanel performBatchUpdates:^{
                [_makePlanCtl.selectPanel deleteItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
            } completion:^(BOOL finished) {
                if (_destinations.destinationsSelected.count == 0) {
                    [_makePlanCtl hideDestinationBar];
                }
            }];
            find = YES;
            break;
        }
    }
    if (!find) {
        if (_destinations.destinationsSelected.count == 0) {
            [_makePlanCtl showDestinationBar];
        }
        [_destinations.destinationsSelected addObject:city];
        NSIndexPath *lnp = [NSIndexPath indexPathForItem:_destinations.destinationsSelected.count - 1 inSection:0];
        [_makePlanCtl.selectPanel performBatchUpdates:^{
            [_makePlanCtl.selectPanel insertItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
        } completion:^(BOOL finished) {
            if (finished) {
            
            }
            
        }];
    }
    
    if (_destinations.destinationsSelected.count > 0) {
        NSIndexPath *lnp = [NSIndexPath indexPathForItem:(_destinations.destinationsSelected.count-1) inSection:0];
        [_makePlanCtl.selectPanel scrollToItemAtIndexPath:lnp
                                         atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
    
    [self.foreignCollectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    return CGSizeMake(self.foreignCollectionView.frame.size.width, 0);
}


#pragma mark - 实现tableView的数据源以及代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.destinations.foreignCountries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * ID = @"cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    AreaDestination *country = [_destinations.foreignCountries objectAtIndex:indexPath.row];

    NSString * title = [NSString stringWithFormat:@"%@",country.zhName];
    
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

/**
 *  代理方法
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"选中了%ld行",indexPath.row);
    
    AreaDestination *country = _destinations.foreignCountries[indexPath.row];
    
    self.citiesArray = country.cities;
    [self.foreignCollectionView reloadData];
    
    NSLog(@"%@",self.citiesArray);
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"%@",self.destinations);
    
    [_makePlanCtl.selectPanel reloadData];
    [self.foreignCollectionView reloadData];
    
    if (self.destinations.destinationsSelected.count == 0) {
        [_makePlanCtl hideDestinationBar];
    }else{
        [_makePlanCtl showDestinationBar];
    }
}


@end




