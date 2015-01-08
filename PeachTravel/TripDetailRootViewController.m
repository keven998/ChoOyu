//
//  TripDetailRootViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TripDetailRootViewController.h"
#import "RDVTabBarItem.h"
#import "SpotsListViewController.h"
#import "RestaurantsListViewController.h"
#import "ShoppingListViewController.h"
#import "CityDestinationPoi.h"
#import "AccountManager.h"
#import "DestinationsView.h"
#import "DestinationUnit.h"
#import "CityDetailTableViewController.h"
#import "ShareActivity.h"
#import "TaoziChatMessageBaseViewController.h"
#import "UMSocialWechatHandler.h"
#import "UMSocial.h"
#import "CityDestinationPoi.h"
#import "ChatRecoredListTableViewController.h"
#import "MakePlanViewController.h"

@interface TripDetailRootViewController () <ActivityDelegate, TaoziMessageSendDelegate, ChatRecordListDelegate, CreateConversationDelegate>

@property (nonatomic, strong) SpotsListViewController *spotsListCtl;
@property (nonatomic, strong) RestaurantsListViewController *restaurantListCtl;
@property (nonatomic, strong) ShoppingListViewController *shoppingListCtl;
@property (nonatomic, strong) ChatRecoredListTableViewController *chatRecordListCtl;
@property (nonatomic, strong) UIButton *actionBtn;

/**
 *  目的地titile 列表，三个界面共享
 */
@property (strong, nonatomic) DestinationsView *destinationsHeaderView;

@property (strong, nonatomic) UIButton *backButton;


@end

