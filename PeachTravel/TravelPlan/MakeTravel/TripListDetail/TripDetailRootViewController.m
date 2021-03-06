//
//  TripDetailRootViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TripDetailRootViewController.h"
#import "PlanScheduleViewController.h"
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
#import "ForeignViewController.h"
#import "DomesticViewController.h"
#import "PXAlertView+Customization.h"
#import "TripPlanSettingViewController.h"
#import "PlansListTableViewController.h"
#import "TripFavoriteTableViewController.h"
#import "MyTripSpotsMapViewController.h"
#import "TZNavigationViewController.h"
#import "LoginViewController.h"
#import "CMPopTipView.h"

@interface TripDetailRootViewController () <ActivityDelegate, TaoziMessageSendDelegate, ChatRecordListDelegate, CreateConversationDelegate, UIActionSheetDelegate, REFrostedViewControllerDelegate>

@property (nonatomic, strong) PlanScheduleViewController *spotsListCtl;
@property (nonatomic, strong) TripFavoriteTableViewController *tripFavoriteCtl;
@property (nonatomic, strong) ChatRecoredListTableViewController *chatRecordListCtl;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;

@property (nonatomic, strong) NSArray *tabbarPageControllerArray;
@property (nonatomic, strong) UIViewController *currentViewController;

@property (nonatomic) CGPoint initialDraggingPoint;

/**
 *  点击目的地显示目的地界面
 */
@property (nonatomic, strong) UIView *destinationBkgView;

//完成按钮。。。uinavigationbar的返回按钮
//@property (nonatomic, strong) UIButton *finishBtn;

//指示哪个tabbar被选中了
@property (nonatomic, strong) UIButton *tabBarSelectedView;

//更多按钮
@property (nonatomic, strong) UIButton *moreBtn;
//复制行程按钮
@property (nonatomic, strong) UIButton *forkBtn;
//现实目的地按钮
@property (nonatomic, strong) UIButton *destinationBtn;

@property (strong, nonatomic) UIButton *backButton;

@property (nonatomic, strong) UIImageView *coverView;

@end

@implementation TripDetailRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.segmentedControl];
    
    [self setupViewControllers];
    [self setNavigationItems];
    
    self.frostedViewController.delegate = self;
    
    if (!_isMakeNewTrip) {
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
    } else {
        [self loadNewTripDataWithRecommendData:YES];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:userDidLogoutNoti object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_lxp_plan_agenda"];
    _isShowing = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_lxp_plan_agenda"];
    _isShowing = NO;
}

