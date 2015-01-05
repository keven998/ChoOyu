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

@interface SpotDetailViewController () <UIActionSheetDelegate>

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
    CGRect frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    _spotDetailView = [[SpotDetailView alloc] initWithFrame:frame];
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
    [super viewWillAppear:animated];
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
     __weak typeof(SpotDetailViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf.navigationController];

    NSString *url = [NSString stringWithFormat:@"%@%@", API_GET_SPOT_DETAIL, _spotId];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        NSLog(@"/***获取景点详情数据****\n%@", responseObject);
        if (result == 0) {
            _spotPoi = [[SpotPoi alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self updateView];
        } else {
            [SVProgressHUD showHint:@"请求也是失败了"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        [SVProgressHUD showHint:@"呃～好像没找到网络"];
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
 *  游玩指南
 *
 *  @param sender
 */
- (IBAction)travelGuide:(id)sender
{
    
}

/**
 *  坑爹攻略
 *
 *  @param sender
 */
- (IBAction)kengdie:(id)sender
{
    
}

/**
 *  交通指南
 *
 *  @param sender
 */
- (IBAction)trafficGuide:(id)sender
{
    
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
    _spotDetailView.favoriteBtn.selected = !_spotPoi.isMyFavorite;
    _spotDetailView.favoriteBtn.userInteractionEnabled = NO;
    [super asyncFavorite:_spotPoi.spotId poiType:@"vs" isFavorite:!_spotPoi.isMyFavorite completion:^(BOOL isSuccess) {
        _spotDetailView.favoriteBtn.userInteractionEnabled = YES;
        if (isSuccess) {
            _spotPoi.isMyFavorite = !_spotPoi.isMyFavorite;
            
        } else {      //如果失败了，再把状态改回来
            _spotDetailView.favoriteBtn.selected = !_spotPoi.isMyFavorite;
        }
    }];
    
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    NSArray *platformArray = [ConvertMethods mapPlatformInPhone];
    switch (buttonIndex) {
        case 0:
            switch ([[[platformArray objectAtIndex:0] objectForKey:@"type"] intValue]) {
                case kAMap: {
                    NSString *urlStr = [[NSString stringWithFormat:@"iosamap://viewMap?sourceApplication=PeachTravel&backScheme=taozi0601&poiname=%@&lat=%f&lon=%f&dev=1",self.spotPoi.zhName, self.spotPoi.lat, self.spotPoi.lng] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlStr]]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
                    }
                }
                    break;
                    
                case kBaiduMap: {
                     NSString *urlStr = [[NSString stringWithFormat:@"baidumap://map/marker?location=%f,%f&title=%@&content=%@&src=taozi",self.spotPoi.lat, self.spotPoi.lng, self.spotPoi.zhName, self.spotPoi.zhName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlStr]]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
                    }
                }
                    break;
                    
                case kAppleMap: {
                    CLLocationCoordinate2D from;
                    from.latitude = self.spotPoi.lat;
                    from.longitude = self.spotPoi.lng;
                    
                    MKMapItem *currentLocation;
                    if (from.latitude != 0.0) {
                        currentLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:from addressDictionary:nil]];
                        currentLocation.name = self.spotPoi.zhName;
                    }
                    
                    [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, nil] launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 1:
            switch ([[[platformArray objectAtIndex:1] objectForKey:@"type"] intValue]) {
                case kAMap: {
                    NSString *urlStr = [[NSString stringWithFormat:@"iosamap://viewMap?sourceApplication=PeachTravel&backScheme=taozi0601&poiname=%@&lat=%f&lon=%f&dev=1",self.spotPoi.zhName, self.spotPoi.lat, self.spotPoi.lng] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlStr]]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
                    }
                }
                    break;
                    
                case kBaiduMap: {
                    NSString *urlStr = [[NSString stringWithFormat:@"baidumap://map/marker?location=%f,%f&title=%@&content=%@&src=taozi",self.spotPoi.lat, self.spotPoi.lng, self.spotPoi.zhName, self.spotPoi.zhName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlStr]]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
                    }
                }
                    break;

                    
                case kAppleMap: {
                    CLLocationCoordinate2D from;
                    from.latitude = self.spotPoi.lat;
                    from.longitude = self.spotPoi.lng;
                    
                    MKMapItem *currentLocation;
                    if (from.latitude != 0.0) {
                        currentLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:from addressDictionary:nil]];
                        currentLocation.name = self.spotPoi.zhName;
                    }
                    
                    [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, nil] launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 2:
            switch ([[[platformArray objectAtIndex:2] objectForKey:@"type"] intValue]) {
                case kAMap: {
                     NSString *urlStr = [[NSString stringWithFormat:@"iosamap://viewMap?sourceApplication=PeachTravel&backScheme=taozi0601&poiname=%@&lat=%f&lon=%f&dev=1",self.spotPoi.zhName, self.spotPoi.lat, self.spotPoi.lng] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlStr]]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
                    }
                }
                    break;
                    
                case kBaiduMap: {
                    NSString *urlStr = [[NSString stringWithFormat:@"baidumap://map/marker?location=%f,%f&title=%@&content=%@&src=taozi",self.spotPoi.lat, self.spotPoi.lng, self.spotPoi.zhName, self.spotPoi.zhName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlStr]]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
                    }
                }
                    break;

                    
                case kAppleMap: {
                    CLLocationCoordinate2D from;
                    from.latitude = self.spotPoi.lat;
                    from.longitude = self.spotPoi.lng;
                    
                    MKMapItem *currentLocation;
                    if (from.latitude != 0.0) {
                        currentLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:from addressDictionary:nil]];
                        currentLocation.name = self.spotPoi.zhName;
                    }
                    
                    [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, nil] launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}


@end








