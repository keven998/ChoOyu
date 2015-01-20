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

@property (nonatomic, strong) NSArray *tabbarButtonArray;
@property (nonatomic, strong) NSArray *tabbarPageControllerArray;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) UIView *tabBarView;

//指示哪个tabbar被选中了
@property (nonatomic, strong) UIImageView *tabBarSelectedView;

//编辑按钮
@property (nonatomic, strong) UIButton *editBtn;
//分享按钮
@property (nonatomic, strong) UIButton *shareBtn;
//复制行程按钮
@property (nonatomic, strong) UIButton *forkBtn;
//现实目的地按钮
@property (nonatomic, strong) UIButton *destinationBtn;

/**
 *  目的地titile 列表，三个界面共享
 */
@property (strong, nonatomic) DestinationsView *destinationsHeaderView;

@property (strong, nonatomic) UIButton *backButton;


@end

@implementation TripDetailRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setImage:[UIImage imageNamed:@"ic_navigation_back.png"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [_backButton setFrame:CGRectMake(0, 0, 48, 30)];
    [_backButton setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
    [_backButton setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];
    _backButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
    _backButton.titleEdgeInsets = UIEdgeInsetsMake(2, 1, 0, 0);
    _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:_backButton];
    self.navigationItem.leftBarButtonItem = barButton;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
   
    if (_canEdit) {
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        _shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_shareBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_shareBtn setImage:[UIImage imageNamed:@"ic_more.png"] forState:UIControlStateNormal];
        [_shareBtn setImage:[UIImage imageNamed:@"ic_more.png"] forState:UIControlStateHighlighted];
        [_shareBtn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:_shareBtn]];
        
        _editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_editBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_editBtn setImage:[UIImage imageNamed:@"ic_trip_edit.png"] forState:UIControlStateNormal];
        [_editBtn setImage:[UIImage imageNamed:@"ic_trip_edit.png"] forState:UIControlStateHighlighted];
        [_editBtn addTarget:self action:@selector(editTrip:) forControlEvents:UIControlEventTouchUpInside];
        [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:_editBtn]];
        
        _destinationBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_destinationBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_destinationBtn setImage:[UIImage imageNamed:@"ic_destination.png"] forState:UIControlStateNormal];
        [_destinationBtn setImage:[UIImage imageNamed:@"ic_destination.png"] forState:UIControlStateHighlighted];
        [_destinationBtn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:_destinationBtn]];


        self.navigationItem.rightBarButtonItems = barItems;
    } else {
        [_forkBtn setTitle:@"复制计划" forState:UIControlStateNormal];
        _forkBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [_forkBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [_forkBtn setTitleColor:[APP_THEME_COLOR colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [_forkBtn addTarget:self action:@selector(forkTrip:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * addBtn = [[UIBarButtonItem alloc]initWithCustomView:_forkBtn];
        self.navigationItem.rightBarButtonItem = addBtn;
    }
    
   
    
    [self setupViewControllers];
    if (_isMakeNewTrip) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"小桃可为你创建行程模版，制作计划更简单" delegate:self cancelButtonTitle:@"不需要" otherButtonTitles:@"创建", nil];
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
    [SVProgressHUD showSuccessWithStatus:@"已保存到旅行计划"];
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
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"计划已编辑，是否保存" delegate:self cancelButtonTitle:@"直接返回" otherButtonTitles:@"保存", nil];
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

- (void)editTrip:(id)sender
{
    _spotsListCtl.shouldEdit = YES;
    _restaurantListCtl.shouldEdit = YES;
}

/**
 *  新制作路线，传入目的地 id 列表获取路线详情
 */
- (void)loadNewTripDataWithRecommendData:(BOOL)isNeedRecommend
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
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
    NSNumber *imageWidth = [NSNumber numberWithInt:120];
    [params setObject:imageWidth forKey:@"imgWidth"];
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
        _destinationsHeaderView = [[DestinationsView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45) andContentOffsetX:10];
        _destinationsHeaderView.backgroundColor = [UIColor whiteColor];
    }
    return _destinationsHeaderView;
}

- (void)setCanEdit:(BOOL)canEdit
{
    _canEdit = canEdit;
    if (_canEdit) {
        _forkBtn = nil;
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        _shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [_shareBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_shareBtn setImage:[UIImage imageNamed:@"ic_more.png"] forState:UIControlStateNormal];
        [_shareBtn setImage:[UIImage imageNamed:@"ic_more.png"] forState:UIControlStateHighlighted];
        [_shareBtn addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:_shareBtn]];
        self.navigationItem.rightBarButtonItems = barItems;
    } else {
        _editBtn = nil;
        _shareBtn = nil;
        _destinationBtn = nil;
        [_forkBtn setTitle:@"复制计划" forState:UIControlStateNormal];
        _forkBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [_forkBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [_forkBtn setTitleColor:[APP_THEME_COLOR colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [_forkBtn addTarget:self action:@selector(forkTrip:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * addBtn = [[UIBarButtonItem alloc]initWithCustomView:_forkBtn];
        self.navigationItem.rightBarButtonItem = addBtn;
    }
    _shoppingListCtl.canEdit = _canEdit;
}

/**
 *  查看已存在的攻略的详情，传入攻略 ID
 */
- (void)checkTripData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
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
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:120];
    [params setObject:imageWidth forKey:@"imgWidth"];
    
    [manager GET:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
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
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:120];
    [params setObject:imageWidth forKey:@"imgWidth"];

    [manager GET:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            _tripDetail.tripId = [[responseObject objectForKey:@"result"] objectForKey:@"id"];
            self.canEdit = YES;
            [SVProgressHUD showHint:@"已保存到旅行计划"];
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
        if (rect.origin.y != 0) {
            rect.origin.y = 0;
        } else {
            return;
        }
        [UIView animateWithDuration:0.35 animations:^{
            _destinationsHeaderView.frame = rect;
        } completion:^(BOOL finished) {
        }];
    } else {
        if (rect.origin.y == 0) {
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
    NSMutableArray *array = [[NSMutableArray alloc] init];
    _spotsListCtl = [[SpotsListViewController alloc] init];

    _spotsListCtl.rootViewController = self;
    
    _restaurantListCtl = [[RestaurantsListViewController alloc] init];
    _restaurantListCtl.rootViewController = self;
    
    _shoppingListCtl = [[ShoppingListViewController alloc] init];
    _shoppingListCtl.canEdit = _canEdit;
    _shoppingListCtl.rootViewController = self;
    _shoppingListCtl.destinationsHeaderView = self.destinationsHeaderView;
    
    [self addChildViewController:_spotsListCtl];
    [self.view addSubview:_spotsListCtl.view];
    
    [_spotsListCtl.view setFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-54-64)];
    [_restaurantListCtl.view setFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-54-64)];
    [_shoppingListCtl.view setFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-54-64)];
    
    [array addObject:_spotsListCtl];
    [array addObject:_restaurantListCtl];
    [array addObject:_shoppingListCtl];
    _tabbarPageControllerArray = array;
    
    [self customizeTabBarForController];
    _currentViewController = _spotsListCtl;
    UIButton *btn = [_tabbarButtonArray firstObject];
    btn.selected = YES;
}

- (void)customizeTabBarForController
{
    _tabBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-54, self.view.frame.size.width, 54)];
    _tabBarView.backgroundColor = APP_THEME_COLOR;
    
    _tabBarSelectedView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    _tabBarSelectedView.image = [UIImage imageNamed:@"trip_tabbar_selected.png"];
    
    [self.view addSubview:_tabBarView];

    NSArray *tabBarItemTitles = @[@"玩安排", @"吃清单", @"买清单"];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    CGFloat width = _tabBarView.frame.size.width;

    NSInteger index = 0;
    for (int i=0; i<3; i++) {
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((25+(width-50)/3*i), 0, (width-50)/3, 54)];
        [button setTitle:tabBarItemTitles[i] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        [array addObject:button];
        [_tabBarView addSubview:button];
        button.tag = i;
        button.titleLabel.font = [UIFont systemFontOfSize:11.0];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(26, 0, -10, 0)];
        [button addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        view.userInteractionEnabled = NO;
        view.backgroundColor = [UIColor whiteColor];
        view.layer.cornerRadius = 5.0;
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 6, 6)];
        dotView.layer.cornerRadius = 3.0;
        dotView.backgroundColor = APP_THEME_COLOR;
        [view addSubview:dotView];
        view.center = CGPointMake(button.bounds.size.width/2, button.bounds.size.height/2);
        [button addSubview:view];
        
        if (i == 0) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(button.frame.size.width/2+7, button.frame.size.height/2-2, button.frame.size.width/2-7, 4)];
            lineView.backgroundColor = [UIColor whiteColor];
            [button addSubview:lineView];
            lineView.userInteractionEnabled = NO;
            _tabBarSelectedView.center = button.center;

        }
        if (i == 1) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(button.frame.size.width/2+7, button.frame.size.height/2-2, button.frame.size.width/2-7, 4)];
            lineView.backgroundColor = [UIColor whiteColor];
            lineView.userInteractionEnabled = NO;
            [button addSubview:lineView];
            
            UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height/2-2, button.frame.size.width/2-7, 4)];
            lineView2.backgroundColor = [UIColor whiteColor];
            lineView2.userInteractionEnabled = NO;
            [button addSubview:lineView2];
        }
        if (i == 2) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height/2-2, button.frame.size.width/2-7, 4)];
            lineView.backgroundColor = [UIColor whiteColor];
            lineView.userInteractionEnabled = NO;
            [button addSubview:lineView];
        }
        
        index++;
    }
    [_tabBarView addSubview:_tabBarSelectedView];
    _tabbarButtonArray = array;
}

