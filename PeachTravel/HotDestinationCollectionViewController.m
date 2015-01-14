//
//  HotDestinationCollectionViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/13/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "HotDestinationCollectionViewController.h"
#import "HotDestinationCollectionViewCell.h"
#import "HotDestinationCollectionReusableView.h"
#import "RecommendDataSource.h"
#import "CityDetailTableViewController.h"
#import "MakePlanViewController.h"
#import "ForeignViewController.h"
#import "DomesticViewController.h"
#import "Destinations.h"
#import "TaoziCollectionLayout.h"
#import "SuperWebViewController.h"
#import "SpotDetailViewController.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"
#import "HotelDetailViewController.h"

@interface HotDestinationCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, TaoziLayoutDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation HotDestinationCollectionViewController

static NSString * const reuseIdentifier = @"Cell";
static NSString * const reuseHeaderIdentifier = @"hotDestinationHeader";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    self.navigationItem.title = @"想去";
    
    [self.view addSubview:self.collectionView];

    [self.collectionView registerNib:[UINib nibWithNibName:@"HotDestinationCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:@"HotDestinationCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeaderIdentifier];
    
    UIBarButtonItem * makePlanBtn = [[UIBarButtonItem alloc]initWithTitle:@"新计划" style:UIBarButtonItemStyleBordered target:self action:@selector(makePlan:)];
    makePlanBtn.tintColor = APP_THEME_COLOR;
    self.navigationItem.rightBarButtonItem = makePlanBtn;
    
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isShowing = YES;
    NSLog(@"Hot viewWillAppear");
    NSLog(@"%lu",(unsigned long)self.navigationController.viewControllers.count);
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    if ([self rdv_tabBarController].tabBarHidden) {
        [[self rdv_tabBarController] setTabBarHidden:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _isShowing = NO;
    if (self.navigationController.viewControllers.count == 2) {
        [[self rdv_tabBarController] setTabBarHidden:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) initData {
    [[TMCache sharedCache] objectForKey:@"hot_destination" block:^(TMCache *cache, NSString *key, id object)  {
        if (object != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setupViewFromData:object];
            });
        }
        [self loadDataSource];
    }];
}

#pragma mark - setter & getter

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        TaoziCollectionLayout *tzLayout = [[TaoziCollectionLayout alloc] init];
        tzLayout.delegate = self;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(11, 0, kWindowWidth-22, kWindowHeight-49) collectionViewLayout:tzLayout];
        _collectionView.showsVerticalScrollIndicator = NO;
        NSLog(@"%@", NSStringFromCGRect(self.view.bounds));
        _collectionView.backgroundColor = APP_PAGE_COLOR;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

#pragma mark - Private Methods

- (void)loadDataSource
{
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    //获取首页数据
    [manager GET:API_GET_RECOMMEND parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            id data = [responseObject objectForKey:@"result"];
            [self setupViewFromData:data];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [[TMCache sharedCache] setObject:data forKey:@"hot_destination"];
            });
        } else {
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}

- (void)setupViewFromData:(id)data
{
    [self.dataSource removeAllObjects];
    for (id json in data) {
        RecommendDataSource *data = [[RecommendDataSource alloc] initWithJsonData:json];
        [self.dataSource addObject:data];
        [self.collectionView reloadData];
    }
}

#pragma mark - IBAciton Methods

- (IBAction)makePlan:(id)sender
{
    Destinations *destinations = [[Destinations alloc] init];
    MakePlanViewController *makePlanCtl = [[MakePlanViewController alloc] init];
    ForeignViewController *foreignCtl = [[ForeignViewController alloc] init];
    DomesticViewController *domestic = [[DomesticViewController alloc] init];
    domestic.destinations = destinations;
    foreignCtl.destinations = destinations;
    makePlanCtl.destinations = destinations;
    foreignCtl.title = @"国外";
    domestic.title = @"国内";
    makePlanCtl.viewControllers = @[domestic, foreignCtl];
    domestic.makePlanCtl = makePlanCtl;
    foreignCtl.makePlanCtl = makePlanCtl;
    domestic.notify = NO;
    foreignCtl.notify = NO;
    [self.navigationController pushViewController:makePlanCtl animated:YES];
}