- (void)setNavigationItems
{
    if (_canEdit) {
        [self setupNavigationRightItems:NO];
        _userId = [AccountManager shareAccountManager].account.userId;
        
    } else {
        _forkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 24)];
        _forkBtn.layer.cornerRadius = 2.0;
        _forkBtn.layer.borderColor = COLOR_TEXT_II.CGColor;
        _forkBtn.layer.borderWidth = 1.0;
        [_forkBtn setTitle:@"复制" forState:UIControlStateNormal];
        _forkBtn.titleLabel.font = [UIFont boldSystemFontOfSize:11.0];
        [_forkBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
        [_forkBtn setTitleColor:COLOR_DISABLE forState:UIControlStateHighlighted];
        [_forkBtn addTarget:self action:@selector(forkTrip:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem * addBtn = [[UIBarButtonItem alloc]initWithCustomView:_forkBtn];
        self.frostedViewController.navigationItem.rightBarButtonItem = addBtn;
        
        UIButton *bbtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [bbtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [bbtn setImage:[UIImage imageNamed:@"common_icon_navigation_back_normal"] forState:UIControlStateNormal];
        [bbtn setImage:[UIImage imageNamed:@"common_icon_navigation_back_highlight"] forState:UIControlStateHighlighted];
        [bbtn addTarget:self action:@selector(dismissCtl) forControlEvents:UIControlEventTouchUpInside];
        self.frostedViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bbtn];
    }
}

- (void)setupNavigationRightItems:(BOOL)isEditing
{
    self.frostedViewController.navigationItem.rightBarButtonItems = nil;
    if (isEditing) {
        _editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        [_editBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_editBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_editBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [_editBtn addTarget:self action:@selector(editTrip:) forControlEvents:UIControlEventTouchUpInside];
        _editBtn.selected = YES;
        self.frostedViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_editBtn];
        self.frostedViewController.navigationItem.leftBarButtonItems = nil;
    } else {
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        _moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 44)];
        [_moreBtn setImage:[UIImage imageNamed:@"common_icon_navigaiton_menu.png"] forState:UIControlStateNormal];
        _moreBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        [_moreBtn addTarget:self action:@selector(showMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barItem = [[UIBarButtonItem alloc]initWithCustomView:_moreBtn];
        [barItems addObject: barItem];
        
        UIButton *mapBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 44)];
        [mapBtn setImage:[UIImage imageNamed:@"icon_navigation_map.png"] forState:UIControlStateNormal];
        [mapBtn addTarget:self action:@selector(mapView) forControlEvents:UIControlEventTouchUpInside];
        mapBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 2);
        [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:mapBtn]];
        
        self.frostedViewController.navigationItem.rightBarButtonItems = barItems;
        
        UIButton *bbtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [bbtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [bbtn setImage:[UIImage imageNamed:@"common_icon_navigation_back_normal"] forState:UIControlStateNormal];
        [bbtn setImage:[UIImage imageNamed:@"common_icon_navigation_back_highlight"] forState:UIControlStateHighlighted];
        [bbtn addTarget:self action:@selector(dismissCtl) forControlEvents:UIControlEventTouchUpInside];
        self.frostedViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bbtn];
        BOOL isNotShouldShowNaviTipsView = [[[NSUserDefaults standardUserDefaults] objectForKey:@"kTripDetailRootCtlNaviTipsView"] boolValue];
        if (!isNotShouldShowNaviTipsView) {
            [self showNaviTipsViewWithBarButtonItem:barItem];
        }
    }
}

- (void)dealloc
{
    //只用从我的攻略进来 _contentMgrDelegate 才不会是 nil, 才会进行备份
    if (_contentMgrDelegate != nil && _tripDetail.backUpJson) {
        [_contentMgrDelegate tripUpdate:_tripDetail.backUpJson];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _spotsListCtl = nil;
    _tripFavoriteCtl = nil;
    _chatRecordListCtl = nil;
}

//显示 navibar 上的页内引导页面
- (void)showNaviTipsViewWithBarButtonItem:(UIBarButtonItem *)barItem
{
    CMPopTipView *tipView = [[CMPopTipView alloc] initWithMessage:@"点击这里修改计划"];
    tipView.backgroundColor = APP_THEME_COLOR;
    tipView.dismissTapAnywhere = YES;
    tipView.hasGradientBackground = NO;
    tipView.hasShadow = YES;
    tipView.borderColor = APP_THEME_COLOR;
    tipView.sidePadding = 5;
    tipView.maxWidth = 110;
    tipView.has3DStyle = NO;
    [tipView presentPointingAtBarButtonItem:barItem animated:YES];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"kTripDetailRootCtlNaviTipsView"];
}

//显示 收藏 上的页内引导页面
- (void)showCollectionTipsViewWithView:(UIView *)sourceView
{
    CMPopTipView *tipView = [[CMPopTipView alloc] initWithMessage:@"添加备选心愿到收藏"];
    tipView.backgroundColor = APP_THEME_COLOR;
    tipView.dismissTapAnywhere = YES;
    tipView.hasGradientBackground = NO;
    tipView.hasShadow = YES;
    tipView.borderColor = APP_THEME_COLOR;
    tipView.sidePadding = 5;
    tipView.maxWidth = 110;
    tipView.has3DStyle = NO;
    tipView.offsetX = sourceView.bounds.size.width/4;
    [tipView presentPointingAtView:sourceView inView:self.view animated:YES];
    objc_setAssociatedObject(self, @"collectionTipsView", tipView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"kTripDetailRootCtlCollectionTipsView"];
}

