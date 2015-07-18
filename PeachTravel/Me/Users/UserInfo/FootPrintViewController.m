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
}

#pragma mark - 实现选择目的地的代理方法
- (void)updateDestinations:(NSArray *)destinations
{
    NSLog(@"%s",__func__);
    _itemFooterCtl.dataSource = destinations;
    _footprintMapCtl.dataSource = destinations;
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

- (void)editFootPrint
{
    MakePlanViewController *makePlanCtl = [[MakePlanViewController alloc] init];
    ForeignViewController *foreignCtl = [[ForeignViewController alloc] init];
    DomesticViewController *domestic = [[DomesticViewController alloc] init];
    
    domestic.destinations = _destinations;
    foreignCtl.destinations = _destinations;
    makePlanCtl.destinations = _destinations;
    
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
    BOOL find = NO;
    [_countryName removeAllObjects];
    for (AreaDestination *area in self.destinations.domesticCities) {
        for (CityDestinationPoi *city in area.cities) {
            
            for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
                if ([cityPoi.cityId isEqualToString:city.cityId]) {
                    [_countryName addObject:area.zhName];
                    find = YES;
                    break;
                }
            }
            if (find) {
                break;
            }
        }
        if (find) {
            break;
        }
    }
    
    for (AreaDestination *area in self.destinations.foreignCountries) {
        for (CityDestinationPoi *city in area.cities) {
            BOOL find = NO;
            for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
                if ([cityPoi.cityId isEqualToString:city.cityId]) {
                    [_countryName addObject:area.zhName];
                    find = YES;
                    break;
                }
            }
            if (find) {
                break;
            }
        }
    }
    NSMutableString *cityDesc = nil;

    for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
        if (cityDesc == nil) {
            cityDesc = [[NSMutableString alloc] initWithString:cityPoi.zhName];
            
        } else {
            [cityDesc appendFormat:@" %@",cityPoi.zhName];
        }
    }
    
    NSLog(@"%@",cityDesc);
    [self.delegate updataTracks:_countryName.count citys:_destinations.destinationsSelected.count trackStr:cityDesc];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)changTracks:(NSString *)action city:(CityDestinationPoi *)track areaName:(NSString *)areaName
{
    AccountManager *manager = [AccountManager shareAccountManager];
    [manager updataUserServerTracks:action withTrack:track areaName:areaName];
}

#pragma mark - ItemFooterCollectionViewControllerDelegate

- (void)didSelectedItem:(NSInteger)index
{
    [_footprintMapCtl selectPointAtIndex:index];
}

@end







