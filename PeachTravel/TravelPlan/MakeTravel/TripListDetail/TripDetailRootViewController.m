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

@interface TripDetailRootViewController () <ActivityDelegate, TaoziMessageSendDelegate, ChatRecordListDelegate, CreateConversationDelegate, UIActionSheetDelegate, DestinationsViewDelegate, UpdateDestinationsDelegate>

@property (nonatomic, strong) SpotsListViewController *spotsListCtl;
@property (nonatomic, strong) RestaurantsListViewController *restaurantListCtl;
@property (nonatomic, strong) ShoppingListViewController *shoppingListCtl;
@property (nonatomic, strong) ChatRecoredListTableViewController *chatRecordListCtl;

@property (nonatomic, strong) NSArray *tabbarButtonArray;
@property (nonatomic, strong) NSArray *tabbarPageControllerArray;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, strong) UIView *tabBarView;

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
    self.automaticallyAdjustsScrollViewInsets = NO;
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setImage:[UIImage imageNamed:@"ic_navigation_back.png"] forState:UIControlStateNormal];
    [_backButton setImage:nil forState:UIControlStateSelected];
    [_backButton setTitle:nil forState:UIControlStateNormal];
    [_backButton setTitle:@"取消" forState:UIControlStateSelected];
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
   
    [self setNavigationItems];
    
    [self setupViewControllers];
    if (_isMakeNewTrip) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否需要为你创建行程模版" delegate:self cancelButtonTitle:@"不需要" otherButtonTitles:@"需要", nil];
        [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self loadNewTripDataWithRecommendData:NO];
                [MobClick event:@"event_unuse_template"];
            }
            
            if (buttonIndex == 1) {
                [self loadNewTripDataWithRecommendData:YES];
                [MobClick event:@"event_use_template"];
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
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self.view addGestureRecognizer:panGesture];

    
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
    if (_canEdit) {
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        
        _editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 44)];
        [_editBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_editBtn setImage:[UIImage imageNamed:@"ic_trip_edit.png"] forState:UIControlStateNormal];
        [_editBtn setImage:[UIImage imageNamed:@"ic_trip_edit_done.png"] forState:UIControlStateSelected];

        [_editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_editBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        [_editBtn addTarget:self action:@selector(editTrip:) forControlEvents:UIControlEventTouchUpInside];
        [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:_editBtn]];
        
        _moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 44)];
        [_moreBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [_moreBtn setImage:[UIImage imageNamed:@"ic_more.png"] forState:UIControlStateNormal];
        _moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_moreBtn addTarget:self action:@selector(showMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:_moreBtn]];
        
        self.navigationItem.rightBarButtonItems = barItems;
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
        UIBarButtonItem * addBtn = [[UIBarButtonItem alloc]initWithCustomView:_forkBtn];
        self.navigationItem.rightBarButtonItem = addBtn;
    }

}
- (void) hint {
    [SVProgressHUD showHint:@"已保存到我的旅程，可自由定制"];
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
            _spotsListCtl.shouldEdit = NO;
            _restaurantListCtl.shouldEdit = NO;
            _shoppingListCtl.shouldEdit = NO;
            _editBtn.selected = !_editBtn.selected;

        } else {
            [SVProgressHUD showErrorWithStatus:@"保存失败了"];
        }
    }];
}

/**
 *  不同情况的返回按钮相应的操作不一致
 */