- (void)hideCollectionTipsViewWithView
{
    id tipsView = objc_getAssociatedObject(self, @"collectionTipsView");
    if (tipsView) {
        [((CMPopTipView *)tipsView) dismissAnimated: YES];
    }
}

- (UISegmentedControl *)segmentedControl
{
    if (!_segmentedControl) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"行程", @"收集"]];
        _segmentedControl.selectedSegmentIndex = 0;
        _segmentedControl.frame = CGRectMake(self.view.bounds.size.width/2-100, 7 + 64, 200, 30);
        [_segmentedControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
        _segmentedControl.tintColor = APP_THEME_COLOR;
    }
    return _segmentedControl;
}

#pragma mark - IBAction

- (IBAction)finishEidtTrip:(id)sender
{
    
    TZProgressHUD *hud;
    if (self.tripDetail.tripIsChange) {
        hud = [[TZProgressHUD alloc] init];
        [hud showHUD];
    }
    [self.tripDetail saveTrip:^(BOOL isSuccesss) {
        if (hud) {
            [hud hideTZHUD];
        }
        if (isSuccesss) {
            if ([_currentViewController isKindOfClass:[PlanScheduleViewController class]]) {
                //                _spotsListCtl.shouldEdit = NO;
            }
            _editBtn.selected = !_editBtn.selected;
        } else {
            [SVProgressHUD showErrorWithStatus:@"保存失败了"];
        }
    }];
}

- (void)mapView {
    [MobClick event:@"navigation_item_lxp_plan_mapview"];
    MyTripSpotsMapViewController *mapViewCtl = [[MyTripSpotsMapViewController alloc] init];
    mapViewCtl.tripDetail = _tripDetail;
    mapViewCtl.titleText = self.frostedViewController.navigationItem.title;
    [self.frostedViewController.navigationController pushViewController:mapViewCtl animated:YES];
    
}

- (void)dismissCtl
{
    if (self.frostedViewController.navigationController.childViewControllers.count > 1) {
        [self.frostedViewController.navigationController popViewControllerAnimated:YES];
    } else {
        [self.frostedViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)userDidLogout
{
    [self.frostedViewController.navigationController popToRootViewControllerAnimated:YES];
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
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    
    NSMutableArray *cityIds = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in _destinations) {
        [cityIds addObject:poi.cityId];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:150];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithBool: isNeedRecommend] forKey:@"initViewSpots"];
    [params setObject:@"create" forKey:@"action"];
    
    [params setObject:cityIds forKey:@"locId"];
    
    __weak typeof(TripDetailRootViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    
    NSString *url = [NSString stringWithFormat:@"%@%ld/guides", API_USERS, [AccountManager shareAccountManager].account.userId];
    //获取路线模板数据,新制作路线的情况下
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            _tripDetail = [[TripDetail alloc] initWithJson:[responseObject objectForKey:@"result"]];
            accountManager.account.guideCnt += 1;
            [self reloadTripData];
            [[NSNotificationCenter defaultCenter] postNotificationName:updateGuideListNoti object:nil];
            if (isNeedRecommend) {
                [self performSelector:@selector(hintBuildRoutes) withObject:nil afterDelay:0.5];
            }
        } else {
            if (self.isShowing) {
                [SVProgressHUD showHint:@"请求也是失败了"];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
        }
    }];
}

- (void)hintBuildRoutes {
    PXAlertView *alertView = [PXAlertView showAlertWithTitle:@"提示"
                                                     message:[NSString stringWithFormat:@"为你创建了%lu天行程，可自由调整", (unsigned long)_tripDetail.itineraryList.count]
                                                 cancelTitle:@"确定"
                                                  completion:nil];
    [alertView useDefaultIOS7Style];
    [alertView setTitleFont:[UIFont systemFontOfSize:17]];
    [alertView setMessageColor:TEXT_COLOR_TITLE_SUBTITLE];
}

