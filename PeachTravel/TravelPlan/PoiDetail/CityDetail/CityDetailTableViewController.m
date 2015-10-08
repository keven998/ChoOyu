//
//  CityDetailTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/14/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "CityDetailTableViewController.h"
#import "CityHeaderView.h"
#import "TravelNoteTableViewCell.h"
#import "CityPoi.h"
#import "TravelNote.h"
#import "PoisOfCityViewController.h"
#import "AccountManager.h"
#import "SuperWebViewController.h"
#import "TravelNoteListViewController.h"
#import "TravelNoteDetailViewController.h"
#import "MakePlanViewController.h"
#import "ForeignViewController.h"
#import "DomesticViewController.h"
#import "AddPoiViewController.h"
#import "CityDescDetailViewController.h"
#import "ExpertListViewController.h"
#import "TZFrendListCell.h"
#import "ExpertManager.h"
#import "GuiderProfileViewController.h"
#import "CityDetailLoadMoreCell.h"
#import "TZFrendListCellForArea.h"
#import "CityDetailHeaderView.h"
#import "CallForNewFrandCell.h"
#import "ExpertRequestViewController.h"
#import "TravelPlanListForCityDetailVC.h"
#import "TripDetailRootViewController.h"
#import "TripPlanSettingViewController.h"

#define CITY_DETAIL_LOAD_MORE_CELL @"CITY_DETAIL_LOAD_MORE_CELL"

@interface CityDetailTableViewController () <UITableViewDataSource, UITableViewDelegate,CityDetailHeaderViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CityDetailHeaderView *cityHeaderView;
@property (nonatomic, strong) TZProgressHUD *hud;

@property (nonatomic, strong) UIImageView *cityPicture;
@property (nonatomic, weak) UIButton *footBtn;
@property (nonatomic, weak) UIButton *likeBtn;

@property (nonatomic, strong) NSArray* expertsArray;

@end

@implementation CityDetailTableViewController

static NSString * const reuseIdentifier = @"travelNoteCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIButton *planBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 44)];
    [planBtn setImage:[UIImage imageNamed:@"city_navigationbar_add_default.png"] forState:UIControlStateNormal];
    [planBtn addTarget:self action:@selector(makePlan) forControlEvents:UIControlEventTouchUpInside];
    planBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:planBtn]];
    UIButton *talkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 44)];
    [talkBtn setImage:[UIImage imageNamed:@"navigationbar_chat_default.png"] forState:UIControlStateNormal];
    [talkBtn setImage:[UIImage imageNamed:@"navigationbar_chat_hilighted.png"] forState:UIControlStateHighlighted];
    [talkBtn addTarget:self action:@selector(send2Frend) forControlEvents:UIControlEventTouchUpInside];
    talkBtn.imageEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 2);
    talkBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:talkBtn]];
    self.navigationItem.rightBarButtonItems = barItems;

    [self loadCityData];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setHeaderView {
    _cityHeaderView = [[CityDetailHeaderView alloc] init];
    //        CityDetailHeaderView* header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    _cityHeaderView.cityPoi = (CityPoi *)self.poi;
    _cityHeaderView.delegate = self;
    self.tableView.tableHeaderView = _cityHeaderView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_city_detail"];
      
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_city_detail"];
}

- (void) dealloc {
    _cityHeaderView = nil;
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    _tableView = nil;
}

- (void)updateView
{
    self.navigationItem.title = self.poi.zhName;
    
    
//    [_cityHeaderView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];

    
    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[table]-0-|" options:0 metrics:nil views:@{@"table":self.tableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-64-[table]-46-|" options:0 metrics:nil views:@{@"table":self.tableView}]];
    
    
//    [_cityHeaderView.showSpotsBtn addTarget:self action:@selector(viewSpots:) forControlEvents:UIControlEventTouchUpInside];
//    [_cityHeaderView.showRestaurantsBtn addTarget:self action:@selector(viewRestaurants:) forControlEvents:UIControlEventTouchUpInside];
//    [_cityHeaderView.showShoppingBtn addTarget:self action:@selector(viewShopping:) forControlEvents:UIControlEventTouchUpInside];
//    [_cityHeaderView.showTipsBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showCityDetail:)];
//    
//    [_cityHeaderView.cityDesc addGestureRecognizer:tap];
//    
//    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showCityTravelMonth:)];
//    
//    [_cityHeaderView.travelMonth addGestureRecognizer:tap1];