@implementation TripDetailRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = YES;
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = CGRectMake(0.0, 0.0, 40.0, 27.0);
    _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_backButton];
    temporaryBarButtonItem.style = UIBarButtonItemStylePlain;
    [_backButton setImage:[UIImage imageNamed:@"ic_navigation_back"] forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_backButton];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    _actionBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 30)];
    [_actionBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    
    if (_canEdit) {
        [_actionBtn setImage:[UIImage imageNamed:@"ic_share_normal.png"] forState:UIControlStateNormal];
        [_actionBtn setImage:[UIImage imageNamed:@"ic_share_high.png"] forState:UIControlStateHighlighted];
        [_actionBtn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [_actionBtn setTitle:@"复制Memo" forState:UIControlStateNormal];
        _actionBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [_actionBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [_actionBtn setTitleColor:[APP_THEME_COLOR colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [_actionBtn addTarget:self action:@selector(forkTrip:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    _actionBtn.hidden = YES;
    
    UIBarButtonItem * addBtn = [[UIBarButtonItem alloc]initWithCustomView:_actionBtn];
    self.navigationItem.rightBarButtonItem = addBtn;
    
    [self setupViewControllers];
    if (_isMakeNewTrip) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否需要小桃为你推荐行程，制作memo更简单" delegate:self cancelButtonTitle:@"不需要" otherButtonTitles:@"为我推荐", nil];
        [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self loadNewTripDataWithRecommendData:NO];
            }
            if (buttonIndex == 1) {
                [self loadNewTripDataWithRecommendData:YES];
            }
        }];
    } else {
        [[TMCache sharedCache] objectForKey:@"last_tripdetail" block:^(TMCache *cache, NSString *key, id object)  {
            dispatch_async(dispatch_get_main_queue(), ^{
            if (object != nil) {
                TripDetail *td = [[TripDetail alloc] initWithJson:object];
                if ([td.tripId isEqualToString:_tripId]) {
                    _tripDetail = td;
                    [self reloadTripData];
                }
            }
            [self checkTripData];
            });
        }];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:userDidLogoutNoti object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isShowing = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isShowing = NO;
}

- (void) hint {
    [SVProgressHUD showSuccessWithStatus:@"已保存到旅行Memo"];
}

- (void)dealloc
{
    //只用从我的攻略进来 _contentMgrDelegate 才不会是 nil, 才会进行备份
    if (_contentMgrDelegate != nil && _tripDetail.backUpJson) {
        [_contentMgrDelegate tripUpdate:_tripDetail.backUpJson];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _spotsListCtl = nil;
    _restaurantListCtl = nil;
    _shoppingListCtl = nil;
    _chatRecordListCtl = nil;
}

/**
 *  不同情况的返回按钮相应的操作不一致
 */
- (void)goBack
{
    if (_tripDetail && _canEdit) {
        if (self.tripDetail.tripIsChange) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Memo已编辑，是否保存" delegate:self cancelButtonTitle:@"直接返回" otherButtonTitles:@"保存", nil];
            [alertView showAlertViewWithBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [self dismissCtl];
                }
                if (buttonIndex == 1) {
                    [self.tripDetail saveTrip:^(BOOL isSuccesss) {
                        if (isSuccesss) {
                            [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.4];
                        } else {
                            [SVProgressHUD showErrorWithStatus:@"保存失败了"];
                        }
                    }];
                }
            }];
        } else {
            [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.4];
        }
    } else {
        [self dismissCtl];
    }
}

- (void)dismissCtl
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)userDidLogout
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

/**
 *  新制作路线，传入目的地 id 列表获取路线详情
 */
- (void)loadNewTripDataWithRecommendData:(BOOL)isNeedRecommend
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }

    NSMutableArray *cityIds = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in _destinations) {
        [cityIds addObject:poi.cityId];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if (isNeedRecommend) {
        [params setObject:@"recommend" forKey:@"action"];
    } else {
        [params setObject:@"" forKey:@"action"];
    }
    [params setObject:cityIds forKey:@"locId"];
    __weak typeof(TripDetailRootViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    //获取路线模板数据,新制作路线的情况下
    [manager POST:API_CREATE_GUIDE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            _tripDetail = [[TripDetail alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self reloadTripData];
            [self performSelector:@selector(hint) withObject:nil afterDelay:1.0];
        } else {
             if (self.isShowing) {
                [SVProgressHUD showHint:@"请求也是失败了"];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
}

- (DestinationsView *)destinationsHeaderView
{
    if (!_destinationsHeaderView) {
        _destinationsHeaderView = [[DestinationsView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 45) andContentOffsetX:10];
        _destinationsHeaderView.backgroundColor = [UIColor whiteColor];
    }
    return _destinationsHeaderView;
}

- (void)setCanEdit:(BOOL)canEdit
{
    _canEdit = canEdit;
    if (_canEdit) {
        [_actionBtn setImage:[UIImage imageNamed:@"ic_more.png"] forState:UIControlStateNormal];
        [_actionBtn removeTarget:self action:@selector(forkTrip:) forControlEvents:UIControlEventTouchUpInside];
        [_actionBtn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        [_actionBtn setTitle:nil forState:UIControlStateNormal];
    } else {
        [_actionBtn setImage:nil forState:UIControlStateNormal];
        [_actionBtn setTitle:@"复制Memo" forState:UIControlStateNormal];
        [_actionBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [_actionBtn removeTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        [_actionBtn addTarget:self action:@selector(forkTrip:) forControlEvents:UIControlEventTouchUpInside];
    }
    _spotsListCtl.canEdit = _canEdit;
    _restaurantListCtl.canEdit = _canEdit;
    _shoppingListCtl.canEdit = _canEdit;
}

/**
 *  查看已存在的攻略的详情，传入攻略 ID
 */
- (void)checkTripData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@/all", API_GET_GUIDE, _tripId];
    TZProgressHUD *hud;
    if (_tripDetail == nil) {
        __weak typeof(TripDetailRootViewController *)weakSelf = self;
        hud = [[TZProgressHUD alloc] init];
        [hud showHUDInViewController:weakSelf];
    }
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (hud) [hud hideTZHUD];
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self setupViewWithData:[responseObject objectForKey:@"result"]];
        } else {
            if (self.isShowing) {
                [SVProgressHUD showHint:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (hud) [hud hideTZHUD];
        NSLog(@"%@", error);
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
}

- (void)setupViewWithData:(id)data
{
    _tripDetail = [[TripDetail alloc] initWithJson:data];
    [self reloadTripData];
}

/**
 *  更新三账单的目的地标题
 */
- (void)updateDestinationsHeaderView
{
    NSMutableArray *destinationsArray = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in _tripDetail.destinations) {
        if (poi.zhName) {
            [destinationsArray addObject:poi.zhName];
        }
    }
    _destinationsHeaderView.destinations = destinationsArray;
    for (DestinationUnit *unit in _destinationsHeaderView.destinationItmes) {
        [unit addTarget:self action:@selector(viewCityDetail:) forControlEvents:UIControlEventTouchUpInside];
    }
}

/**
 *  点击我的目的地进入城市详情
 *
 *  @param sender
 */
- (IBAction)viewCityDetail:(UIButton *)sender
{
    CityDestinationPoi *poi = [_tripDetail.destinations objectAtIndex:sender.tag];
    CityDetailTableViewController *cityDetailCtl = [[CityDetailTableViewController alloc] init];
    cityDetailCtl.cityId = poi.cityId;
    [self.navigationController pushViewController:cityDetailCtl animated:YES];
}

/**
 *  点击分享按钮
 *
 *  @param sender
 */
- (IBAction)share:(id)sender
{
    NSArray *shareButtonimageArray = @[@"ic_sns_talk.png", @"ic_sns_pengyouquan.png",  @"ic_sns_weixin.png", @"ic_sns_qq.png", @"ic_sns_qzone.png", @"ic_sns_sina.png", @"ic_sns_douban.png"];
    NSArray *shareButtonTitleArray = @[@"桃∙Talk", @"朋友圈", @"微信好友", @"QQ", @"QQ空间", @"新浪微博", @"豆瓣"];
    ShareActivity *shareActivity = [[ShareActivity alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"取消" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonimageArray];
    [shareActivity showInView:self.view];
}

/**
 *  复制路线
 *
 *  @param sender
 */
- (IBAction)forkTrip:(id)sender
{
    [self forkTrip];
}

- (void)forkTrip
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", API_FORK_TRIP, _tripDetail.tripId];
    __weak typeof(TripDetailRootViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            _tripDetail.tripId = [[responseObject objectForKey:@"result"] objectForKey:@"id"];
            self.canEdit = YES;
            [SVProgressHUD showHint:@"已保存到我的Memo"];
        } else {
             if (self.isShowing) {
                [SVProgressHUD showHint:@"请求也是失败了"];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        NSLog(@"%@", error);
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
}

/**
 *  更新三账单的路线数据
 */
- (void)reloadTripData
{
    _actionBtn.hidden = NO;
    _spotsListCtl.tripDetail = _tripDetail;
    _restaurantListCtl.tripDetail = _tripDetail;
    _shoppingListCtl.tripDetail = _tripDetail;
    [self updateDestinationsHeaderView];
}

/**
 *  是否显示目的地那一栏
 *
 *  @param show 
 */
- (void)showDHView:(BOOL) show {
    CGRect rect = _destinationsHeaderView.frame;
    if (show) {
        if (rect.origin.y != 64.0) {
            rect.origin.y = 64.0;
        } else {
            return;
        }
        [UIView animateWithDuration:0.35 animations:^{
            _destinationsHeaderView.frame = rect;
        } completion:^(BOOL finished) {
        }];
    } else {
        if (rect.origin.y == 64.0) {
            rect.origin.y -= rect.size.height;
            [UIView animateWithDuration:0.35 animations:^{
                _destinationsHeaderView.frame = rect;
            } completion:^(BOOL finished) {
            }];
        }
    }
}

- (void)setupViewControllers
{
    _spotsListCtl = [[SpotsListViewController alloc] init];
    _spotsListCtl.canEdit = _canEdit;
    UINavigationController *firstNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:_spotsListCtl];
    _spotsListCtl.rootViewController = self;
    _spotsListCtl.destinationsHeaderView = self.destinationsHeaderView;
    
    _restaurantListCtl = [[RestaurantsListViewController alloc] init];
    UINavigationController *secondNavigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:_restaurantListCtl];
    _restaurantListCtl.canEdit = _canEdit;
    _restaurantListCtl.rootViewController = self;
    _restaurantListCtl.destinationsHeaderView = self.destinationsHeaderView;
    
    _shoppingListCtl = [[ShoppingListViewController alloc] init];
    UINavigationController *thirdNavigationController = [[UINavigationController alloc]
                                                   initWithRootViewController:_shoppingListCtl];
    _shoppingListCtl.canEdit = _canEdit;
    _shoppingListCtl.rootViewController = self;
    _shoppingListCtl.destinationsHeaderView = self.destinationsHeaderView;
    
    [self setViewControllers:@[firstNavigationController, secondNavigationController,
                                           thirdNavigationController]];
    [self customizeTabBarForController];
}

- (void)customizeTabBarForController
{
    self.tabBar.contentEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 60);
    self.tabBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 62);
    self.tabBar.backgroundColor = [UIColor whiteColor];
    
    UIView *toolBarViewLeft = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-62, 60, 62)];
    toolBarViewLeft.backgroundColor = [UIColor whiteColor];
    UIView *toolBarViewRight = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-60, self.view.frame.size.height-62, 60, 62)];
    toolBarViewRight.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:toolBarViewLeft];
    [self.view addSubview:toolBarViewRight];
    
    //分割线
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-62, self.view.frame.size.width, 0.5)];
    spaceView.backgroundColor = UIColorFromRGB(0xcfcfcf);
    [self.view addSubview:spaceView];
    
    UIImage *finishedImage = [ConvertMethods createImageWithColor:[UIColor whiteColor]];
    UIImage *unfinishedImage = [ConvertMethods createImageWithColor:[UIColor whiteColor]];

    NSArray *tabBarItemImages = @[@"first", @"second", @"third"];
    NSArray *tabBarItemTitles = @[@"玩安排", @"吃清单", @"买清单"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[self tabBar] items]) {
        [item setTitle:tabBarItemTitles[index]];
        item.titlePositionAdjustment = UIOffsetMake(0, 6);
        item.selectedTitleAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:11.0], NSForegroundColorAttributeName : APP_THEME_COLOR};
        item.unselectedTitleAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:11.0], NSForegroundColorAttributeName : TEXT_COLOR_TITLE_SUBTITLE};

        item.itemHeight = 62.0;

        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        index++;
    }
}

