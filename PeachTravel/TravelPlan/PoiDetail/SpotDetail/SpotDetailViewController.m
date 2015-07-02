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
#import "SpecialPoiCell.h"
#import "CommentTableViewCell.h"
#import "UIImage+BoxBlur.h"

@interface SpotDetailViewController () <UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) SpotDetailView *spotDetailView;
@property (nonatomic, strong) UIImageView *backGroundImageView;
@property (nonatomic, strong) UITableView *tableView;
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
    self.navigationItem.rightBarButtonItems = barItems;

    
    
//    _spotDetailView = [[SpotDetailView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 410 + 342/3 * SCREEN_HEIGHT / 736)];
//    self.tableView.tableHeaderView = _spotDetailView;
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

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.separatorColor = APP_DIVIDER_COLOR;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.tableHeaderView = self.spotDetailView;
        [self.tableView registerNib:[UINib nibWithNibName:@"SpotDetailCell" bundle:nil] forCellReuseIdentifier:@"detailCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"SpecialPoiCell" bundle:nil] forCellReuseIdentifier:@"specialCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"commentCell"];
    }
    return _tableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.poi.comments.count + 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 4) {
        return 67 * SCREEN_HEIGHT/736;
    } else if (indexPath.row == 4) {
        return  372/3;
    } else {
        return 100;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 4) {
        SpotDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.categoryLabel.text = @"地址";
            cell.infomationLabel.text = self.poi.address;
            cell.image.image = [UIImage imageNamed:@"poi_icon_add"];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else if (indexPath.row == 1) {
            cell.categoryLabel.text = @"电话";
            cell.infomationLabel.text = ((SpotPoi *)self.poi).telephone;
            cell.image.image = [UIImage imageNamed:@"poi_icon_phone"];
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else if (indexPath.row == 2) {
            cell.categoryLabel.text = @"时间";
            cell.infomationLabel.text = ((SpotPoi *)self.poi).openTime;
            cell.image.image = [UIImage imageNamed:@"icon_arrow"];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.categoryLabel.text = @"票价";
            cell.infomationLabel.text = ((SpotPoi *)self.poi).priceDesc;
            cell.image.image = [UIImage imageNamed:@"poi_icon_ticket_default"];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    } else if (indexPath.row == 4) {
        SpecialPoiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"specialCell" forIndexPath:indexPath];
        cell.userInteractionEnabled = YES;
        if (((SpotPoi *)self.poi).guideUrl == nil || [((SpotPoi *)self.poi).guideUrl isBlankString]) {
            cell.planBtn.enabled = NO;
        } else {
            [cell.planBtn addTarget:self action:@selector(travelGuide:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        if (((SpotPoi *)self.poi).tipsUrl == nil || [((SpotPoi *)self.poi).tipsUrl isBlankString]) {
            cell.tipsBtn.enabled = NO;
        } else {
            [cell.tipsBtn addTarget:self action:@selector(kengdie:) forControlEvents:UIControlEventTouchUpInside];
        }
    
        
        if (((SpotPoi *)self.poi).trafficInfoUrl == nil || [((SpotPoi *)self.poi).trafficInfoUrl isBlankString]) {
            cell.trafficBtn.enabled = NO;
        } else {
            [cell.trafficBtn addTarget:self action:@selector(trafficGuide:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return cell;
    } else {
        CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell" forIndexPath:indexPath];
        cell.commentDetail =[self.poi.comments objectAtIndex:1];
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 4) {
        if (indexPath.row == 0) {
            [self jumpToMap];
        } else if (indexPath.row == 1) {
            [self showSpotDetail:nil];
        } else if (indexPath.row == 2) {
            [self showSpotDetail:nil];
        } else {
            [self showSpotDetail:nil];
        }
    }

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)updateView
{
    _spotDetailView = [[SpotDetailView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 410 + 342/3 +14* SCREEN_HEIGHT / 736)];
    _spotDetailView.spot = (SpotPoi *)self.poi;
    _spotDetailView.rootCtl = self;
    _spotDetailView.layer.cornerRadius = 4.0;
    self.tableView.tableHeaderView = _spotDetailView;
    
    
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
    [_spotDetailView.addressBtn addTarget:self action:@selector(jumpToMap) forControlEvents:UIControlEventTouchUpInside];
    
    [_spotDetailView.shareBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.travelBtn addTarget:self action:@selector(showSpotDetail:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.phoneButton addTarget:self action:@selector(showSpotDetail:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.ticketBtn addTarget:self action:@selector(showSpotDetail:) forControlEvents:UIControlEventTouchUpInside];
    [_spotDetailView.descDetailBtn addTarget:self action:@selector(showSpotDetail:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showSpotDetail:)];
    
    [_spotDetailView.poisDesc addGestureRecognizer:tap];
    
    [_spotDetailView.bookBtn addTarget:self action:@selector(book:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.tableView];
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

- (void)loadData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (accountManager.isLogin) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:(kWindowWidth-22)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(SpotDetailViewController *)weakSelf = self;
    [hud showHUDInViewController:weakSelf content:64];
    NSString *url = [NSString stringWithFormat:@"%@%@", API_GET_SPOT_DETAIL, _spotId];
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger result = [[responseObject objectForKey:@"code"] integerValue];
        if (result == 0) {
            self.poi = [[SpotPoi alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self updateView];
        } else {
        }
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
    taoziMessageCtl.messageType = IMMessageTypeSpotMessageType;
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








