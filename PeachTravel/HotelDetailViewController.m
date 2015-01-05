//
//  HotelDetailViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/22/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "HotelDetailViewController.h"
#import "CommonPoiDetailView.h"

@interface HotelDetailViewController ()
@property (nonatomic, strong) PoiSummary *hotelPoi;

@end

@implementation HotelDetailViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self loadData];
}

- (void)updateView
{
    self.navigationItem.title = _hotelPoi.zhName;
    CommonPoiDetailView *hotelView = [[CommonPoiDetailView alloc] initWithFrame:CGRectMake(11, 64, self.view.bounds.size.width-22, self.view.bounds.size.height-64)];
    hotelView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    hotelView.poi = self.hotelPoi;
    [self.view addSubview:hotelView];
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
     __weak typeof(HotelDetailViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf.navigationController];

    NSString *url = [NSString stringWithFormat:@"%@%@", API_GET_HOTEL_DETAIL, _hotelId];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        NSLog(@"/***获取酒店详情数据****\n%@", responseObject);
        if (result == 0) {
            _hotelPoi = [[PoiSummary alloc] initWithJson:[responseObject objectForKey:@"result"]];
            _hotelPoi.poiType  = kHotelPoi;
            [self updateView];
        } else {
            [SVProgressHUD showHint:@"请求也是失败了"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        [SVProgressHUD showHint:@"呃～好像没找到网络"];
    }];
}

- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.messageId = _hotelPoi.poiId;
    taoziMessageCtl.messageImage = ((TaoziImage *)[_hotelPoi.images firstObject]).imageUrl;
    taoziMessageCtl.messageDesc = _hotelPoi.desc;
    taoziMessageCtl.messageName = _hotelPoi.zhName;
    taoziMessageCtl.messagePrice = _hotelPoi.priceDesc;
    taoziMessageCtl.messageRating = _hotelPoi.rating;
    taoziMessageCtl.chatType = TZChatTypeFood;
    taoziMessageCtl.messageAddress = _hotelPoi.address;
}

@end
