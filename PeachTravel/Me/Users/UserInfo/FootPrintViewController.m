//
//  FootPrintViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 3/26/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "FootPrintViewController.h"
#import "TaoziCollectionLayout.h"
#import "FootprintMapViewController.h"
#import "ScreenningViewCell.h"
#import "DestinationCollectionHeaderView.h"
#import "SwipeView.h"
#import "AreaDestination.h"
#import "ItemFooterCollectionViewController.h"
#import "MakePlanViewController.h"
#import "DomesticViewController.h"
#import "ForeignViewController.h"

@interface FootPrintViewController () <ItemFooterCollectionViewControllerDelegate,UpdateDestinationsDelegate>
{
    NSInteger _countryCount;
    NSMutableArray *_dataArray;
    NSMutableArray *_countryName;
}
@property (nonatomic, strong) FootprintMapViewController *footprintMapCtl;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) SwipeView *swipeView;
@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ItemFooterCollectionViewController *itemFooterCtl;
@property (nonatomic, strong) Destinations *destinations;

@end

@implementation FootPrintViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_destinations) {
        _destinations = [[Destinations alloc] init];
    }
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.navigationItem.title = @"我的足迹";
    _countryCount = 0;
    _countryName = [NSMutableArray array];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    // 点击足迹进入足迹地图控制器,需要传入
    _footprintMapCtl = [[FootprintMapViewController alloc] init];
    // 下面的是数据源方法
    _footprintMapCtl.dataSource = _destinations.destinationsSelected;
    [_footprintMapCtl.view setFrame:self.view.bounds];
    [self addChildViewController:_footprintMapCtl];
    [self.view addSubview:_footprintMapCtl.view];
    [_footprintMapCtl didMoveToParentViewController:self];
    
    _itemFooterCtl = [[ItemFooterCollectionViewController alloc] init];
    _itemFooterCtl.dataSource = _destinations.destinationsSelected;
    [_itemFooterCtl.view setFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];

    [self addChildViewController:_itemFooterCtl];
    [self.view addSubview:_itemFooterCtl.view];
    [_itemFooterCtl didMoveToParentViewController:self];
    _itemFooterCtl.delegate = self;
    _itemFooterCtl.dataSource = _destinations.destinationsSelected;
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(3, 15, 44, 44)];
    [backBtn setImage:[UIImage imageNamed:@"common_icon_navigaiton_back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"common_icon_navigaiton_back_highlight"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editFootPrint)];
    self.navigationItem.rightBarButtonItem = item;
    [self loadFootprintData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

- (Destinations *)destinations
{
    if (!_destinations) {
        _destinations = [[Destinations alloc] init];
    }
    return _destinations;
}

/**
 *  获取用户足迹接口
 */
- (void)loadFootprintData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", self.userId] forHTTPHeaderField:@"UserId"];
    NSString *url = [NSString stringWithFormat:@"%@%ld/footprints", API_USERS, _userId];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (NSDictionary *footprintDic in [responseObject objectForKey:@"result"]) {
                CityDestinationPoi *poi = [[CityDestinationPoi alloc] initWithJson:footprintDic];
                [array addObject:poi];
            }
            [self updateDestinations:array];
            
        } else {
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];

}

- (void)editFootPrint
{
    MakePlanViewController *makePlanCtl = [[MakePlanViewController alloc] init];
    ForeignViewController *foreignCtl = [[ForeignViewController alloc] init];
    DomesticViewController *domestic = [[DomesticViewController alloc] init];
    Destinations *destinatios = [[Destinations alloc] init];
    _destinations.destinationsSelected = _destinations.destinationsSelected;
    domestic.destinations = destinatios;
    foreignCtl.destinations = destinatios;
    makePlanCtl.destinations = destinatios;
    
    makePlanCtl.shouldOnlyChangeDestinationWhenClickNextStep = YES;
    makePlanCtl.myDelegate = self;
    makePlanCtl.viewControllers = @[domestic, foreignCtl];
    domestic.makePlanCtl = makePlanCtl;
    foreignCtl.makePlanCtl = makePlanCtl;
    makePlanCtl.animationOptions = UIViewAnimationOptionTransitionNone;
    makePlanCtl.duration = 0;
    makePlanCtl.segmentedTitles = @[@"国内", @"国外"];
    makePlanCtl.selectedColor = APP_THEME_COLOR;
    makePlanCtl.segmentedTitleFont = [UIFont systemFontOfSize:18.0];
    makePlanCtl.normalColor= [UIColor grayColor];
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:makePlanCtl] animated:YES completion:nil];

}

- (void)back
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)changTracks:(NSString *)action city:(CityDestinationPoi *)track
{
    AccountManager *manager = [AccountManager shareAccountManager];
    [manager updataUserServerTracks:action withTrack:track];
}

#pragma mark - 实现选择目的地的代理方法

- (void)updateDestinations:(NSArray *)destinations{
    NSMutableArray *addArray = [[NSMutableArray alloc] init];
    NSMutableArray *delArray = [[NSMutableArray alloc] init];
    
    for (CityDestinationPoi *oldPoi in _destinations.destinationsSelected) {
        BOOL find = NO;
        for (CityDestinationPoi *poi in destinations) {
            if ([poi.cityId isEqualToString:oldPoi.cityId]) {
                find = YES;
            }
        }
        if (!find) {
            [delArray addObject:oldPoi];
        }
    }
    
    for (CityDestinationPoi *oldPoi in destinations) {
        BOOL find = NO;
        for (CityDestinationPoi *poi in _destinations.destinationsSelected) {
            if ([poi.cityId isEqualToString:oldPoi.cityId]) {
                find = YES;
            }
        }
        if (!find) {
            [addArray addObject:oldPoi];
        }
    }
    _destinations.destinationsSelected = [destinations mutableCopy];
    [AccountManager shareAccountManager].account.footprints = _destinations.destinationsSelected;
    _itemFooterCtl.dataSource = _destinations.destinationsSelected;
    _footprintMapCtl.dataSource = _destinations.destinationsSelected;
}

#pragma mark - ItemFooterCollectionViewControllerDelegate

- (void)didSelectedItem:(NSInteger)index
{
    [_footprintMapCtl selectPointAtIndex:index];
}

@end







