//
//  ShoppingDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "ShoppingDetailViewController.h"
#import "CommonPoiDetailView.h"
#import "AccountManager.h"

@interface ShoppingDetailViewController ()
@property (nonatomic, strong) PoiSummary *shoppingPoi;
@end

@implementation ShoppingDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self loadData];
}

- (void)updateView
{
    CommonPoiDetailView *shoppingView = [[CommonPoiDetailView alloc] initWithFrame:CGRectMake(11, 64, self.view.bounds.size.width-22, self.view.bounds.size.height-64)];
    self.tabBarItem.title = self.shoppingPoi.zhName;
    shoppingView.poi = self.shoppingPoi;
    shoppingView.rootCtl = self;

    [self.view addSubview:shoppingView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - Private Methods

- (void) loadData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
     __weak typeof(ShoppingDetailViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];

    NSString *url = [NSString stringWithFormat:@"%@%@", API_GET_SHOPPING_DETAIL, _shoppingId];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        NSLog(@"/***获取购物详情数据****\n%@", responseObject);
        if (result == 0) {
            _shoppingPoi = [[PoiSummary alloc] initWithJson:[responseObject objectForKey:@"result"]];
            _shoppingPoi.poiType = kShoppingPoi;
            [self updateView];
        } else {
             if (self.isShowing) {
                [SVProgressHUD showHint:@"请求也是失败了"];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
}

@end