//    _tableView.tableHeaderView = _cityHeaderView;
//    _tableView.tableFooterView
    [self setUpToolbarView];
}

- (void)restaurantBtnAction{
    [self viewRestaurants:nil];
}
- (void)spotBtnAction{
    [self viewSpots:nil];
}
- (void)guideBtnAction{
    [self play:nil];
}
- (void)shoppingBtnAction{
    [self viewShopping:nil];
}
- (void)planBtnAction{
    TripDetailRootViewController *tripDetailCtl = [[TripDetailRootViewController alloc] init];
    tripDetailCtl.canEdit = NO;;
    tripDetailCtl.cityId = _cityId;
    tripDetailCtl.isCheckPlanFromCityDetail = YES;
    
    TripPlanSettingViewController *tpvc = [[TripPlanSettingViewController alloc] init];
    
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:tripDetailCtl menuViewController:tpvc];
    tpvc.rootViewController = tripDetailCtl;
    frostedViewController.direction = REFrostedViewControllerDirectionRight;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.limitMenuViewSize = YES;
    [self.navigationController pushViewController:frostedViewController animated:YES];

}
- (void)journeyBtnAction{
    [self showMoreTravelNote:nil];
}
- (void)imageListAction{
    
}
- (void)travelMonthAction{
    [self showCityTravelMonth:nil];
}
- (void)descriptionAction{
    [self showCityDetail:nil];
}

