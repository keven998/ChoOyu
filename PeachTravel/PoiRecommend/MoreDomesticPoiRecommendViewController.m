//
//  MoreDomesticPoiRecommendViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/25/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "MoreDomesticPoiRecommendViewController.h"
#import "AreaDestination.h"
#import "DestinationCollectionHeaderView.h"
#import "PoiRecommendCollectionViewCell.h"
#import "CityDetailTableViewController.h"

@interface MoreDomesticPoiRecommendViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionView *domesticCollectionView;
@property (nonatomic, strong) TZProgressHUD *hud;

@end

@implementation MoreDomesticPoiRecommendViewController

static NSString *reusableIdentifier = @"poiRecommendCollectionCell";
static NSString *reusableHeaderIdentifier = @"domesticHeader";
static NSString *cacheName = @"destination_demostic_group";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.domesticCollectionView];
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionView *)domesticCollectionView
{
    if (!_domesticCollectionView) {
        UICollectionViewFlowLayout *layou = [[UICollectionViewFlowLayout alloc] init];
        layou.minimumLineSpacing = 0.0;
        layou.itemSize = CGSizeMake(self.view.bounds.size.width, 210);
        _domesticCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) collectionViewLayout:layou];
        [_domesticCollectionView registerNib:[UINib nibWithNibName:@"PoiRecommendCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reusableIdentifier];
        [_domesticCollectionView registerNib:[UINib nibWithNibName:@"DestinationCollectionHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reusableHeaderIdentifier];
        _domesticCollectionView.dataSource = self;
        _domesticCollectionView.delegate = self;
        _domesticCollectionView.showsVerticalScrollIndicator = NO;
        _domesticCollectionView.contentInset = UIEdgeInsetsMake(-5, 0, 35, 0);
        _domesticCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _domesticCollectionView.backgroundColor = APP_PAGE_COLOR;
    }
    return _domesticCollectionView;
}

- (void)initData
{
    [[TMCache sharedCache] objectForKey:cacheName block:^(TMCache *cache, NSString *key, id object)  {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (object != nil) {
                if ([object isKindOfClass:[NSDictionary class]]) {
                    [_destinations initDomesticCitiesWithJson:[object objectForKey:@"result"]];
                    [self loadDomesticDataFromServerWithLastModified:[object objectForKey:@"lastModified"]];
                    [self reloadData];
                } else {
                    [self loadDomesticDataFromServerWithLastModified:@""];
                }
            } else {
                _hud = [[TZProgressHUD alloc] init];
                [_hud showHUD];
                [self loadDomesticDataFromServerWithLastModified:@""];
                
            }
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"%@",self.destinations);
    
    [self.domesticCollectionView reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _domesticCollectionView.delegate = nil;
    _domesticCollectionView.dataSource = nil;
    _domesticCollectionView = nil;
}

- (void)reloadData
{
    [self.domesticCollectionView reloadData];
}

/**
 *  获取国内目的地
 */

- (void)loadDomesticDataFromServerWithLastModified:(NSString *)modifiedTime
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
    
    NSNumber *imageWidth = [NSNumber numberWithInt:450];
    NSDictionary *params = @{@"groupBy" : [NSNumber numberWithBool:true], @"imgWidth": imageWidth};
    
    NSLog(@"%@",API_GET_DOMESTIC_DESTINATIONS);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager GET:API_GET_DOMESTIC_DESTINATIONS parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@",responseObject);
        
        if (_hud) {
            [_hud hideTZHUD];
        }
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            id result = [responseObject objectForKey:@"result"];
            [_destinations.domesticCities removeAllObjects];
            [_destinations initDomesticCitiesWithJson:result];
            [self reloadData];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSMutableDictionary *dic = [responseObject mutableCopy];
                if ([operation.response.allHeaderFields objectForKey:@"Date"]) {
                    [dic setObject:[operation.response.allHeaderFields objectForKey:@"Date"]  forKey:@"lastModified"];
                    [[TMCache sharedCache] setObject:dic forKey:cacheName];
                }
                
            });
        } else {
            if (_hud) {
                [SVProgressHUD showHint:HTTP_FAILED_HINT];
            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [_hud hideTZHUD];
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
    }];
}

#pragma mark - UICollectionViewDataSource

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
{
    return CGSizeMake(self.domesticCollectionView.frame.size.width, 72);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    AreaDestination *area = [self.destinations.domesticCities objectAtIndex:section];
    return [area.cities count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.destinations.domesticCities.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        DestinationCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reusableHeaderIdentifier forIndexPath:indexPath];
        headerView.backgroundColor = APP_PAGE_COLOR;
        AreaDestination *area = [self.destinations.domesticCities objectAtIndex:indexPath.section];
        NSString * title = [NSString stringWithFormat:@"- %@ -",area.zhName];
        headerView.titleLabel.text = title;
        return headerView;
    }
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PoiRecommendCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusableIdentifier forIndexPath:indexPath];
    AreaDestination *area = [self.destinations.domesticCities objectAtIndex:indexPath.section];
    CityDestinationPoi *city = [area.cities objectAtIndex:indexPath.row];
    cell.titleLabel.text = city.zhName;
    TaoziImage *image = [city.images firstObject];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:image.imageUrl]];
    return  cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AreaDestination *area = [self.destinations.domesticCities objectAtIndex:indexPath.section];
    CityDestinationPoi *city = [area.cities objectAtIndex:indexPath.row];
    CityDetailTableViewController *ctl = [[CityDetailTableViewController alloc] init];
    ctl.cityId = city.cityId;
    [self.navigationController pushViewController:ctl animated:YES];
}



@end
