//
//  SpotDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/17/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "SpotDetailViewController.h"
#import "SpotDetailView.h"
#import "SpotPoi.h"


@interface SpotDetailViewController () 
@property (nonatomic, strong) SpotPoi *spotPoi;

@end

@implementation SpotDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self loadData];
}

- (void)updateView
{
    SpotDetailView *spotDetailView = [[SpotDetailView alloc] initWithFrame:self.view.frame];
    spotDetailView.spot = self.spotPoi;
    [self.view addSubview:spotDetailView];
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
    NSString *url = [NSString stringWithFormat:@"%@547bfdfdb8ce043eb2d860e6", API_GET_SPOT_DETAIL];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        NSLog(@"/***获取景点详情数据****\n%@", responseObject);
        if (result == 0) {
            [SVProgressHUD dismiss];
            _spotPoi = [[SpotPoi alloc] initWithJson:[responseObject objectForKey:@"result"]];
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

/**
 *  实现父类的发送 poi 到桃talk 的值传递
 *
 *  @param taoziMessageCtl 
 */
- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.messageId = _spotPoi.spotId;
    taoziMessageCtl.messageImage = ((TaoziImage *)[_spotPoi.images firstObject]).imageUrl;
    taoziMessageCtl.messageDesc = _spotPoi.desc;
    taoziMessageCtl.messageName = _spotPoi.zhName;
    taoziMessageCtl.messageTimeCost = _spotPoi.timeCostStr;
    taoziMessageCtl.descLabel.text = _spotPoi.desc;
}


@end








