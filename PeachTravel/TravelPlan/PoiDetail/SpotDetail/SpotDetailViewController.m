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

@property (nonatomic, strong) SpotPoi *spotPoi;
@property (nonatomic, strong) SpotDetailView *spotDetailView;
@property (nonatomic, strong) UIImageView *backGroundImageView;

@end

@implementation SpotDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _backGroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _backGroundImageView.image = [[self screenShotWithView:self.navigationController.view] drn_boxblurImageWithBlur:0.17];
    _backGroundImageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:_backGroundImageView];
    [self.view addSubview:view];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCtl)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:tap];
    
    [self loadData];
}

- (void)updateView
{
    _spotDetailView = [[SpotDetailView alloc] initWithFrame:CGRectMake(15, 40, self.view.bounds.size.width-30, self.view.bounds.size.height-60)];
    _spotDetailView.spot = self.spotPoi;
    self.navigationItem.title = self.spotPoi.zhName;
    _spotDetailView.layer.cornerRadius = 4.0;
    [self.view addSubview:_spotDetailView];

    _spotDetailView.transform = CGAffineTransformMakeScale(0.01, 0.01);

    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _spotDetailView.transform = CGAffineTransformMakeScale(1, 1);
    } completion:nil];
    
    if (self.spotPoi.trafficInfoUrl == nil || [self.spotPoi.trafficInfoUrl isBlankString]) {
        _spotDetailView.trafficGuideBtn.enabled = NO;
    } else {
        [_spotDetailView.trafficGuideBtn addTarget:self action:@selector(trafficGuide:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (self.spotPoi.guideUrl == nil || [self.spotPoi.guideUrl isBlankString]) {
        _spotDetailView.travelGuideBtn.enabled = NO;
    } else {
        [_spotDetailView.travelGuideBtn addTarget:self action:@selector(travelGuide:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (self.spotPoi.tipsUrl == nil || [self.spotPoi.tipsUrl isBlankString]) {
        _spotDetailView.kendieBtn.enabled = NO;
    } else {
        [_spotDetailView.kendieBtn addTarget:self action:@selector(kengdie:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [_spotDetailView.closeBtn addTarget:self action:@selector(dismissCtl) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.favoriteBtn addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.addressBtn addTarget:self action:@selector(jumpToMapview:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.shareBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.travelBtn addTarget:self action:@selector(showSpotDetail:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.ticketBtn addTarget:self action:@selector(showSpotDetail:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.descDetailBtn addTarget:self action:@selector(showSpotDetail:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.bookBtn addTarget:self action:@selector(book:) forControlEvents:UIControlEventTouchUpInside];



}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)dismissCtl
{
    [SVProgressHUD dismiss];
    self.navigationController.navigationBar.hidden = NO;
    [UIView animateWithDuration:0.0 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
    
}

- (void)dismissCtlWithHint:(NSString *)hint {
    [SVProgressHUD showHint:hint];
    self.navigationController.navigationBar.hidden = NO;
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

- (UIImage *)screenShotWithView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    image = [UIImage imageWithData:imageData];
    return image;
}

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
            _spotPoi = [[SpotPoi alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self updateView];
        } else {
            [self dismissCtlWithHint:@"无法获取数据"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        [self dismissCtlWithHint:@"呃～好像没找到网络"];
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

/**
 *  进入景点的详细介绍的 h5
 *
 *  @param sender
 */
- (IBAction)showSpotDetail:(id)sender
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = _spotPoi.zhName;
    webCtl.urlStr = _spotPoi.descUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}


/**
 *  在线预订
 *
 *  @param sender
 */
- (IBAction)book:(id)sender
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"在线预订";
    webCtl.urlStr = _spotPoi.bookUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}

/**
 *  游玩指南
 *
 *  @param sender
 */
- (IBAction)travelGuide:(id)sender
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"景点体验";
    webCtl.urlStr = _spotPoi.guideUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}

/**
 *  坑爹攻略
 *
 *  @param sender
 */
- (IBAction)kengdie:(id)sender
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"游玩小贴士";
    webCtl.urlStr = _spotPoi.tipsUrl;
    [self.navigationController pushViewController:webCtl animated:YES];
}

/**
 *  交通指南
 *
 *  @param sender
 */
- (IBAction)trafficGuide:(id)sender
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.titleStr = @"景点交通";
    webCtl.urlStr = _spotPoi.trafficInfoUrl;
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

- (IBAction)favorite:(id)sender
{
    //先将收藏的状态改变
    _spotDetailView.favoriteBtn.selected = !_spotDetailView.favoriteBtn.selected;
    _spotDetailView.favoriteBtn.userInteractionEnabled = NO;
    [super asyncFavorite:_spotPoi.spotId poiType:@"vs" isFavorite:!_spotPoi.isMyFavorite completion:^(BOOL isSuccess) {
        _spotDetailView.favoriteBtn.userInteractionEnabled = YES;
        if (isSuccess) {
            _spotPoi.isMyFavorite = !_spotPoi.isMyFavorite;
        } else {      //如果失败了，再把状态改回来
            _spotDetailView.favoriteBtn.selected = !_spotDetailView.favoriteBtn.selected;
        }
    }];
    
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
                        [ConvertMethods jumpGaodeMapAppWithPoiName:self.spotPoi.zhName lat:self.spotPoi.lat lng:self.spotPoi.lng];
                        break;
                        
                    case kBaiduMap: {
                        [ConvertMethods jumpBaiduMapAppWithPoiName:self.spotPoi.zhName lat:self.spotPoi.lat lng:self.spotPoi.lng];
                    }
                        break;
                        
                    case kAppleMap: {
                        [ConvertMethods jumpAppleMapAppWithPoiName:self.spotPoi.zhName lat:self.spotPoi.lat lng:self.spotPoi.lng];
                    }
                        
                    default:
                        break;
                }
                break;
                
            case 1:
                switch ([[[platformArray objectAtIndex:1] objectForKey:@"type"] intValue]) {
                    case kAMap:
                        [ConvertMethods jumpGaodeMapAppWithPoiName:self.spotPoi.zhName lat:self.spotPoi.lat lng:self.spotPoi.lng];
                        break;
                        
                    case kBaiduMap: {
                        [ConvertMethods jumpBaiduMapAppWithPoiName:self.spotPoi.zhName lat:self.spotPoi.lat lng:self.spotPoi.lng];
                    }
                        break;
                        
                    case kAppleMap: {
                        [ConvertMethods jumpAppleMapAppWithPoiName:self.spotPoi.zhName lat:self.spotPoi.lat lng:self.spotPoi.lng];
                    }
                        break;
                        
                    default:
                        break;
                }
                break;
                
            case 2:
                switch ([[[platformArray objectAtIndex:2] objectForKey:@"type"] intValue]) {
                    case kAMap:
                        [ConvertMethods jumpGaodeMapAppWithPoiName:self.spotPoi.zhName lat:self.spotPoi.lat lng:self.spotPoi.lng];
                        break;
                        
                    case kBaiduMap: {
                        [ConvertMethods jumpBaiduMapAppWithPoiName:self.spotPoi.zhName lat:self.spotPoi.lat lng:self.spotPoi.lng];
                    }
                        break;
                        
                    case kAppleMap: {
                        [ConvertMethods jumpAppleMapAppWithPoiName:self.spotPoi.zhName lat:self.spotPoi.lat lng:self.spotPoi.lng];
                    }                    break;
                        
                    default:
                        break;
                }
                break;
                
            default:
                break;
        }

    } else {
        [self shareToTalk];
    }
}


@end