- (void)setCanEdit:(BOOL)canEdit
{
    _canEdit = canEdit;
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
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%ld/guides/%@", API_USERS, (long)_userId, _tripId];
    TZProgressHUD *hud;
    if (_tripDetail == nil) {
        __weak typeof(TripDetailRootViewController *)weakSelf = self;
        hud = [[TZProgressHUD alloc] init];
        [hud showHUDInViewController:weakSelf content:64];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:200];
    [params setObject:imageWidth forKey:@"imgWidth"];
    
    [manager GET:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (hud) [hud hideTZHUD];
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self setupViewWithData:[responseObject objectForKey:@"result"]];
        } else {
            if (self.isShowing) {
                [SVProgressHUD showHint:HTTP_FAILED_HINT];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (hud) [hud hideTZHUD];
        NSLog(@"%@", error);
        if (self.isShowing) {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
        }
    }];
}

- (void)setupViewWithData:(id)data
{
    _tripDetail = [[TripDetail alloc] initWithJson:data];
    [self reloadTripData];
}

/**
 *  点击我的目的地进入城市详情
 *
 *  @param sender
 */
- (void)viewCityDetail:(NSString *)cityId
{
    CityDetailTableViewController *cityDetailCtl = [[CityDetailTableViewController alloc] init];
    cityDetailCtl.cityId = cityId;
    [self.frostedViewController.navigationController pushViewController:cityDetailCtl animated:YES];
}

/**
 *  点击分享按钮
 *
 *  @param sender
 */
- (IBAction)share:(id)sender
{
    NSArray *shareButtonimageArray = @[@"ic_sns_talk.png", @"ic_sns_pengyouquan.png",  @"ic_sns_weixin.png", @"ic_sns_qq.png", @"ic_sns_qzone.png", @"ic_sns_sina.png", @"ic_sns_douban.png"];
    NSArray *shareButtonTitleArray = @[@"Talk", @"朋友圈", @"微信朋友", @"QQ", @"QQ空间", @"新浪微博", @"豆瓣"];
    ShareActivity *shareActivity = [[ShareActivity alloc] initWithTitle:@"转发至" delegate:self cancelButtonTitle:@"取消" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonimageArray];
    [shareActivity showInView:self.view];
}

/**
 *  点击navigationbar上的更多按钮
 *  @param sender
 */
- (IBAction)showMoreAction:(id)sender
{
    [MobClick event:@"navigiation_item_lxp_plan_setting"];
    if (!_tripDetail) {
        return;
    }
    
    [self.view endEditing:YES];
    
    [self.frostedViewController.view endEditing:YES];
    [self.frostedViewController presentMenuViewController];
}

/**
 *  点击navigationbar上的目的地按钮
 *
 *  @param sender
 */