#pragma mark AvtivityDelegate

- (void)didClickOnImageIndex:(NSInteger)imageIndex
{
    NSString *shareContentWithoutUrl = [NSString stringWithFormat:@"我搞了一条去北京的游玩的路线."];
    NSString *shareContentWithUrl = [NSString stringWithFormat:@"我搞了一条去北京玩的路线"];
    NSData *shareImageData;
    NSArray *_shareUrls;
    UMSocialUrlResource *resource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:@"http://www.lvxingpai.cn"];
    [UMSocialConfig setFinishToastIsHidden:NO position:UMSocialiToastPositionCenter];
    switch (imageIndex) {
            
        case 0: {
            _chatRecordListCtl = [[ChatRecoredListTableViewController alloc] init];
            _chatRecordListCtl.delegate = self;
            UINavigationController *nCtl = [[UINavigationController alloc] initWithRootViewController:_chatRecordListCtl];
            [self presentViewController:nCtl animated:YES completion:nil];
            
            break;
        }
            
        case 1: {
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = [_shareUrls firstObject];
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatTimeline] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
            
        case 2: {
            [UMSocialData defaultData].extConfig.wechatSessionData.url = [_shareUrls firstObject];
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:nil completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
            
        case 3: {
            [UMSocialData defaultData].extConfig.qqData.url = [_shareUrls firstObject];
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQQ] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
            
        case 4: {
            [UMSocialData defaultData].extConfig.qzoneData.url = [_shareUrls firstObject];
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQzone] content:shareContentWithoutUrl image:shareImageData location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
            
        }
            break;
            
        case 5:
            [[UMSocialControllerService defaultControllerService] setShareText:shareContentWithUrl shareImage:shareImageData socialUIDelegate:nil];
            
            [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
            
            break;
            
        case 6:
            [[UMSocialControllerService defaultControllerService] setShareText:shareContentWithUrl shareImage:shareImageData socialUIDelegate:nil];
            
            [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToDouban].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
            
            break;
            
        
            
            
        default:
            break;
    }
}

