//
//  RestaurantDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RestaurantDetailViewController.h"
#import "RestaurantDetailView.h"

@interface RestaurantDetailViewController ()
@property (nonatomic, strong) RestaurantPoi *restaurantPoi;

@end

@implementation RestaurantDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = UIColorFromRGB(0xf5f5f5);
    [self loadData];
}

- (void)updateView
{
    self.navigationItem.title = _restaurantPoi.zhName;
    RestaurantDetailView *restaurantView = [[RestaurantDetailView alloc] initWithFrame:CGRectMake(11, 74, self.view.bounds.size.width-22, self.view.bounds.size.height-74)];
    restaurantView.restaurantPoi = self.restaurantPoi;
    [self.view addSubview:restaurantView];
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
    NSString *url = [NSString stringWithFormat:@"%@53b05a1210114e05e448131d", API_GET_RESTAURANT_DETAIL];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        NSLog(@"/***获取美食详情数据****\n%@", responseObject);
        if (result == 0) {
            [SVProgressHUD dismiss];
            _restaurantPoi = [[RestaurantPoi alloc] initWithJson:[responseObject objectForKey:@"result"]];
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

- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.messageId = _restaurantPoi.restaurantId;
    taoziMessageCtl.messageImage = ((TaoziImage *)[_restaurantPoi.images firstObject]).imageUrl;
    taoziMessageCtl.messageDesc = _restaurantPoi.desc;
    taoziMessageCtl.messageName = _restaurantPoi.zhName;
    taoziMessageCtl.messagePrice = _restaurantPoi.priceDesc;
    taoziMessageCtl.messageRating = _restaurantPoi.rating;
    taoziMessageCtl.chatType = TZChatTypeFood;
    taoziMessageCtl.messageAddress = _restaurantPoi.address;
}

@end
