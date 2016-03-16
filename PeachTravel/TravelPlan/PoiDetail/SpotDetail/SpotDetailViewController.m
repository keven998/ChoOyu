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
#import "SuperWebViewController.h"
#import "SpotDetailCell.h"
#import "CommentTableViewCell.h"
#import "UIImage+BoxBlur.h"
#import "CityDescDetailViewController.h"
#import "PricePoiDetailController.h"

@interface SpotDetailViewController () <UIActionSheetDelegate>

@end

@implementation SpotDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    super.poiType = kSpotPoi;
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
      
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Private Methods

- (void)loadData
{
    NSString *url = [NSString stringWithFormat:@"%@%@", API_GET_SPOT_DETAIL, _spotId];
    [super loadDataWithUrl:url];
}

/**
 *  实现父类的发送 poi 到旅行派 的值传递
 *
 *  @param taoziMessageCtl
 */
- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.messageId = self.poi.poiId;
    taoziMessageCtl.messageImage = ((TaoziImage *)[self.poi.images firstObject]).imageUrl;
    taoziMessageCtl.messageDesc = self.poi.desc;
    taoziMessageCtl.messageName = self.poi.zhName;
    taoziMessageCtl.messageTimeCost = ((SpotPoi *)self.poi).timeCostStr;
    taoziMessageCtl.descLabel.text = self.poi.desc;
    taoziMessageCtl.messageType = IMMessageTypeSpotMessageType;
}

/**
 *  开放时间
 */
- (void)openTime
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"在线预订";
    webCtl.urlStr = self.poi.descUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}


/**
 *  在线预订
 *
 *  @param sender
 */
- (IBAction)book:(id)sender
{
    if ([((SpotPoi *)self.poi).bookUrl isEqualToString:@""]) {
        if (![self.poi.priceDesc isEqualToString:@""]) {
            PricePoiDetailController * pricePoi = [[PricePoiDetailController alloc] init];
            pricePoi.desc = ((SpotPoi *)self.poi).priceDesc;
            pricePoi.view.backgroundColor = [UIColor whiteColor];
            [self.navigationController pushViewController:pricePoi animated:YES];
        }
    }else{
        SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
        webCtl.titleStr = @"在线预订";
        webCtl.urlStr = ((SpotPoi *)self.poi).bookUrl;
        [self.navigationController pushViewController:webCtl animated:YES];
    }
}

- (void)showPoiDesc
{
    CityDescDetailViewController *cddVC = [[CityDescDetailViewController alloc]init];
    cddVC.desc = self.poi.desc;
    cddVC.title = @"景点简介";
    [self.navigationController pushViewController:cddVC animated:YES];
}


@end








