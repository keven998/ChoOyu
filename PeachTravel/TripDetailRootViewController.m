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

@interface TripDetailRootViewController ()

@property (nonatomic, strong) SpotsListViewController *spotsListCtl;
@property (nonatomic, strong) RestaurantsListViewController *restaurantListCtl;
@property (nonatomic, strong) ShoppingListViewController *shoppingListCtl;


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
    
    //获取路线模板数据,新制作路线的情况下
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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


- (void)reloadTripData
{
    _spotsListCtl.tripDetail = _tripDetail;
    _restaurantListCtl.tripDetail = _tripDetail;
    _shoppingListCtl.tripDetail = _tripDetail;
}

- (void)setupViewControllers {
    _spotsListCtl = [[SpotsListViewController alloc] init];
    UIViewController *firstNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:_spotsListCtl];
    _spotsListCtl.rootViewController = self;
    
    _restaurantListCtl = [[RestaurantsListViewController alloc] init];
    UIViewController *secondNavigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:_restaurantListCtl];
    _restaurantListCtl.rootViewController = self;
    
    _shoppingListCtl = [[ShoppingListViewController alloc] init];
    UIViewController *thirdNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:_shoppingListCtl];
    
    [self setViewControllers:@[firstNavigationController, secondNavigationController,
                                           thirdNavigationController]];
    [self customizeTabBarForController];
}

- (void)customizeTabBarForController
{
    UIImage *finishedImage = [UIImage imageNamed:@"tabbar_selected_background"];
    UIImage *unfinishedImage = [UIImage imageNamed:@"tabbar_normal_background"];
    NSArray *tabBarItemImages = @[@"first", @"second", @"third"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[self tabBar] items]) {
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