- (IBAction)showDestination:(id)sender
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in _tripDetail.destinations) {
        [array addObject:poi.zhName];
    }
    
    if (!_destinationBkgView) {
        _destinationBkgView = [[UIView alloc] initWithFrame:self.view.bounds];
        UITapGestureRecognizer *tapGester = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDestinationView:)];
        tapGester.numberOfTapsRequired = 1;
        tapGester.numberOfTouchesRequired = 1;
        [_destinationBkgView addGestureRecognizer:tapGester];
    }
    _destinationBkgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    UIView *panelView = [[UIView alloc] initWithFrame:CGRectMake(0, _destinationBkgView.bounds.size.height, _destinationBkgView.bounds.size.width, 340)];
    panelView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    
    UIButton *titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _destinationBkgView.bounds.size.width, 49)];
    titleBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [titleBtn setTitle:@"目的地" forState:UIControlStateNormal];
    [titleBtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
    titleBtn.userInteractionEnabled = NO;
    [panelView addSubview:titleBtn];
    
    UIImageView *spaceView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, _destinationBkgView.bounds.size.width, 1)];
    spaceView.image = [UIImage imageNamed:@"ic_dot_line.png"];
    [panelView addSubview:spaceView];
    
    UIImageView *spaceViewTwo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 299, _destinationBkgView.bounds.size.width, 1)];
    spaceViewTwo.image = [UIImage imageNamed:@"ic_dot_line.png"];
    [panelView addSubview:spaceViewTwo];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 300, _destinationBkgView.bounds.size.width, 40)];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(hideDestinationView:) forControlEvents:UIControlEventTouchUpInside];
    [panelView addSubview:cancelBtn];
    
    [_destinationBkgView addSubview:panelView];
    
    [self.frostedViewController.navigationController.view addSubview:_destinationBkgView];
    
    [UIView animateWithDuration:0.2 animations:^{
        panelView.frame = CGRectMake(0, _destinationBkgView.bounds.size.height-340, _destinationBkgView.bounds.size.width, 340);
    } completion:nil];
}


- (IBAction)hideDestinationView:(id)sender
{
    [_destinationBkgView removeFromSuperview];
    _destinationBkgView = nil;
}

/**
 *  点击navigationbar上的编辑按钮
 *
 *  @param sender
 */
- (void)editTrip:(UIButton *)sender
{
    if (!_tripDetail) {
        return;
    }
    BOOL status = sender.selected;
    if (!status) {
        if ([_currentViewController isKindOfClass:[PlanScheduleViewController class]]) {
            //            _spotsListCtl.shouldEdit = YES;
        }
        sender.selected = !status;
    } else {
        [self finishEidtTrip:nil];
    }
    
    [self setupNavigationRightItems:!status];
}

/**
 *  复制路线
 *
 *  @param sender
 */
- (IBAction)forkTrip:(id)sender
{
    // 2.判断是否登录,如果没有登录,跳转到登录界面
    if (![[AccountManager shareAccountManager] isLogin]) {
        [self userLogin];
        return;
    }
    [MobClick event:@"navigation_item_copy_plan"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"复制\"%@\"到我的旅行计划", _tripDetail.tripTitle] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [self forkTrip];
        }
    }];
}

- (void)userLogin
{
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
    loginCtl.isPushed = NO;
    [self.frostedViewController.navigationController presentViewController:nctl animated:YES completion:nil];
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
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%ld/guides", API_USERS, (long)[AccountManager shareAccountManager].account.userId];
    __weak typeof(TripDetailRootViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:150];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:_tripDetail.tripId forKeyedSubscript:@"guideId"];
    [params setObject:@"fork" forKey:@"action"];
    
    [manager POST:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            accountManager.account.guideCnt += 1;
            PlansListTableViewController *myGuidesCtl = [[PlansListTableViewController alloc] initWithUserId:accountManager.account.userId];
            NSMutableArray *clts = [NSMutableArray arrayWithArray:[self.frostedViewController.navigationController childViewControllers]];
            myGuidesCtl.userName = accountManager.account.nickName;
            myGuidesCtl.copyPatch = YES;
            [clts replaceObjectAtIndex:(clts.count-1) withObject:myGuidesCtl];
            [self.frostedViewController.navigationController setViewControllers:clts animated:YES];
        } else {
            if (self.isShowing) {
                [SVProgressHUD showHint:@"请求也是失败了"];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        NSLog(@"%@", error);
        if (self.isShowing) {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
        }
    }];
}

/**
 *  更新三账单的路线数据
 */
- (void)reloadTripData
{
    _spotsListCtl.tripDetail = _tripDetail;
    _tripFavoriteCtl.tripDetail = _tripDetail;
    ((TripPlanSettingViewController *)self.frostedViewController.menuViewController).tripDetail = self.tripDetail;
    
    self.frostedViewController.navigationItem.title = _tripDetail.tripTitle;
}