- (void)changePage:(UIButton *)sender
{
    UIViewController *newController = [_tabbarPageControllerArray objectAtIndex:sender.tag];
    
    [UIView animateWithDuration:0.2 animations:^{
        [_tabBarSelectedView setCenter:sender.center];
    }];
    
    if ([newController isEqual:_currentViewController]) {
        return;
    }
    [self replaceController:_currentViewController newController:newController];
}

- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController
{
    [self addChildViewController:newController];
    [self transitionFromViewController:oldController toViewController:newController duration:0 options:UIViewAnimationOptionTransitionNone animations:nil completion:^(BOOL finished) {
        if (finished) {
            [newController didMoveToParentViewController:self];
            [oldController willMoveToParentViewController:nil];
            [oldController removeFromParentViewController];
            self.currentViewController = newController;

            NSInteger newIndex = [_tabbarPageControllerArray indexOfObject:newController];
            for (UIButton *btn in _tabbarButtonArray) {
                if ([_tabbarButtonArray indexOfObject:btn] == newIndex) {
                    btn.selected = YES;
                } else {
                    btn.selected = NO;
                }
            }
        }else{
            self.currentViewController = oldController;
        }
    }];
    [self.view bringSubviewToFront:_tabBarView];
}

#pragma mark AvtivityDelegate

