//
//  ShoppingDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "ShoppingDetailViewController.h"
#import "ShoppingDetailView.h"

@interface ShoppingDetailViewController ()
@property (nonatomic, strong) PoiSummary *shoppingPoi;
@end

@implementation ShoppingDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(0xf5f5f5);
    [self loadData];
}

- (void)updateView
{
    ShoppingDetailView *shoppingView = [[ShoppingDetailView alloc] initWithFrame:CGRectMake(8, 0, self.view.bounds.size.width-16, self.view.bounds.size.height)];
    shoppingView.shoppingPoi = self.shoppingPoi;
    [self.view addSubview:shoppingView];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - Private Methods

- (void) loadData
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@53b0599710114e05dc63b5a5", API_GET_SHOPPING_DETAIL];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        NSLog(@"/***获取购物详情数据****\n%@", responseObject);
        if (result == 0) {
            [SVProgressHUD dismiss];
            _shoppingPoi = [[PoiSummary alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self updateView];
        } else {
            [SVProgressHUD showErrorWithStatus:@"无法获取数据"];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [SVProgressHUD showErrorWithStatus:@"无法获取数据"];
    }];
    
    
}

@end