- (void)updateTravelNoteTableView
{
//    if (((CityPoi *)self.poi).travelNotes.count > 0) {
    if (self.expertsArray.count > 0) {
        
    
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 104)];
        view.backgroundColor = [UIColor clearColor];
        view.userInteractionEnabled = YES;
        UIButton *footerView = [[UIButton alloc] initWithFrame:CGRectMake(21, -2, CGRectGetWidth(_tableView.frame) - 42, 44)];
        [footerView setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [footerView setBackgroundImage:[ConvertMethods createImageWithColor:COLOR_DISABLE] forState:UIControlStateHighlighted];
        [footerView setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [footerView setTitle:[NSString stringWithFormat:@"~查看更多 · %@达人~",self.poi.zhName] forState:UIControlStateNormal];
//        [footerView setTitle:@"~阅读更多 · 达人游记~" forState:UIControlStateNormal];
        footerView.titleLabel.font = [UIFont systemFontOfSize:12];
        [footerView addTarget:self action:@selector(showMoreTravelNote:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:footerView];
        _tableView.tableFooterView = view;
    }
    [self.tableView reloadData];
}

- (void)setUpToolbarView
{
    UIImageView *toolBarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 46)];
    toolBarView.userInteractionEnabled = YES;
    toolBarView.image = [[UIImage imageNamed:@"ic_city_toolbar_bgk.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.view addSubview:toolBarView];
    UIButton *footBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, toolBarView.bounds.size.width/2, toolBarView.bounds.size.height)];
    self.footBtn = footBtn;
    // 设置cityPoi的选中状态
    CityPoi *poi = (CityPoi *)self.poi;
    footBtn.selected = poi.traveled;
    
    [footBtn setTitle:@"去过" forState:UIControlStateNormal];
    footBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    footBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    footBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    [footBtn addTarget:self action:@selector(footBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [footBtn setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    [footBtn setImage:[UIImage imageNamed:@"ic_city_footter_normal.png"] forState:UIControlStateNormal];
    [footBtn setImage:[UIImage imageNamed:@"ic_city_footter_selected.png"] forState:UIControlStateSelected];
    [toolBarView addSubview:footBtn];
    
    UIButton *likeBtn = [[UIButton alloc] initWithFrame:CGRectMake(toolBarView.bounds.size.width/2, 0, toolBarView.bounds.size.width/2, toolBarView.bounds.size.height)];
    self.likeBtn = likeBtn;
    likeBtn.selected = poi.isVote;
    likeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [likeBtn setTitle:@"喜欢" forState:UIControlStateNormal];
    likeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    likeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    [likeBtn setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    [likeBtn setImage:[UIImage imageNamed:@"ic_city_favorite_normal.png"] forState:UIControlStateNormal];
    [likeBtn setImage:[UIImage imageNamed:@"ic_city_favorite_selected.png"] forState:UIControlStateSelected];
    [likeBtn addTarget:self action:@selector(likeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:likeBtn];
}

#pragma mark - 监听去过和喜欢按钮的点击事件
- (void)likeBtnClick:(UIButton *)likeBtn {
    
    if (likeBtn.selected) {  // 说明是喜欢状态
        // 删除喜欢
        [self sendUnlikeStatusRequest:likeBtn];
    } else {
        // 喜欢
        [self sendLikeStatusRequest:likeBtn];
    }
}

- (void)sendLikeStatusRequest:(UIButton *)likeBtn
{
    // 1.获取请求管理者
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // 2.设置请求参数
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    // 选中则喜欢
    
    NSInteger userId = [AccountManager shareAccountManager].account.userId;
    [params setObject:[NSNumber numberWithInteger:userId] forKey:@"userId"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@/votes",API_GET_CITYDETAIL,self.cityId];
    
    // 3.发送Post请求
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            // 设置likeBtn的选中状态
            likeBtn.selected = !likeBtn.selected;
//            [self loadCityData];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 打印失败信息
        NSLog(@"%@",error);
    }];

}

// 发送不喜欢状态
- (void)sendUnlikeStatusRequest:(UIButton *)likeBtn
{
    // 1.获取请求管理者
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // 2.设置请求参数
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    NSInteger userId = [AccountManager shareAccountManager].account.userId;
    [params setObject:[NSNumber numberWithInteger:userId] forKey:@"userId"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@/votes/%ld",API_GET_CITYDETAIL,self.cityId,userId];
    
    // 3.发送Post请求
    [manager DELETE:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            // 设置likeBtn的选中状态
            likeBtn.selected = !likeBtn.selected;
            //            [self loadCityData];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // 打印失败信息
        NSLog(@"%@",error);
    }];
    
}


- (void)footBtnClick:(UIButton *)footBtn {
    
    AccountManager * manager = [AccountManager shareAccountManager];
    
    NSString *trackStatus = nil;
    if (!footBtn.selected) {
        trackStatus = @"add";
    } else {
        trackStatus = @"del";
    }
    
    // 修改用户足迹
    [manager asyncChangeUserServerTracks:trackStatus withTracks:@[self.cityId] completion:^(BOOL isSuccess, NSString *errorCode) {
        // 修改选中状态
        footBtn.selected = !footBtn.selected;
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[TZFrendListCell class] forCellReuseIdentifier:reuseIdentifier];
        [_tableView registerClass:[CityDetailLoadMoreCell class] forCellReuseIdentifier:CITY_DETAIL_LOAD_MORE_CELL];
        [_tableView registerClass:[CallForNewFrandCell class] forCellReuseIdentifier:@"callforcell"];
        [_tableView registerClass:[CityDetailHeaderView class] forHeaderFooterViewReuseIdentifier:@"header"];

    }
    return _tableView;
}

- (void)headerFrameDidChange:(CityDetailHeaderView*)headerView{
    
    if (headerView.frame.size.height != 520 && headerView.frame.size.width == [UIScreen mainScreen].bounds.size.width && self.tableView.sectionHeaderHeight == 520) {
            NSLog(@"可执行的frame %@",NSStringFromCGRect(headerView.frame));
            self.tableView.tableHeaderView = headerView;
    }
    
}


#pragma mark - 网络请求

- (void)loadCityData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (accountManager.isLogin) {
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    
    NSString *requsetUrl = [NSString stringWithFormat:@"%@%@", API_GET_CITYDETAIL, _cityId];
    _hud = [[TZProgressHUD alloc] init];
    __weak typeof(CityDetailTableViewController *)weakSelf = self;
    [_hud showHUDInViewController:weakSelf content:64];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:kWindowWidth*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    
    //获取城市信息
    [manager GET:requsetUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            self.poi = [[CityPoi alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self updateView];
            [self loadFrendListOfCityData];
//            [self setHeaderView];
        } else {
            if (self.isShowing) {
                [SVProgressHUD showHint:HTTP_FAILED_HINT];
            }
            [_hud hideTZHUD];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if (self.isShowing) {
            [SVProgressHUD showHint:HTTP_FAILED_HINT];
        }
        [_hud hideTZHUD];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

/**
 *  同时加载城市达人信息
 */

- (void)loadFrendListOfCityData
{
    __weak typeof(CityDetailTableViewController *)weakSelf = self;
    [ExpertManager asyncLoadExpertsWithAreaName:self.poi.zhName page:0 pageSize:3 completionBlock:^(BOOL success, NSArray * result) {
        if (success) {
            self.expertsArray = result;

            [weakSelf.tableView reloadData];
            [_hud hideTZHUD];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } else {
            
            [_hud hideTZHUD];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }];
}

/**
 *  当加载完城市详情后开始加载城市的攻略内容
 */
- (void)loadTravelNoteOfCityData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:200];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithInt:3] forKey:@"pageSize"];
    [params setObject:self.poi.poiId forKey:@"locality"];
    [params setObject:[NSNumber numberWithInt:0] forKey:@"page"];
    [manager GET:API_SEARCH_TRAVELNOTE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            id travelNotes = [responseObject objectForKey:@"result"];
            if ([travelNotes isKindOfClass:[NSArray class]]) {
                ((CityPoi *)self.poi).travelNotes = travelNotes;
            }
            [self updateTravelNoteTableView];
        } else {
            
        }
        [_hud hideTZHUD];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [_hud hideTZHUD];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}



/**
 *  实现父类的发送 poi 到消息的值传递
 *
 *  @param taoziMessageCtl
 */
- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.messageId = self.poi.poiId;
    taoziMessageCtl.messageImage = ((TaoziImage *)[self.poi.images firstObject]).imageUrl;
    taoziMessageCtl.messageDesc = self.poi.desc;
    taoziMessageCtl.messageName = self.poi.zhName;
    taoziMessageCtl.messageTimeCost = ((CityPoi *)self.poi).timeCostDesc;
    taoziMessageCtl.descLabel.text = self.poi.desc;
    taoziMessageCtl.messageType = IMMessageTypeCityPoiMessageType;
}

#pragma mark - IBAction Methods

- (IBAction)viewSpots:(id)sender
{
    [MobClick event:@"button_item_city_spots"];

    AddPoiViewController *addCtl = [[AddPoiViewController alloc] init];
    addCtl.cityId = _cityId;
    addCtl.cityName = self.poi.zhName;
    addCtl.shouldEdit = NO;
    addCtl.poiType = kSpotPoi;
    [self.navigationController pushViewController:addCtl animated:YES];
}

/**
 *  游玩攻略
 *
 *  @param sender
 */
- (IBAction)play:(id)sender {
    [MobClick event:@"button_item_city_travel_tips"];
    SuperWebViewController *funOfCityWebCtl = [[SuperWebViewController alloc] init];
    funOfCityWebCtl.urlStr = ((CityPoi *)self.poi).playGuide;
    funOfCityWebCtl.titleStr = @"旅游指南";;
    [self.navigationController pushViewController:funOfCityWebCtl animated:YES];
}

/**
 *  查看城市美食列表
 *
 *  @param sender
 */
- (IBAction)viewRestaurants:(id)sender
{
    [MobClick event:@"button_item_city_delicious"];

    PoisOfCityViewController *restaurantOfCityCtl = [[PoisOfCityViewController alloc] init];
    restaurantOfCityCtl.shouldEdit = NO;
    restaurantOfCityCtl.cityId = self.poi.poiId;
    restaurantOfCityCtl.descDetail = ((CityPoi *)self.poi).diningTitles;
    restaurantOfCityCtl.zhName = self.poi.zhName;
    restaurantOfCityCtl.poiType = kRestaurantPoi;
    [self.navigationController pushViewController:restaurantOfCityCtl animated:YES];
}

/**
 *  城市购物详情
 *
 *  @param sender
 */
- (IBAction)viewShopping:(id)sender
{
    [MobClick event:@"button_item_city_shoppings"];

    PoisOfCityViewController *shoppingOfCityCtl = [[PoisOfCityViewController alloc] init];
    shoppingOfCityCtl.shouldEdit = NO;
    shoppingOfCityCtl.descDetail = ((CityPoi *)self.poi).shoppingTitles;
    shoppingOfCityCtl.cityId = self.poi.poiId;
    shoppingOfCityCtl.zhName = self.poi.zhName;
    shoppingOfCityCtl.poiType = kShoppingPoi;
    
    [self.navigationController pushViewController:shoppingOfCityCtl animated:YES];
}

/**
 *  更多游记
 *
 *  @param sender
 */
- (IBAction)showMoreTravelNote:(id)sender
{
    TravelNoteListViewController *travelListCtl = [[TravelNoteListViewController alloc] init];
    travelListCtl.isSearch = NO;
    travelListCtl.cityId = ((CityPoi *)self.poi).poiId;
    travelListCtl.cityName = ((CityPoi *)self.poi).zhName;
    [self.navigationController pushViewController:travelListCtl animated:YES];
}


- (void)send2Frend
{
    [self shareToTalk];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 44;
    }else if (self.expertsArray.count == 0){
        return [UIScreen mainScreen].bounds.size.width / 1206 * 336 + 14.6;
    }
    
    return 120;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return ((CityPoi *)self.poi).travelNotes.count;
//    return self.expertsArray.count;
    if (self.expertsArray.count == 0) {
        return 2;
    }else if (self.expertsArray.count < 3){
        return self.expertsArray.count + 1;
    }
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        CityDetailLoadMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CITY_DETAIL_LOAD_MORE_CELL forIndexPath:indexPath];

        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    if (self.expertsArray.count > 0) {
        TZFrendListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        ExpertModel* model = self.expertsArray[indexPath.row - 1];
        cell.model = model;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else {
        CallForNewFrandCell* cell = [tableView dequeueReusableCellWithIdentifier:@"callforcell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CityDetailHeaderView* header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    header.cityPoi = (CityPoi *)self.poi;
    return [header headerHeight] + 25;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    _cityHeaderView = [[CityDetailHeaderView alloc] init];
    CityDetailHeaderView* header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    header.cityPoi = (CityPoi *)self.poi;
    header.delegate = self;
    return header;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        ExpertListViewController* frendList = [[ExpertListViewController alloc] initWithCityName:self.poi.zhName orAreaId:nil];
        [self.navigationController pushViewController:frendList animated:YES];
        return;
    }
    if (self.expertsArray.count > 0) {
        GuiderProfileViewController *guiderCtl = [[GuiderProfileViewController alloc] init];
        FrendModel *model = self.expertsArray[indexPath.row-1];
        guiderCtl.userId = model.userId;
        guiderCtl.shouldShowExpertTipsView = YES;
        [self.navigationController pushViewController:guiderCtl animated:YES];
    } else{
        ExpertRequestViewController* expertRequestVC = [[ExpertRequestViewController alloc] init];
        [self.navigationController pushViewController:expertRequestVC animated:YES];
    }
    
    
}

#pragma mark - IBAction

- (void)makePlan
{
    [MobClick event:@"navigation_item_lxp_city_create_plan"];
    Destinations *destinations = [[Destinations alloc] init];
    MakePlanViewController *makePlanCtl = [[MakePlanViewController alloc] init];
    makePlanCtl.destinations = destinations;
    CityDestinationPoi *poi = [[CityDestinationPoi alloc] init];
    poi.zhName = self.poi.zhName;
    poi.cityId = self.poi.poiId;
    [destinations.destinationsSelected addObject:poi];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:makePlanCtl] animated:YES completion:nil];
}

- (void)showCityDetail:(UITapGestureRecognizer *)tap
{
    CityDescDetailViewController *cddVC = [[CityDescDetailViewController alloc]init];
    cddVC.des = self.poi.desc;
    cddVC.title = @"城市简介";
    [self.navigationController pushViewController:cddVC animated:YES];
}

- (void)showCityTravelMonth:(UITapGestureRecognizer *)tap
{
    CityDescDetailViewController *cddVC = [[CityDescDetailViewController alloc]init];
    
    CityPoi * poi = (CityPoi *)self.poi;
    NSLog(@"%@",self.poi.desc);
    cddVC.des = poi.travelMonth;
    cddVC.title = @"最佳季节";
    [self.navigationController pushViewController:cddVC animated:YES];
}


@end






