//
//  MoreForeignPoiRecommendViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/25/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "MoreForeignPoiRecommendViewController.h"
#import "TaoziCollectionLayout.h"
#import "DestinationCollectionHeaderView.h"
#import "AreaDestination.h"
#import "CityDestinationPoi.h"
#import "DomesticCell.h"
#import "PoiRecommendCollectionViewCell.h"
#import "CityDetailViewController.h"

@interface MoreForeignPoiRecommendViewController () <UICollectionViewDataSource, UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate>

//当前显示第几个国家
@property (nonatomic) NSInteger showCitiesIndex;

@property (strong, nonatomic) UICollectionView *foreignCollectionView;
@property (nonatomic, strong) TZProgressHUD *hud;

@property (strong, nonatomic) UITableView *foreignTableView;

// 下面定义一个CollectionView的数据源数组
@property (nonatomic, strong)NSArray * citiesArray;

@end

@implementation MoreForeignPoiRecommendViewController

static NSString *reuseableHeaderIdentifier  = @"domesticHeader";
static NSString *reuseableCellIdentifier  = @"poiRecommendCollectionCell";

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
    self.automaticallyAdjustsScrollViewInsets = NO;
    /**
     *  定义CollectionView的内容
     */
    _showCitiesIndex = 0;
    [self.view addSubview:self.foreignTableView];
    [self.view addSubview:self.foreignCollectionView];
    [self.foreignCollectionView registerNib:[UINib nibWithNibName:@"PoiRecommendCollectionViewCell" bundle:nil]  forCellWithReuseIdentifier:reuseableCellIdentifier];
    [self.foreignCollectionView registerNib:[UINib nibWithNibName:@"DestinationCollectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseableHeaderIdentifier];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.foreignCollectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(kWindowWidth - 75, 150);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    [self.foreignCollectionView setContentInset:UIEdgeInsetsMake(-5, 0, 100, 0)];
    self.foreignCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.foreignCollectionView setShowsVerticalScrollIndicator:NO];
    _foreignCollectionView.dataSource = self;
    _foreignCollectionView.delegate = self;
    
    self.foreignTableView.dataSource = self;
    self.foreignTableView.delegate = self;
    self.foreignTableView.showsVerticalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initData];
}

- (UICollectionView *)foreignCollectionView
{
    if (!_foreignCollectionView) {
        UICollectionViewFlowLayout *layou = [[UICollectionViewFlowLayout alloc] init];
        layou.minimumLineSpacing = 0.0;
        layou.itemSize = CGSizeMake(self.view.bounds.size.width, 210);
        _foreignCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(75, 64, self.view.bounds.size.width-75, self.view.bounds.size.height-64) collectionViewLayout:layou];
        [_foreignCollectionView registerNib:[UINib nibWithNibName:@"PoiRecommendCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseableCellIdentifier];
        [_foreignCollectionView registerNib:[UINib nibWithNibName:@"DestinationCollectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseableHeaderIdentifier];
        _foreignCollectionView.dataSource = self;
        _foreignCollectionView.delegate = self;
        _foreignCollectionView.showsVerticalScrollIndicator = NO;
        _foreignCollectionView.contentInset = UIEdgeInsetsMake(-5, 0, 35, 0);
        _foreignCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _foreignCollectionView.backgroundColor = APP_PAGE_COLOR;
    }
    return _foreignCollectionView;
}

- (UITableView *)foreignTableView
{
    if (!_foreignTableView) {
        _foreignTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 75, self.view.bounds.size.height-64)];
        _foreignTableView.delegate = self;
        _foreignTableView.dataSource = self;
    }
    return _foreignTableView;
}

- (void)initData
{
    [[TMCache sharedCache] objectForKey:@"destination_foreign" block:^(TMCache *cache, NSString *key, id object)  {
        if (object != nil) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   
                    [_destinations initForeignCountriesWithJson:[object objectForKey:@"result"]];
                    // 默认选中第一组
                    NSIndexPath *first = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.foreignTableView selectRowAtIndexPath:first animated:YES scrollPosition:UITableViewScrollPositionTop];
                    
                    AreaDestination *country = _destinations.foreignCountries[0];
                    self.citiesArray = country.cities;
                    [_foreignCollectionView reloadData];

                    [self loadForeignDataFromServerWithLastModified:[object objectForKey:@"lastModified"]];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self loadForeignDataFromServerWithLastModified:@""];
                });
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                _hud = [[TZProgressHUD alloc] init];
                [_hud showHUD];
                [self loadForeignDataFromServerWithLastModified:@""];
                
            });
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
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    [manager.requestSerializer setValue:@"application/vnd.lvxingpai.v1+json" forHTTPHeaderField:@"Accept"];
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
            
            if (_showCitiesIndex == 0) {
                NSIndexPath *first = [NSIndexPath indexPathForRow:_showCitiesIndex inSection:0];
                [self.foreignTableView selectRowAtIndexPath:first animated:YES scrollPosition:UITableViewScrollPositionTop];
            }
          
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSMutableDictionary *dic = [responseObject mutableCopy];
                if ([operation.response.allHeaderFields objectForKey:@"Date"]) {
                    [dic setObject:[operation.response.allHeaderFields objectForKey:@"Date"]  forKey:@"lastModified"];
                    [[TMCache sharedCache] setObject:dic forKey:@"destination_foreign"];
                }
            });
            
            AreaDestination *country = _destinations.foreignCountries[_showCitiesIndex];
            self.citiesArray = country.cities;
            [_foreignCollectionView reloadData];
            
        } else {
            if (_hud) {
                [SVProgressHUD showHint:HTTP_FAILED_HINT];
            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (_hud) {
            [_hud hideTZHUD];
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
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
    PoiRecommendCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseableCellIdentifier forIndexPath:indexPath];
    CityDestinationPoi *city = self.citiesArray[indexPath.item];

    cell.titleLabel.text = city.zhName;
    cell.subTitleLabel.text = city.enName;
    TaoziImage *image = [city.images firstObject];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CityDestinationPoi *city = self.citiesArray[indexPath.item];
    CityDetailViewController *ctl = [[CityDetailViewController alloc] init];
    ctl.cityId = city.cityId;
    [self.navigationController pushViewController:ctl animated:YES];
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
    _showCitiesIndex = indexPath.row;
    NSLog(@"%@",self.citiesArray);
}

@end