- (void)setupViewControllers
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    _spotsListCtl = [[PlanScheduleViewController alloc] init];
    _tripFavoriteCtl = [[TripFavoriteTableViewController alloc] init];
    _tripFavoriteCtl.canEdit = _canEdit;
    [_spotsListCtl.view setFrame:CGRectMake(0, 44+64, CGRectGetWidth(self.frostedViewController.view.bounds), CGRectGetHeight(self.frostedViewController.view.bounds)-44-64-49)];
    [_tripFavoriteCtl.view setFrame:CGRectMake(0, 44+64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-44-64)];
    [self addChildViewController:_spotsListCtl];
    [self.view addSubview:_spotsListCtl.view];
    
    [array addObject:_spotsListCtl];
    [array addObject:_tripFavoriteCtl];
    _tabbarPageControllerArray = array;

    _currentViewController = _spotsListCtl;
}

- (void)changePage:(UISegmentedControl *)sender
{
    [self hideCollectionTipsViewWithView];
    UIViewController *newController = [_tabbarPageControllerArray objectAtIndex:sender.selectedSegmentIndex];
    [self replaceController:_currentViewController newController:newController];
    if (sender.selectedSegmentIndex == 1) {
        BOOL isNotShouldShowNaviTipsView = [[[NSUserDefaults standardUserDefaults] objectForKey:@"kTripDetailRootCtlCollectionTipsView"] boolValue];
        if (!isNotShouldShowNaviTipsView) {
            [self showCollectionTipsViewWithView:sender];
        }
    }
}

- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController
{
    [self addChildViewController:newController];
    [self transitionFromViewController:oldController toViewController:newController duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
        if (finished) {
            [oldController removeFromParentViewController];
            self.currentViewController = newController;
            [self.view bringSubviewToFront:_segmentedControl];
            
        } else {
            self.currentViewController = oldController;
        }
    }];
}

#pragma mark - AvtivityDelegate

- (void)didClickOnImageIndex:(NSInteger)imageIndex
{
    NSString *url = _tripDetail.tripDetailUrl;
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
            TZNavigationViewController *nCtl = [[TZNavigationViewController alloc] initWithRootViewController:_chatRecordListCtl];
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

#pragma mark - DestinationsViewDelegate

- (void)destinationDidSelect:(NSInteger)selectedIndex
{
    [self hideDestinationView:nil];
    CityDestinationPoi *poi =  [_tripDetail.destinations objectAtIndex:selectedIndex];
    CityDetailTableViewController *cityDetailCtl = [[CityDetailTableViewController alloc] init];
    cityDetailCtl.cityId = poi.cityId;
    [self.frostedViewController.navigationController pushViewController:cityDetailCtl animated:YES];
}

#pragma mark - CreateConversationDelegate

- (void)createConversationSuccessWithChatter:(NSInteger)chatterId chatType:(IMChatType)chatType chatTitle:(NSString *)chatTitle
{
    TaoziChatMessageBaseViewController *taoziMessageCtl = [[TaoziChatMessageBaseViewController alloc] init];
    [self setChatMessageModel:taoziMessageCtl];
    taoziMessageCtl.delegate = self;
    taoziMessageCtl.chatTitle = chatTitle;
    taoziMessageCtl.chatterId = chatterId;
    taoziMessageCtl.chatType = chatType;
    
    [self.chatRecordListCtl dismissViewControllerAnimated:YES completion:^{
        [self presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:nil];
    }];
}

- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.delegate = self;
    taoziMessageCtl.messageType = IMMessageTypeGuideMessageType;
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
    [SVProgressHUD showSuccessWithStatus:@"已发送"];
    
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
        [self dismissPopupViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self share:nil];
    } else if (buttonIndex == 1) {
        [self showDestination:nil];
    }
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController willHideMenuViewController:(UIViewController *)menuViewController
{
    self.frostedViewController.navigationItem.title = _tripDetail.tripTitle;
}

@end


