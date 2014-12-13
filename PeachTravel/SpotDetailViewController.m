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
#import "AccountManager.h"

@interface SpotDetailViewController () 
@property (nonatomic, strong) SpotPoi *spotPoi;
@property (nonatomic, strong) SpotDetailView *spotDetailView;

@end

@implementation SpotDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
}

- (void)updateView
{
    _spotDetailView = [[SpotDetailView alloc] initWithFrame:self.view.frame];
    _spotDetailView.spot = self.spotPoi;
    self.navigationItem.title = self.spotPoi.zhName;
    [self.view addSubview:_spotDetailView];
    [_spotDetailView.kendieBtn addTarget:self action:@selector(kengdie:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.travelGuideBtn addTarget:self action:@selector(travelGuide:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.trafficGuideBtn addTarget:self action:@selector(trafficGuide:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.favoriteBtn addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.addressBtn addTarget:self action:@selector(jumpToMapview:) forControlEvents:UIControlEventTouchUpInside];


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
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (accountManager.isLogin) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
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
    taoziMessageCtl.chatType = TZChatTypeSpot;
}

- (IBAction)travelGuide:(id)sender
{
    
}

- (IBAction)kengdie:(id)sender
{
    
}

- (IBAction)trafficGuide:(id)sender
{
    
}

- (IBAction)jumpToMapview:(id)sender
{
    
}

- (IBAction)favorite:(id)sender
{
    _spotDetailView.favoriteBtn.userInteractionEnabled = NO;
    [super asyncFavorite:_spotPoi.spotId poiType:@"vs" isFavorite:!_spotPoi.isMyFavorite completion:^(BOOL isSuccess) {
        _spotDetailView.favoriteBtn.userInteractionEnabled = YES;
        if (isSuccess) {
            _spotPoi.isMyFavorite = !_spotPoi.isMyFavorite;
            NSString *imageName = _spotPoi.isMyFavorite ? @"ic_favorite.png":@"ic_unFavorite.png";
            [_spotDetailView.favoriteBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        } else {
           
        }
    }];
    
}


@end








