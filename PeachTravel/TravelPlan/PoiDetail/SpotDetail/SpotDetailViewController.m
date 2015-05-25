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
#import "UIImage+BoxBlur.h"

@interface SpotDetailViewController () <UIActionSheetDelegate>
{
    UIButton *_favoriteBtn;
}
@property (nonatomic, strong) SpotDetailView *spotDetailView;
@property (nonatomic, strong) UIImageView *backGroundImageView;

@end

@implementation SpotDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = @"详情";
    
    self.view.backgroundColor = [UIColor whiteColor];
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIButton *talkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 44)];
    [talkBtn setImage:[UIImage imageNamed:@"ic_home_normal"] forState:UIControlStateNormal];
    [talkBtn addTarget:self action:@selector(shareToTalk) forControlEvents:UIControlEventTouchUpInside];
    
    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:talkBtn]];
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 44)];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_ztl_sc_2"] forState:UIControlStateNormal];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_ztl_sc_1"] forState:UIControlStateSelected];
    [_favoriteBtn addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:_favoriteBtn]];
    
    self.navigationItem.rightBarButtonItems = barItems;
    
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_spot_detail"];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_spot_detail"];
}

- (IBAction)favorite:(UIButton *)sender
{
    [MobClick event:@"event_city_favorite"];
    //先将收藏的状态改变
    //    _cityHeaderView.favoriteBtn.selected = !self.poi.isMyFavorite;
    //    _cityHeaderView.favoriteBtn.userInteractionEnabled = NO;
    
    [super asyncFavoritePoiWithCompletion:^(BOOL isSuccess) {
        //        _cityHeaderView.favoriteBtn.userInteractionEnabled = YES;
        //        if (!isSuccess) {
        //            _cityHeaderView.favoriteBtn.selected = !_cityHeaderView.favoriteBtn.selected;
        //
        //        }
        if (isSuccess) {
            _favoriteBtn.selected = !_favoriteBtn.selected;
        }
    }];
    
    
}
- (void)updateView
{
//    _spotDetailView = [[SpotDetailView alloc] initWithFrame:CGRectMake(15, 40, self.view.bounds.size.width-30, self.view.bounds.size.height-60)];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    _spotDetailView = [[SpotDetailView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
//    _spotDetailView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height+150) ;
    _spotDetailView.showsHorizontalScrollIndicator = NO;
    _spotDetailView.showsVerticalScrollIndicator = NO;
    _spotDetailView.spot = (SpotPoi *)self.poi;
    _spotDetailView.rootCtl = self;
//    self.navigationItem.title = self.poi.zhName;
    _spotDetailView.layer.cornerRadius = 4.0;
    [self.view addSubview:_spotDetailView];

//    _spotDetailView.transform = CGAffineTransformMakeScale(0.01, 0.01);
//
//    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        _spotDetailView.transform = CGAffineTransformMakeScale(1, 1);
//    } completion:nil];
    
    if (((SpotPoi *)self.poi).trafficInfoUrl == nil || [((SpotPoi *)self.poi).trafficInfoUrl isBlankString]) {
        _spotDetailView.trafficGuideBtn.enabled = NO;
    } else {
        [_spotDetailView.trafficGuideBtn addTarget:self action:@selector(trafficGuide:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (((SpotPoi *)self.poi).guideUrl == nil || [((SpotPoi *)self.poi).guideUrl isBlankString]) {
        _spotDetailView.travelGuideBtn.enabled = NO;
    } else {
        [_spotDetailView.travelGuideBtn addTarget:self action:@selector(travelGuide:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (((SpotPoi *)self.poi).tipsUrl == nil || [((SpotPoi *)self.poi).tipsUrl isBlankString]) {
        _spotDetailView.kendieBtn.enabled = NO;
    } else {
        [_spotDetailView.kendieBtn addTarget:self action:@selector(kengdie:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [_spotDetailView.closeBtn addTarget:self action:@selector(dismissCtl) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.favoriteBtn addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.addressBtn addTarget:self action:@selector(jumpToMap) forControlEvents:UIControlEventTouchUpInside];
    
    [_spotDetailView.shareBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.travelBtn addTarget:self action:@selector(showSpotDetail:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.phoneButton addTarget:self action:@selector(showSpotDetail:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.ticketBtn addTarget:self action:@selector(showSpotDetail:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.descDetailBtn addTarget:self action:@selector(showSpotDetail:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.bookBtn addTarget:self action:@selector(book:) forControlEvents:UIControlEventTouchUpInside];



}


- (void)dismissCtl
{
    [SVProgressHUD dismiss];
    [UIView animateWithDuration:0.0 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
    
}

- (void)dealloc
{
    NSLog(@"citydetailCtl dealloc");
    _spotDetailView = nil;
}


#pragma mark - Private Methods

- (void) loadData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (accountManager.isLogin) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:(kWindowWidth-22)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(self)weakSelf = self;
    [hud showHUDInViewController:weakSelf];
    NSString *url = [NSString stringWithFormat:@"%@%@", API_GET_SPOT_DETAIL, _spotId];
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        if (result == 0) {
            [SVProgressHUD dismiss];
            self.poi = [[SpotPoi alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self updateView];
        } else {
        }
        _favoriteBtn.selected=self.poi.isMyFavorite;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
    }];

    
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
    taoziMessageCtl.chatType = IMMessageTypeSpotMessageType;
}

/**
 *  进入景点的详细介绍的 h5
 *
 *  @param sender
 */
- (IBAction)showSpotDetail:(id)sender
{
    [MobClick event:@"event_spot_information"];
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = self.poi.zhName;
    webCtl.urlStr = ((SpotPoi *)self.poi).descUrl;
    webCtl.hideToolBar = YES;
    [self.navigationController pushViewController:webCtl animated:YES];
}


/**
 *  在线预订
 *
 *  @param sender
 */
- (IBAction)book:(id)sender
{
    [MobClick event:@"event_book_ticket"];

    SuperWebViewController *webCtl = [[SuperWebViewController alloc] initWithURL:[NSURL URLWithString:((SpotPoi *)self.poi).bookUrl]];
    webCtl.titleStr = @"在线预订";
//    webCtl.urlStr = ((SpotPoi *)self.poi).bookUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}

/**
 *  游玩指南
 *
 *  @param sender
 */
- (IBAction)travelGuide:(id)sender
{
    [MobClick event:@"event_spot_travel_experience"];

    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"景点体验";
    webCtl.urlStr = ((SpotPoi *)self.poi).guideUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}

/**
 *  坑爹攻略
 *
 *  @param sender
 */
- (IBAction)kengdie:(id)sender
{
    [MobClick event:@"event_spot_travel_tips"];

    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"游玩小贴士";
    webCtl.urlStr = ((SpotPoi *)self.poi).tipsUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}

/**
 *  交通指南
 *
 *  @param sender
 */
- (IBAction)trafficGuide:(id)sender
{
    [MobClick event:@"event_spot_traffic_summary"];

    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"景点交通";
    webCtl.urlStr = ((SpotPoi *)self.poi).trafficInfoUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}

/**
 *  进入地图导航
 *
 *  @param sender
 */
- (IBAction)jumpToMapview:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"其他软件导航"
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:nil];
    NSArray *platformArray = [ConvertMethods mapPlatformInPhone];
    for (NSDictionary *dic in platformArray) {
        [sheet addButtonWithTitle:[dic objectForKey:@"platform"]];
    }
    [sheet addButtonWithTitle:@"取消"];
    sheet.cancelButtonIndex = sheet.numberOfButtons-1;
    [sheet showInView:self.view];
}

//- (IBAction)favorite:(id)sender
//{
//    //先将收藏的状态改变
//    [MobClick event:@"event_spot_favorite"];
//    _spotDetailView.favoriteBtn.selected = !_spotDetailView.favoriteBtn.selected;
//    _spotDetailView.favoriteBtn.userInteractionEnabled = NO;
//    
//    [super asyncFavoritePoiWithCompletion:^(BOOL isSuccess) {
//        _spotDetailView.favoriteBtn.userInteractionEnabled = YES;
//        if (isSuccess) {
//        } else {      //如果失败了，再把状态改回来
//            _spotDetailView.favoriteBtn.selected = !_spotDetailView.favoriteBtn.selected;
//        }
//    }];
//
//}
-(void)jumpToMap
{
    [ConvertMethods jumpAppleMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
}
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    if (actionSheet.tag != kASShare) {
        NSArray *platformArray = [ConvertMethods mapPlatformInPhone];
        switch (buttonIndex) {
            case 0:
                switch ([[[platformArray objectAtIndex:0] objectForKey:@"type"] intValue]) {
                    case kAMap:
                        [ConvertMethods jumpGaodeMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                        break;
                        
                    case kBaiduMap: {
                        [ConvertMethods jumpBaiduMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                    }
                        break;
                        
                    case kAppleMap: {
                        [ConvertMethods jumpAppleMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                    }
                        
                    default:
                        break;
                }
                break;
                
            case 1:
                switch ([[[platformArray objectAtIndex:1] objectForKey:@"type"] intValue]) {
                    case kAMap:
                        [ConvertMethods jumpGaodeMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                        break;
                        
                    case kBaiduMap: {
                        [ConvertMethods jumpBaiduMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                    }
                        break;
                        
                    case kAppleMap: {
                        [ConvertMethods jumpAppleMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                    }
                        break;
                        
                    default:
                        break;
                }
                break;
                
            case 2:
                switch ([[[platformArray objectAtIndex:2] objectForKey:@"type"] intValue]) {
                    case kAMap:
                        [ConvertMethods jumpGaodeMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                        break;
                        
                    case kBaiduMap: {
                        [ConvertMethods jumpBaiduMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                    }
                        break;
                        
                    case kAppleMap: {
                        [ConvertMethods jumpAppleMapAppWithPoiName:self.poi.zhName lat:self.poi.lat lng:self.poi.lng];
                    }
                        break;
                        
                    default:
                        break;
                }
                break;
                
            default:
                break;
        }

    } else {
        [MobClick event:@"event_spot_share_to_talk"];
        [self shareToTalk];
    }
}



@end








