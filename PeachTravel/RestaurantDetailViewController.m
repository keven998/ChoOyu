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
@property (nonatomic, strong) PoiSummary *restaurantPoi;

@end

@implementation RestaurantDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self loadData];
}

- (void)updateView
{
    self.navigationItem.title = _restaurantPoi.zhName;
    RestaurantDetailView *restaurantView = [[RestaurantDetailView alloc] initWithFrame:CGRectMake(11, 64, self.view.bounds.size.width-22, self.view.bounds.size.height-74)];
    restaurantView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    restaurantView.restaurantPoi = self.restaurantPoi;
    [self.view addSubview:restaurantView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Private Methods

- (void) loadData
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@", API_GET_RESTAURANT_DETAIL, _restaurantId];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        NSLog(@"/***获取美食详情数据****\n%@", responseObject);
        [SVProgressHUD dismiss];
        if (result == 0) {
            [SVProgressHUD dismiss];
            _restaurantPoi = [[PoiSummary alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self updateView];
        } else {
//            [SVProgressHUD showErrorWithStatus:@"无法获取数据"];
            [self showHint:@"请求也是失败了"];
        }
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//        [SVProgressHUD showErrorWithStatus:@"无法获取数据"];
        [SVProgressHUD dismiss];
        [self showHint:@"呃～好像没找到网络"];
    }];
}

- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.messageId = _restaurantPoi.poiId;
    taoziMessageCtl.messageImage = ((TaoziImage *)[_restaurantPoi.images firstObject]).imageUrl;
    taoziMessageCtl.messageDesc = _restaurantPoi.desc;
    taoziMessageCtl.messageName = _restaurantPoi.zhName;
    taoziMessageCtl.messagePrice = _restaurantPoi.priceDesc;
    taoziMessageCtl.messageRating = _restaurantPoi.rating;
    taoziMessageCtl.chatType = TZChatTypeFood;
    taoziMessageCtl.messageAddress = _restaurantPoi.address;
}

@end
