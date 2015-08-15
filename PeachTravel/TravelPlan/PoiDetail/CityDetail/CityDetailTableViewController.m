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

@interface CityDetailTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CityHeaderView *cityHeaderView;
@property (nonatomic, strong) TZProgressHUD *hud;

@property (nonatomic, strong) UIImageView *cityPicture;

@end

@implementation CityDetailTableViewController

static NSString * const reuseIdentifier = @"travelNoteCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIButton *planBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 44)];
    [planBtn setImage:[UIImage imageNamed:@"city_navigationbar_add_default.png"] forState:UIControlStateNormal];
    [planBtn setImage:[UIImage imageNamed:@"city_navigationbar_add_hilighted.png"] forState:UIControlStateHighlighted];
    [planBtn addTarget:self action:@selector(makePlan) forControlEvents:UIControlEventTouchUpInside];
    planBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:planBtn]];
    UIButton *talkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 44)];
    [talkBtn setImage:[UIImage imageNamed:@"navigationbar_chat_default.png"] forState:UIControlStateNormal];
    [talkBtn setImage:[UIImage imageNamed:@"navigationbar_chat_hilighted.png"] forState:UIControlStateHighlighted];
    [talkBtn addTarget:self action:@selector(send2Frend) forControlEvents:UIControlEventTouchUpInside];
    talkBtn.imageEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 2);
    talkBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:talkBtn]];
    self.navigationItem.rightBarButtonItems = barItems;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TravelNoteTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self loadCityData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_city_detail"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    
    _cityHeaderView = [[CityHeaderView alloc] init];
    [_cityHeaderView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    _cityHeaderView.cityPoi = (CityPoi *)self.poi;
    
    [self.view addSubview:self.tableView];
    
    [_cityHeaderView.showSpotsBtn addTarget:self action:@selector(viewSpots:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showRestaurantsBtn addTarget:self action:@selector(viewRestaurants:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showShoppingBtn addTarget:self action:@selector(viewShopping:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showTipsBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showCityDetail:)];
    
    [_cityHeaderView.cityDesc addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showCityTravelMonth:)];
    
    [_cityHeaderView.travelMonth addGestureRecognizer:tap1];

    _tableView.tableHeaderView = _cityHeaderView;
    [self setUpToolbarView];
}

- (void)updateTravelNoteTableView
{
    if (((CityPoi *)self.poi).travelNotes.count > 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 104)];
        view.backgroundColor = [UIColor clearColor];
        view.userInteractionEnabled = YES;
        UIButton *footerView = [[UIButton alloc] initWithFrame:CGRectMake(21, -2, CGRectGetWidth(_tableView.frame) - 42, 44)];
        [footerView setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [footerView setBackgroundImage:[ConvertMethods createImageWithColor:COLOR_DISABLE] forState:UIControlStateHighlighted];
        [footerView setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [footerView setTitle:@"~阅读更多 · 达人游记~" forState:UIControlStateNormal];
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
    [footBtn setTitle:@"去过" forState:UIControlStateNormal];
    footBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    footBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    footBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    [footBtn setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    [footBtn setImage:[UIImage imageNamed:@"ic_city_footter_normal.png"] forState:UIControlStateNormal];
    [footBtn setImage:[UIImage imageNamed:@"ic_city_footter_selected.png"] forState:UIControlStateSelected];
    [toolBarView addSubview:footBtn];
    
    UIButton *likeBtn = [[UIButton alloc] initWithFrame:CGRectMake(toolBarView.bounds.size.width/2, 0, toolBarView.bounds.size.width/2, toolBarView.bounds.size.height)];
    likeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [likeBtn setTitle:@"喜欢" forState:UIControlStateNormal];
    likeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    likeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    [likeBtn setTitleColor:COLOR_TEXT_I forState:UIControlStateNormal];
    [likeBtn setImage:[UIImage imageNamed:@"ic_city_favorite_normal.png"] forState:UIControlStateNormal];
    [likeBtn setImage:[UIImage imageNamed:@"ic_city_favorite_selected.png"] forState:UIControlStateSelected];
    [toolBarView addSubview:likeBtn];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64)];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

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
        
//        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            self.poi = [[CityPoi alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self updateView];
            [self loadTravelNoteOfCityData];
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
    return 126;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((CityPoi *)self.poi).travelNotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TravelNoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    TravelNote *travelNote = [((CityPoi *)self.poi).travelNotes objectAtIndex:indexPath.row];
    cell.travelNoteImage = travelNote.authorAvatar;
    cell.title = travelNote.title;
    cell.desc = travelNote.summary;
    
    cell.property = [NSString stringWithFormat:@"%@    %@", travelNote.authorName, travelNote.publishDateStr];
    cell.canSelect = NO;
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TravelNote *travelNote = [((CityPoi *)self.poi).travelNotes objectAtIndex:indexPath.row];
    TravelNoteDetailViewController *travelNoteCtl = [[TravelNoteDetailViewController alloc] init];
    travelNoteCtl.titleStr = travelNote.title;
    travelNoteCtl.travelNote = travelNote;
    [self.navigationController pushViewController:travelNoteCtl animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - IBAction

- (void)makePlan {
    [MobClick event:@"navigation_item_lxp_city_create_plan"];
    Destinations *destinations = [[Destinations alloc] init];
    MakePlanViewController *makePlanCtl = [[MakePlanViewController alloc] init];
    ForeignViewController *foreignCtl = [[ForeignViewController alloc] init];
    DomesticViewController *domestic = [[DomesticViewController alloc] init];
    
    CityDestinationPoi *poi = [[CityDestinationPoi alloc] init];
    poi.zhName = self.poi.zhName;
    poi.cityId = self.poi.poiId;
    [destinations.destinationsSelected addObject:poi];
    
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