- (void)didClickOnCancelButton
{
    
}

#pragma mark - CreateConversationDelegate

- (void)createConversationSuccessWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup chatTitle:(NSString *)chatTitle
{
    TaoziChatMessageBaseViewController *taoziMessageCtl = [[TaoziChatMessageBaseViewController alloc] init];
    [self setChatMessageModel:taoziMessageCtl];
    taoziMessageCtl.delegate = self;
    taoziMessageCtl.chatTitle = chatTitle;
    taoziMessageCtl.chatter = chatter;
    taoziMessageCtl.isGroup = isGroup;
    
    [self.chatRecordListCtl dismissViewControllerAnimated:YES completion:^{
        [self presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:^(void) {
        }];
    }];
}


- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.delegate = self;
    taoziMessageCtl.chatType = TZChatTypeStrategy;
    taoziMessageCtl.messageId = self.tripDetail.tripId;
    
    NSMutableString *summary;
    for (CityDestinationPoi *poi in self.tripDetail.destinations) {
        NSString *s;
        if ([poi isEqual:[self.tripDetail.destinations lastObject]]) {
            s = poi.zhName;
        } else {
            s = [NSString stringWithFormat:@"%@-", poi.zhName];
        }
        [summary appendString:s];
    }
    
    taoziMessageCtl.messageDesc = summary;
    taoziMessageCtl.messageName = self.tripDetail.tripTitle;
    TaoziImage *image = [self.tripDetail.images firstObject];
    taoziMessageCtl.messageImage = image.imageUrl;
    taoziMessageCtl.messageTimeCost = [NSString stringWithFormat:@"%ld天", (long)self.tripDetail.dayCount];
}

#pragma mark - TaoziMsgSendDelegate

//用户确定发送poi给朋友
- (void)sendSuccess:(ChatViewController *)chatCtl
{
    [self dismissPopup];
    
    /*发送完成后不进入聊天界面
     [self.navigationController pushViewController:chatCtl animated:YES];
     */
    
    [SVProgressHUD showSuccessWithStatus:@"已发送~"];
    
}

- (void)sendCancel
{
    [self dismissPopup];
}

/**
 *  消除发送 poi 对话框
 *  @param sender
 */
- (void)dismissPopup
{
    if (self.popupViewController != nil) {
        [self dismissPopupViewControllerAnimated:YES completion:^{
            
        }];
    }
}


@end




