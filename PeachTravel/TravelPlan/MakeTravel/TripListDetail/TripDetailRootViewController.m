//
//  TripDetailRootViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/24/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "TripDetailRootViewController.h"
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
#import "ForeignViewController.h"
#import "DomesticViewController.h"
#import "PXAlertView+Customization.h"
#import "TripPlanSettingViewController.h"
@interface TripDetailRootViewController () <ActivityDelegate, TaoziMessageSendDelegate, ChatRecordListDelegate, CreateConversationDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) SpotsListViewController *spotsListCtl;
@property (nonatomic, strong) RestaurantsListViewController *restaurantListCtl;
@property (nonatomic, strong) ShoppingListViewController *shoppingListCtl;
@property (nonatomic, strong) ChatRecoredListTableViewController *chatRecordListCtl;

@property (nonatomic, strong) NSArray *tabbarButtonArray;
@property (nonatomic, strong) NSArray *tabbarPageControllerArray;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) UIView *tabBarView;

@property (nonatomic, strong) UINavigationItem *navgationBarItem;

@property (nonatomic) CGPoint initialDraggingPoint;

/**
 *  点击目的地显示目的地界面
 */
@property (nonatomic, strong) UIView *destinationBkgView;
@property (nonatomic, strong) DestinationsView *destinationView;

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

/**
 *  目的地titile 列表，三个界面共享
 */
//@property (strong, nonatomic) DestinationsView *destinationsHeaderView;

@property (strong, nonatomic) UIButton *backButton;


@end

@implementation TripDetailRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewControllers];
    [self setNavigationItems];
    
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
    [MobClick beginLogPageView:@"page_plan_detail"];
    _isShowing = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_plan_detail"];
    _isShowing = NO;
}