#pragma mark TaoziLayouteDelegate

- (NSInteger)numberOfSectionsInTZCollectionView:(UICollectionView *)collectionView
{
    return self.dataSource.count;
}

- (CGFloat)tzcollectionLayoutWidth
{
    return self.collectionView.frame.size.width;
}

- (NSInteger)tzcollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    RecommendDataSource *recommedDataSource = [self.dataSource objectAtIndex:section];
    return recommedDataSource.localities.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            CGFloat width = ((collectionView.frame.size.width-7)/3*2);
            CGFloat heigh = width *0.75;
            size = CGSizeMake(width, heigh);
            return size;
        } else if (indexPath.row == 1) {
            CGFloat width = ((collectionView.frame.size.width-17)/3*1);
            CGFloat heigh = ((collectionView.frame.size.width-7)/3*2)*0.75;
            size = CGSizeMake(width, heigh);
            return size;
        } else {
            CGFloat width = ((collectionView.frame.size.width-20)/3);
            size = CGSizeMake(width, width);
            return size;
        }
    }
    if (indexPath.section > 0) {
        size = CGSizeMake(self.collectionView.frame.size.width/2-5, self.collectionView.frame.size.width/2-5);
        return size;
    }
    size = CGSizeMake(self.collectionView.frame.size.width/2-40, 100);
    return size;
}

- (CGSize)collectionview:(UICollectionView *)collectionView sizeForHeaderView:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(self.collectionView.frame.size.width, 30);
    return size;
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dataSource.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    RecommendDataSource *recommedDataSource = [self.dataSource objectAtIndex:section];
    return recommedDataSource.localities.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommendDataSource *recommedDataSource = [self.dataSource objectAtIndex:indexPath.section];
    Recommend *recommend = [recommedDataSource.localities objectAtIndex:indexPath.row];
    HotDestinationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    [cell.cellImageView sd_setImageWithURL:[NSURL URLWithString:recommend.cover] placeholderImage:nil];
    cell.cellTitleLabel.text = recommend.title;
    cell.cellDescLabel.text = recommend.desc;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    RecommendDataSource *recommedDataSource = [self.dataSource objectAtIndex:indexPath.section];
    HotDestinationCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:reuseHeaderIdentifier forIndexPath:indexPath];
    headerView.collectionHeaderView.text = recommedDataSource.typeName;
    return headerView;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RecommendDataSource *recommedDataSource = [self.dataSource objectAtIndex:indexPath.section];
    Recommend *recommend = [recommedDataSource.localities objectAtIndex:indexPath.row];
    if (recommend.linkType == LinkHtml) {
        SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
        webCtl.title = recommend.title;
        webCtl.urlStr = recommend.linkUrl;
        [self.navigationController pushViewController:webCtl animated:YES];
    }
    if (recommend.linkType == LinkNative) {
        switch (recommend.poiType) {
            case kCityPoi: {
                CityDetailTableViewController *ctl = [[CityDetailTableViewController alloc] init];
                ctl.cityId = recommend.recommondId;
                [self.navigationController pushViewController:ctl animated:YES];
            }
                break;
                
            case kSpotPoi: {
                SpotDetailViewController *ctl = [[SpotDetailViewController alloc] init];
                ctl.spotId = recommend.recommondId;
                [self.navigationController pushViewController:ctl animated:YES];
            }
                break;
                
            case kRestaurantPoi: {
                RestaurantDetailViewController *ctl = [[RestaurantDetailViewController alloc] init];
                ctl.restaurantId = recommend.recommondId;
                [self.navigationController pushViewController:ctl animated:YES];
            }
                break;
            
            case kShoppingPoi: {
                ShoppingDetailViewController *ctl = [[ShoppingDetailViewController alloc] init];
                ctl.shoppingId = recommend.recommondId;
                [self.navigationController pushViewController:ctl animated:YES];
            }
                break;
                
            case kHotelPoi: {
                HotelDetailViewController *ctl = [[HotelDetailViewController alloc] init];
                ctl.hotelId = recommend.recommondId;
                [self.navigationController pushViewController:ctl animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
}

@end














