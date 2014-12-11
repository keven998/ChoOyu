//
//  TripDetailRootViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TripDetailRootViewController.h"
#import "RDVTabBarItem.h"
#import "SpotsListViewController.h"
#import "RestaurantsListViewController.h"
#import "ShoppingListViewController.h"
#import "CityDestinationPoi.h"
#import "AccountManager.h"
#import "DestinationsView.h"
#import "DestinationUnit.h"
#import "CityDetailTableViewController.h"

@interface TripDetailRootViewController ()

@property (nonatomic, strong) SpotsListViewController *spotsListCtl;
@property (nonatomic, strong) RestaurantsListViewController *restaurantListCtl;
@property (nonatomic, strong) ShoppingListViewController *shoppingListCtl;
/**
 *  目的地titile 列表，三个界面共享
 */
@property (strong, nonatomic) DestinationsView *destinationsHeaderView;


@end

@implementation TripDetailRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"旅行圈";
    
    [self setupViewControllers];
    if (_isMakeNewTrip) {
        [self loadNewTripData];
    } else {
        [self checkTripData];
    }
}

/**
 *  新制作路线，传入目的地 id 列表获取路线详情
 */
- (void)loadNewTripData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];

    NSMutableArray *cityIds = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in _destinations) {
        [cityIds addObject:poi.cityId];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:cityIds forKey:@"locId"];
    [SVProgressHUD show];
    
    //获取路线模板数据,新制作路线的情况下
    [manager POST:API_CREATE_GUIDE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [SVProgressHUD dismiss];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            _tripDetail = [[TripDetail alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self reloadTripData];
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD dismiss];
    }];
}

- (DestinationsView *)destinationsHeaderView
{
    if (!_destinationsHeaderView) {
        _destinationsHeaderView = [[DestinationsView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 45) andContentOffsetX:80];
#warning 测试数据
        _destinationsHeaderView.backgroundColor = [UIColor whiteColor];
    }
    return _destinationsHeaderView;
}

/**
 *  查看已存在的攻略的详情，传入攻略 ID
 */
- (void)checkTripData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@/all", API_GET_GUIDE, _tripId];
    [SVProgressHUD show];

    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [SVProgressHUD dismiss];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            _tripDetail = [[TripDetail alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self reloadTripData];
            [self updateDestinationsHeaderView];
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD dismiss];
    }];
}

/**
 *  更新三账单的目的地标题
 */
- (void)updateDestinationsHeaderView
{
    NSMutableArray *destinationsArray = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in _tripDetail.destinations) {
        if (poi.zhName) {
            [destinationsArray addObject:poi.zhName];
        }
    }
    _destinationsHeaderView.destinations = destinationsArray;
    for (DestinationUnit *unit in _destinationsHeaderView.destinationItmes) {
        [unit addTarget:self action:@selector(viewCityDetail:) forControlEvents:UIControlEventTouchUpInside];
    }
}

/**
 *  点击我的目的地进入城市详情
 *
 *  @param sender
 */
- (IBAction)viewCityDetail:(UIButton *)sender
{
    CityDestinationPoi *poi = [_tripDetail.destinations objectAtIndex:sender.tag];
    CityDetailTableViewController *cityDetailCtl = [[CityDetailTableViewController alloc] init];
    cityDetailCtl.cityId = poi.cityId;
    [self.navigationController pushViewController:cityDetailCtl animated:YES];
}

/**
 *  更新三账单的路线数据
 */
- (void)reloadTripData
{
    _spotsListCtl.tripDetail = _tripDetail;
    _restaurantListCtl.tripDetail = _tripDetail;
    _shoppingListCtl.tripDetail = _tripDetail;
    [self updateDestinationsHeaderView];
}

- (void)setupViewControllers {
    _spotsListCtl = [[SpotsListViewController alloc] init];
    UIViewController *firstNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:_spotsListCtl];
    _spotsListCtl.rootViewController = self;
    _spotsListCtl.destinationsHeaderView = self.destinationsHeaderView;
    
    _restaurantListCtl = [[RestaurantsListViewController alloc] init];
    UIViewController *secondNavigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:_restaurantListCtl];
    _restaurantListCtl.rootViewController = self;
    _restaurantListCtl.destinationsHeaderView = self.destinationsHeaderView;
    
    _shoppingListCtl = [[ShoppingListViewController alloc] init];
    UIViewController *thirdNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:_shoppingListCtl];
    
    [self setViewControllers:@[firstNavigationController, secondNavigationController,
                                           thirdNavigationController]];
    [self customizeTabBarForController];
}

- (void)customizeTabBarForController
{
    self.tabBar.contentEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 60);
    self.tabBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 62);
    self.tabBar.backgroundColor = [UIColor whiteColor];
    UIView *toolBarViewLeft = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-62, 60, 62)];
    toolBarViewLeft.backgroundColor = [UIColor whiteColor];
    UIView *toolBarViewRight = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-62, 60, 62)];
    toolBarViewRight.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:toolBarViewLeft];
    [self.view addSubview:toolBarViewRight];
    
    UIImage *finishedImage = [ConvertMethods createImageWithColor:[UIColor whiteColor]];
    UIImage *unfinishedImage = [ConvertMethods createImageWithColor:[UIColor whiteColor]];

    NSArray *tabBarItemImages = @[@"first", @"second", @"third"];
    NSArray *tabBarItemTitles = @[@"线路日程", @"美食清单", @"爱购清单"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[self tabBar] items]) {
        [item setTitle:tabBarItemTitles[index]];
        item.titlePositionAdjustment = UIOffsetMake(0, 6);
        item.selectedTitleAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:11.0], NSForegroundColorAttributeName : APP_THEME_COLOR};
        item.unselectedTitleAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:11.0], NSForegroundColorAttributeName : UIColorFromRGB(0x797979)};

        item.itemHeight = 62.0;

        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        index++;
    }
}

@end