- (void)goBack
{
    if ([_tripDetail tripIsChange]) {
        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"攻略已编辑，是否保存" message:nil delegate:self cancelButtonTitle:@"直接返回" otherButtonTitles:@"保存", nil];
        [alterView showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            if (buttonIndex == 1) {
                TZProgressHUD *hud = [[TZProgressHUD alloc] init];
                [hud showHUD];
                [_tripDetail saveTrip:^(BOOL isSuccesss) {
                    [hud hideTZHUD];
                    if (isSuccesss) {
                        [SVProgressHUD showHint:@"保存成功"];
                        [self performSelector:@selector(dismissCtl) withObject:nil afterDelay:0.3];
                    } else {
                        [SVProgressHUD showHint:@"保存失败了～"];
                    }
                }];
            }
        }];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:updateGuideListNoti object:nil];
            if (isNeedRecommend) {
                [SVProgressHUD showHint:[NSString stringWithFormat:@"已为你创建%lu行程", (unsigned long)_tripDetail.itineraryList.count]];
            } else {
                [self performSelector:@selector(hint) withObject:nil afterDelay:1.0];
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

- (void)setCanEdit:(BOOL)canEdit
{
    _canEdit = canEdit;
    _spotsListCtl.canEdit = _canEdit;
    _restaurantListCtl.canEdit = _canEdit;
    _shoppingListCtl.canEdit = _canEdit;
    [self setNavigationItems];
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
    ShareActivity *shareActivity = [[ShareActivity alloc] initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"取消" ShareButtonTitles:shareButtonTitleArray withShareButtonImagesName:shareButtonimageArray];
    [shareActivity showInView:self.view];
}

/**
 *  点击navigationbar上的更多按钮
 *
 *  @param sender
 */
- (IBAction)showMoreAction:(id)sender
{
    if (!_tripDetail) {
        [SVProgressHUD showHint:@"呃～好像没找到网络"];
        return;
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享", @"目的地", nil];
    [sheet showInView:self.view];
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
    
    _destinationView = [[DestinationsView alloc] initWithFrame:CGRectMake(8, 50, kWindowWidth-16, 249)];
    _destinationView.isCanAddDestination = YES;
    _destinationView.delegate = self;
    _destinationView.titleColor = APP_THEME_COLOR;
    _destinationView.destinations = array;
    [panelView addSubview:_destinationView];
    
    [_destinationBkgView addSubview:panelView];
    
    [self.navigationController.view addSubview:_destinationBkgView];

    [UIView animateWithDuration:0.2 animations:^{
        panelView.frame = CGRectMake(0, _destinationBkgView.bounds.size.height-340, _destinationBkgView.bounds.size.width, 340);
    } completion:^(BOOL finished) {
        
    }];
    
    for (UIView *view in _destinationBkgView.subviews) {
        NSLog(@"%@", view);
    }
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
        [SVProgressHUD showHint:@"呃～好像没找到网络"];
        return;
    }
    BOOL status = sender.selected;
    if (!status) {
        _spotsListCtl.shouldEdit = YES;
        _restaurantListCtl.shouldEdit = YES;
        _shoppingListCtl.shouldEdit = YES;
        sender.selected = !status;
    } else {
        [self finishEidtTrip:nil];
    }
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
            [[NSNotificationCenter defaultCenter] postNotificationName:updateGuideListNoti object:nil];
            [SVProgressHUD showHint:@"已保存到我的旅程"];
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
    if (_isMakeNewTrip) {
        [_editBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    _spotsListCtl.tripDetail = _tripDetail;
    _restaurantListCtl.tripDetail = _tripDetail;
    _shoppingListCtl.tripDetail = _tripDetail;
    _spotsListCtl.canEdit = _canEdit;
    _restaurantListCtl.canEdit = _canEdit;
    _shoppingListCtl.canEdit = _canEdit;
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
    
    _tabBarSelectedView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    _tabBarSelectedView.backgroundColor = APP_SUB_THEME_COLOR;
    _tabBarSelectedView.layer.cornerRadius = 15.0;
    [_tabBarSelectedView setImage:[UIImage imageNamed:@"ic_trip_selected_1.png"] forState:UIControlStateNormal];
    
    [self.view addSubview:_tabBarView];

    NSArray *tabBarItemTitles = @[@"旅程", @"美食收集", @"逛收集"];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    CGFloat width = _tabBarView.frame.size.width;

    NSInteger index = 0;
    for (int i=0; i<3; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((25+(width-50)/3*i), 0, (width-50)/3, 54)];
        [button setTitle:tabBarItemTitles[i] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(36, 0, 0, 0)];
        [array addObject:button];
        [_tabBarView addSubview:button];
        button.tag = i;
        button.titleLabel.font = [UIFont systemFontOfSize:9.0];
        [button addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *showBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        showBtn.userInteractionEnabled = NO;
        showBtn.backgroundColor = UIColorFromRGB(0xd74353);
        showBtn.layer.cornerRadius = 15.0;
        NSString *imageName = [NSString stringWithFormat: @"ic_trip_normal_%d",i+1];
        [showBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        showBtn.center = CGPointMake(button.bounds.size.width/2, button.bounds.size.height/2-6);
        [button addSubview:showBtn];
        
        
        if (i == 0) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(button.frame.size.width/2+7, button.frame.size.height/2-9, button.frame.size.width/2, 7)];
            lineView.backgroundColor = UIColorFromRGB(0xd74353);
            [button addSubview:lineView];
            lineView.userInteractionEnabled = NO;
            _tabBarSelectedView.center = button.center;
            [_tabBarSelectedView setCenter:CGPointMake(button.center.x, button.center.y-7)];
        }
        if (i == 1) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(button.frame.size.width/2+14, button.frame.size.height/2-9, button.frame.size.width/2-7, 7)];
            lineView.backgroundColor = UIColorFromRGB(0xd74353);
            lineView.userInteractionEnabled = NO;
            [button addSubview:lineView];
            UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height/2-9, button.frame.size.width/2-14, 7)];
            lineView2.backgroundColor = UIColorFromRGB(0xd74353);
            lineView2.userInteractionEnabled = NO;
            [button addSubview:lineView2];
        }
        if (i == 2) {
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, button.frame.size.height/2-9, button.frame.size.width/2-14, 7)];
            lineView.backgroundColor = UIColorFromRGB(0xd74353);
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
        [_tabBarSelectedView setCenter:CGPointMake(sender.center.x, sender.center.y-7)];
    }];
    
    if ([newController isEqual:_currentViewController]) {
        return;
    }
    NSString *imageName = [NSString stringWithFormat: @"ic_trip_selected_%ld",(long)sender.tag+1];
    [_tabBarSelectedView setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
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
        }else{
            self.currentViewController = oldController;
        }
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
            UINavigationController *nCtl = [[UINavigationController alloc] initWithRootViewController:_chatRecordListCtl];
            [nCtl.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bkg.png"] forBarMetrics:UIBarMetricsDefault];
            nCtl.navigationBar.translucent = YES;
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

- (void)willAddDestination
{
    [MobClick event:@"event_rechoose_destination"];
    [self hideDestinationView:nil];
    Destinations *destinations = [[Destinations alloc] init];
    MakePlanViewController *makePlanCtl = [[MakePlanViewController alloc] init];
    ForeignViewController *foreignCtl = [[ForeignViewController alloc] init];
    DomesticViewController *domestic = [[DomesticViewController alloc] init];
    for (CityDestinationPoi *poi in _tripDetail.destinations) {
        [destinations.destinationsSelected addObject:poi];
    }
    domestic.destinations = destinations;
    foreignCtl.destinations = destinations;
    makePlanCtl.destinations = destinations;
    makePlanCtl.viewControllers = @[domestic, foreignCtl];
    domestic.makePlanCtl = makePlanCtl;
    foreignCtl.makePlanCtl = makePlanCtl;
    makePlanCtl.animationOptions = UIViewAnimationOptionTransitionNone;
    makePlanCtl.duration = 0;
    makePlanCtl.segmentedTitles = @[@"国内", @"国外"];
    makePlanCtl.selectedColor = APP_THEME_COLOR;
    makePlanCtl.segmentedTitleFont = [UIFont systemFontOfSize:18.0];
    makePlanCtl.normalColor= [UIColor grayColor];
    makePlanCtl.shouldOnlyChangeDestinationWhenClickNextStep = YES;
    makePlanCtl.myDelegate = self;
    [self.navigationController pushViewController:makePlanCtl animated:YES];
}

#pragma mark - UpdateDestinationsDelegate

- (void)updateDestinations:(NSArray *)destinations
{
    [self showDestination:nil];
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    typeof(self) weakSelf = self;
    [hud showHUDInViewController:weakSelf.navigationController];
    [self.tripDetail updateTripDestinations:^(BOOL isSuccesss) {
        [hud hideTZHUD];
        if (isSuccesss) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (CityDestinationPoi *poi in _tripDetail.destinations) {
                [array addObject:poi.zhName];
            }
            _destinationView.destinations = array;
        } else {
            
        }
    } withDestinations:destinations];
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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self share:nil];
    }
    if (buttonIndex == 1) {
        [self showDestination:nil];
    }
}

@end