- (void)didClickOnImageIndex:(NSInteger)imageIndex
{
    NSString *url = [NSString stringWithFormat:@"%@%@",TRIP_DETAIL_HTML, _tripDetail.tripId];
    NSString *shareContentWithoutUrl = [NSString stringWithFormat:@"我的《%@》来了，亲们快快来围观～",_tripDetail.tripTitle];
    NSString *shareContentWithUrl = [NSString stringWithFormat:@"我的《%@》来了，亲们快快来围观~ %@",_tripDetail.tripTitle, url];
    TaoziImage *image = [_tripDetail.images firstObject];
    NSString *imageUrl = image.imageUrl;
    UMSocialUrlResource *resource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:imageUrl];

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
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = url;
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatTimeline] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
            
        case 2: {
            [UMSocialData defaultData].extConfig.wechatSessionData.url = url;
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:nil completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
            
        case 3: {
            [UMSocialData defaultData].extConfig.qqData.url = url;
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQQ] content:shareContentWithoutUrl image:nil location:nil urlResource:resource presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
        }
            break;
            
        case 4: {
            [UMSocialData defaultData].extConfig.qzoneData.url = url;
            [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQzone] content:shareContentWithoutUrl image:nil location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
                if (response.responseCode == UMSResponseCodeSuccess) {
                    NSLog(@"分享成功！");
                }
            }];
            
        }
            break;
            
        case 5:
            [[UMSocialControllerService defaultControllerService] setShareText:shareContentWithUrl shareImage:nil socialUIDelegate:nil];
            
            [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina].snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);
            
            break;
            
        case 6:
            [[UMSocialControllerService defaultControllerService] setShareText:shareContentWithUrl shareImage:nil  socialUIDelegate:nil];
            
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




