//
//  ShoppingDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "ShoppingDetailViewController.h"
#import "CommonPoiDetailView.h"

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
    shoppingView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    self.tabBarItem.title = self.shoppingPoi.zhName;
    shoppingView.poi = self.shoppingPoi;
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
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@", API_GET_SHOPPING_DETAIL, _shoppingId];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        NSLog(@"/***获取购物详情数据****\n%@", responseObject);
        if (result == 0) {
            _shoppingPoi = [[PoiSummary alloc] initWithJson:[responseObject objectForKey:@"result"]];
            _shoppingPoi.poiType = TripShoppingPoi;
            [self updateView];
            [SVProgressHUD dismiss];
        } else {
            [SVProgressHUD showHint:@"请求也是失败了"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showHint:@"呃～好像没找到网络"];
    }];
}

@end