- (void)setNavigationItems
{
    UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    UINavigationItem *navTitle = [[UINavigationItem alloc] init];
    [bar pushNavigationItem:navTitle animated:YES];
    [self.view addSubview:bar];
    _navgationBarItem = navTitle;

    if (_canEdit) {
        [self setupNavigationRightItems:NO];
        
    } else {
        _forkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
        _forkBtn.layer.cornerRadius = 2.0;
        _forkBtn.layer.borderColor = APP_THEME_COLOR.CGColor;
        _forkBtn.layer.borderWidth = 1.0;
        [_forkBtn setTitle:@"复制计划" forState:UIControlStateNormal];
        _forkBtn.titleLabel.font = [UIFont systemFontOfSize:10.0];
        [_forkBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [_forkBtn setTitleColor:[APP_THEME_COLOR colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [_forkBtn addTarget:self action:@selector(forkTrip:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *bbtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [bbtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [bbtn setImage:[UIImage imageNamed:@"ic_navigation_back.png"] forState:UIControlStateNormal];
        [bbtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        _navgationBarItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bbtn];
        UIBarButtonItem * addBtn = [[UIBarButtonItem alloc]initWithCustomView:_forkBtn];
        _navgationBarItem.rightBarButtonItem = addBtn;
    }
}

- (void) setupNavigationRightItems:(BOOL)isEditing {
    
    _navgationBarItem.rightBarButtonItems = nil;
    if (isEditing) {
        _editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        [_editBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_editBtn setTitle:@"确定" forState:UIControlStateNormal];
//        [_editBtn setImage:[UIImage imageNamed:@"ic_xingchengdan_queding"] forState:UIControlStateNormal];
        [_editBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [_editBtn addTarget:self action:@selector(editTrip:) forControlEvents:UIControlEventTouchUpInside];
        _editBtn.selected = YES;
        _navgationBarItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_editBtn];
        _navgationBarItem.leftBarButtonItems = nil;

    } else {
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        _moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [_moreBtn setImage:[UIImage imageNamed:@"ic_menu_navigationbar.png"] forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(showMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:_moreBtn]];
        
        if ([_currentViewController isKindOfClass:[SpotsListViewController class]]) {
            UIButton *mapBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 44)];
            [mapBtn setImage:[UIImage imageNamed:@"ic_trip_mapview_ios"] forState:UIControlStateNormal];
            [mapBtn addTarget:self action:@selector(mapView) forControlEvents:UIControlEventTouchUpInside];
            [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:mapBtn]];
        }
        
        _editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 44)];
        [_editBtn setImage:[UIImage imageNamed:@"ic_trip_edit.png"] forState:UIControlStateNormal];
        [_editBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_editBtn addTarget:self action:@selector(editTrip:) forControlEvents:UIControlEventTouchUpInside];
        [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:_editBtn]];
        
        _navgationBarItem.rightBarButtonItems = barItems;
        
        UIButton *bbtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [bbtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [bbtn setImage:[UIImage imageNamed:@"ic_navigation_back.png"] forState:UIControlStateNormal];
        [bbtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        _navgationBarItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bbtn];
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
    _restaurantListCtl = nil;
    _shoppingListCtl = nil;
    _chatRecordListCtl = nil;
}

- (void)pan:(UIPanGestureRecognizer *)reconizer
{
    if (reconizer.state == UIGestureRecognizerStateBegan) {
        _initialDraggingPoint = [reconizer translationInView:self.view];
    } else if (reconizer.state == UIGestureRecognizerStateEnded || reconizer.state == UIGestureRecognizerStateCancelled) {
        CGPoint lastPoint = [reconizer translationInView:self.view];
        if ((lastPoint.x - _initialDraggingPoint.x) > 100) {
            if ([_currentViewController isEqual:[_tabbarPageControllerArray firstObject]]) {
                UIButton *btn = [_tabbarButtonArray lastObject];
                [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
            } else {
                NSInteger index = [_tabbarPageControllerArray indexOfObject:_currentViewController];
                UIButton *btn = [_tabbarButtonArray objectAtIndex:index-1];
                [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            
        } else if ((lastPoint.x - _initialDraggingPoint.x) < -100) {
            if ([_currentViewController isEqual:[_tabbarPageControllerArray lastObject]]) {
                UIButton *btn = [_tabbarButtonArray firstObject];
                [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
            } else {
                NSInteger index = [_tabbarPageControllerArray indexOfObject:_currentViewController];
                UIButton *btn = [_tabbarButtonArray objectAtIndex:index+1];
                [btn sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

#pragma mark - IBAction

- (IBAction)finishEidtTrip:(id)sender
{
    [MobClick event:@"event_edit_done"];
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
            if ([_currentViewController isKindOfClass:[SpotsListViewController class]]) {
                _spotsListCtl.shouldEdit = NO;
            } else if ([_currentViewController isKindOfClass:[ShoppingListViewController class]]) {
                _shoppingListCtl.shouldEdit = NO;
            } else if ([_currentViewController isKindOfClass:[RestaurantsListViewController class]]) {
                _restaurantListCtl.shouldEdit = NO;
            }
            _editBtn.selected = !_editBtn.selected;
        } else {
            [SVProgressHUD showErrorWithStatus:@"保存失败了"];
        }
    }];
}

- (void)mapView {
    if ([_currentViewController isKindOfClass:[SpotsListViewController class]]) {
        [_spotsListCtl mapView];
    } else if ([_currentViewController isKindOfClass:[ShoppingListViewController class]]) {
        [_shoppingListCtl mapView];
    } else if ([_currentViewController isKindOfClass:[RestaurantsListViewController class]]) {
        [_restaurantListCtl mapView];
    }
}

/**
 *  不同情况的确定按钮相应的操作不一致
 */
- (void)goBack
{
    if ([_tripDetail tripIsChange]) {
        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否保存已修改内容" delegate:self cancelButtonTitle:@"直接返回" otherButtonTitles:@"保存", nil];
        [alterView showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self dismissCtl];
            } else if (buttonIndex == 1) {
                TZProgressHUD *hud = [[TZProgressHUD alloc] init];
                [hud showHUD];
                [_tripDetail saveTrip:^(BOOL isSuccesss) {
                    [hud hideTZHUD];
                    if (isSuccesss) {
                        [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
                        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                        [center postNotificationName:updateGuideListNoti object:nil];
                    } else {
                        [SVProgressHUD showHint:@"保存失败了～"];
                    }
                }];
            }
        }];
    } else {
        [self dismissCtl];
    }
}

- (void)dismissCtl
{
    if (self.navigationController.childViewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
    NSNumber *imageWidth = [NSNumber numberWithInt:150];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:updateGuideListNoti object:nil];
            if (isNeedRecommend) {
//                [SVProgressHUD showHint:[NSString stringWithFormat:@"已为你创建%lu行程", (unsigned long)_tripDetail.itineraryList.count]];
                [self performSelector:@selector(hintBuildRoutes) withObject:nil afterDelay:0.25];
            }
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

- (void)hintBuildRoutes {
    PXAlertView *alertView = [PXAlertView showAlertWithTitle:@"提示"
                            message:[NSString stringWithFormat:@"根据网友们经验为你推荐了%lu天旅程，可自由调整", (unsigned long)_tripDetail.itineraryList.count]
                        cancelTitle:@"确定"
                         completion:nil];
    [alertView useDefaultIOS7Style];
    [alertView setTitleFont:[UIFont systemFontOfSize:17]];
    [alertView setMessageColor:TEXT_COLOR_TITLE_SUBTITLE];
}

- (void)setCanEdit:(BOOL)canEdit
{
    _canEdit = canEdit;
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
 *  点击我的目的地进入城市详情
 *
 *  @param sender
 */
- (void)viewCityDetail:(NSString *)cityId
{
    [MobClick event:@"event_go_city_detail"];
    CityDetailTableViewController *cityDetailCtl = [[CityDetailTableViewController alloc] init];
    cityDetailCtl.cityId = cityId;
    [self.navigationController pushViewController:cityDetailCtl animated:YES];
}

/**
 *  点击分享按钮
 *
 *  @param sender
 */
- (IBAction)share:(id)sender
{
    [MobClick event:@"event_share_plan_detail"];
    NSArray *shareButtonimageArray = @[@"ic_sns_talk.png", @"ic_sns_pengyouquan.png",  @"ic_sns_weixin.png", @"ic_sns_qq.png", @"ic_sns_qzone.png", @"ic_sns_sina.png", @"ic_sns_douban.png"];
    NSArray *shareButtonTitleArray = @[@"Talk", @"朋友圈", @"微信好友", @"QQ", @"QQ空间", @"新浪微博", @"豆瓣"];
    ShareActivity *shareActivity = [[ShareActivity alloc] initWithTitle:@"转发至" delegate:self cancelButtonTitle:@"取消" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonimageArray];
    [shareActivity showInView:self.view];
}

/**
 *  点击navigationbar上的更多按钮
 *  @param sender
 */
- (IBAction)showMoreAction:(id)sender
{
    if (!_tripDetail) {
//        [SVProgressHUD showHint:@"呃～好像没找到网络"];
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
    
    [self.navigationController.view addSubview:_destinationBkgView];
    
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
    [MobClick event:@"event_edit_plan"];
    if (!_tripDetail) {
        return;
    }
    BOOL status = sender.selected;
    if (!status) {
        if ([_currentViewController isKindOfClass:[SpotsListViewController class]]) {
            _spotsListCtl.shouldEdit = YES;
        } else if ([_currentViewController isKindOfClass:[ShoppingListViewController class]]) {
            _shoppingListCtl.shouldEdit = YES;
        } else if ([_currentViewController isKindOfClass:[RestaurantsListViewController class]]) {
            _restaurantListCtl.shouldEdit = YES;
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
    NSNumber *imageWidth = [NSNumber numberWithInt:150];
    [params setObject:imageWidth forKey:@"imgWidth"];
    
    [manager GET:urlStr parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            _tripDetail.tripId = [[responseObject objectForKey:@"result"] objectForKey:@"id"];
            self.canEdit = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:updateGuideListNoti object:nil];
            [SVProgressHUD showHint:@"已保存到我的旅行计划"];
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
    _spotsListCtl.canEdit = _canEdit;
    _restaurantListCtl.canEdit = _canEdit;
    _shoppingListCtl.canEdit = _canEdit;
    ((TripPlanSettingViewController *)self.container.menuViewController).tripDetail = self.tripDetail;
    
}

- (void)setupViewControllers
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    _spotsListCtl = [[SpotsListViewController alloc] init];
    _spotsListCtl.rootViewController = self;
    
    _restaurantListCtl = [[RestaurantsListViewController alloc] init];
    _restaurantListCtl.rootViewController = self;
    
    _shoppingListCtl = [[ShoppingListViewController alloc] init];
    _shoppingListCtl.rootViewController = self;
    
    [self addChildViewController:_spotsListCtl];
    [self.view addSubview:_spotsListCtl.view];
    
    
    [_spotsListCtl.view setFrame:CGRectMake(0, 65, self.view.bounds.size.width, self.view.bounds.size.height - 65)];
    [_restaurantListCtl.view setFrame:CGRectMake(0, 65, self.view.bounds.size.width, self.view.bounds.size.height - 65)];
    [_shoppingListCtl.view setFrame:CGRectMake(0, 65, self.view.bounds.size.width, self.view.bounds.size.height - 65)];
    
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
    _tabBarView = [[UIView alloc] initWithFrame:CGRectMake(19, self.view.frame.size.height-49-5, self.view.frame.size.width-38, 49)];
    _tabBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _tabBarView.backgroundColor = APP_PAGE_COLOR;
    _tabBarView.alpha = 0.9;
    CALayer *layer = _tabBarView.layer;
    layer.borderWidth = 1;
    layer.borderColor = APP_BORDER_COLOR.CGColor;
    layer.shadowColor = APP_BORDER_COLOR.CGColor;
    layer.shadowOffset = CGSizeMake(0, -0.5);
    layer.shadowRadius = 0.5;
    layer.shadowOpacity = 1.0;
    layer.cornerRadius = 1;
//    UIView *divide = [[UIView alloc]initWithFrame:CGRectMake(0.5, 0, _tabBarView.frame.size.width - 1, 1)];
//    divide.backgroundColor = APP_PAGE_COLOR;
//    [_tabBarView addSubview:divide];
//    _tabBarView.layer.cornerRadius = 3;
//    _tabBarView.layer.shadowColor = APP_DIVIDER_COLOR.CGColor;
//    _tabBarView.layer.shadowColor = APP_THEME_COLOR.CGColor;
//    _tabBarView.layer.shadowOffset = CGSizeMake(0, 0);
//    _tabBarView.layer.shadowOpacity = 0;
//    _tabBarView.layer.shadowRadius = 4;
//    _tabBarView.clipsToBounds = YES;
    [self.view addSubview:_tabBarView];
    
    NSArray *tabBarItemTitles = @[@"行程计划", @"美食计划", @"购物计划"];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    CGFloat width = _tabBarView.frame.size.width;
    
    for (int i = 0; i < 3; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(width/3*i, 0, width/3, 50)];
        [button setTitle:tabBarItemTitles[i] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        
        [button setTitleEdgeInsets:UIEdgeInsetsMake(28, 0, 0, 0)];
        [array addObject:button];
        [button setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
        [_tabBarView addSubview:button];
        button.tag = i;
        button.titleLabel.font = [UIFont systemFontOfSize:9.0];
        [button addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *showBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        showBtn.userInteractionEnabled = NO;
//        showBtn.backgroundColor = UIColorFromRGB(0xd74353);
//        showBtn.layer.cornerRadius = 15.0;
        NSString *imageName = [NSString stringWithFormat: @"ic_trip_new_%d",i+1];
        [showBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        showBtn.center = CGPointMake(button.bounds.size.width/2, button.bounds.size.height/2-6);
        [button addSubview:showBtn];
    }
    
    UIView *divider1 = [[UIView alloc]initWithFrame:CGRectMake(width/3.0-0.5, 7, 1, 35)];
    divider1.backgroundColor = APP_DIVIDER_COLOR;
    [_tabBarView addSubview:divider1];
    
    UIView *divider2 = [[UIView alloc]initWithFrame:CGRectMake(width*2.0/3.0-0.5, 7, 1, 35)];
    divider2.backgroundColor = APP_DIVIDER_COLOR;
    [_tabBarView addSubview:divider2];
//    [_tabBarView addSubview:_tabBarSelectedView];
    _tabbarButtonArray = array;
}

- (void)changePage:(UIButton *)sender
{
    UIViewController *newController = [_tabbarPageControllerArray objectAtIndex:sender.tag];
    
    if ([newController isEqual:_currentViewController]) {
        return;
    }
//    NSString *imageName = [NSString stringWithFormat: @"ic_trip_selected_%ld",(long)sender.tag+1];
//    [_tabBarSelectedView setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [self replaceController:_currentViewController newController:newController];
}

- (void)replaceController:(UIViewController *)oldController newController:(UIViewController *)newController
{
    [self addChildViewController:newController];
    [self transitionFromViewController:oldController toViewController:newController duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:nil completion:^(BOOL finished) {
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
        } else {
            self.currentViewController = oldController;
        }
        [self setNavigationItems];
    }];
    [self.view bringSubviewToFront:_tabBarView];
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
    [self.navigationController pushViewController:cityDetailCtl animated:YES];
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
        [self presentPopupViewController:taoziMessageCtl atHeight:170.0 animated:YES completion:nil];
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

@end


