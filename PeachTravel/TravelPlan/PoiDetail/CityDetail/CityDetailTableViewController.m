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

@interface CityDetailTableViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

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
    UIButton *planBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 44)];
    [planBtn setImage:[UIImage imageNamed:@"ic_add_city.png"] forState:UIControlStateNormal];
    planBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [planBtn addTarget:self action:@selector(makePlan) forControlEvents:UIControlEventTouchUpInside];
    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:planBtn]];
    UIButton *talkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 44)];
    [talkBtn setImage:[UIImage imageNamed:@"ic_ztl_lt"] forState:UIControlStateNormal];
    [talkBtn addTarget:self action:@selector(shareToTalk) forControlEvents:UIControlEventTouchUpInside];
    talkBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:talkBtn]];
    self.navigationItem.rightBarButtonItems = barItems;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TravelNoteTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self loadCityData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    
    _cityHeaderView = [[CityHeaderView alloc] init];
    [_cityHeaderView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    _cityHeaderView.cityPoi = (CityPoi *)self.poi;
    
    [self.view addSubview:self.tableView];
    
    [_cityHeaderView.showSpotsBtn addTarget:self action:@selector(viewSpots:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showRestaurantsBtn addTarget:self action:@selector(viewRestaurants:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showShoppingBtn addTarget:self action:@selector(viewShopping:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showTipsBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealtap:)];
    
    [_cityHeaderView.cityDesc addGestureRecognizer:tap];
    _tableView.tableHeaderView = _cityHeaderView;
    
   }

- (void)updateTravelNoteTableView
{
    if (((CityPoi *)self.poi).travelNotes.count > 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 64)];
        view.backgroundColor = [UIColor clearColor];
        view.userInteractionEnabled = YES;
        UIButton *footerView = [[UIButton alloc] initWithFrame:CGRectMake(21, 0, CGRectGetWidth(_tableView.frame) - 42, 44)];
        [footerView setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [footerView setBackgroundImage:[ConvertMethods createImageWithColor:COLOR_DISABLE] forState:UIControlStateHighlighted];
        [footerView setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateNormal];
        [footerView setTitle:@"~阅读更多 · 达人游记~" forState:UIControlStateNormal];
        footerView.titleLabel.font = [UIFont systemFontOfSize:12];
        [footerView addTarget:self action:@selector(showMoreTravelNote:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:footerView];
        _tableView.tableFooterView = view;
    }
    [self.tableView reloadData];

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
                [SVProgressHUD showHint:@"呃～好像没找到网络"];
            }
            [_hud hideTZHUD];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
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
    [params setObject:self.poi.poiId forKey:@"locId"];
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
    [MobClick event:@"event_city_spots"];
    AddPoiViewController *addCtl = [[AddPoiViewController alloc] init];
    addCtl.cityId = _cityId;
    addCtl.cityName = self.poi.zhName;
    addCtl.shouldEdit = NO;
    [self.navigationController pushViewController:addCtl animated:YES];
}

/**
 *  游玩攻略
 *
 *  @param sender
 */
- (IBAction)play:(id)sender {
    [MobClick event:@"event_city_information"];
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
    [MobClick event:@"event_city_delicacy"];
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
    [MobClick event:@"event_city_shopping"];
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
    [MobClick event:@"event_more_city_travel_notes"];
    
    TravelNoteListViewController *travelListCtl = [[TravelNoteListViewController alloc] init];
    travelListCtl.isSearch = NO;
    travelListCtl.cityId = ((CityPoi *)self.poi).poiId;
    travelListCtl.cityName = ((CityPoi *)self.poi).zhName;
    [self.navigationController pushViewController:travelListCtl animated:YES];
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
    TaoziImage *image = [travelNote.images firstObject];
    cell.travelNoteImage = image.imageUrl;
    cell.title = travelNote.title;
    cell.desc = travelNote.summary;
    
    cell.property = [NSString stringWithFormat:@"%@    %@", travelNote.authorName, travelNote.publishDateStr];
    cell.canSelect = NO;
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"event_city_travel_note_item"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TravelNote *travelNote = [((CityPoi *)self.poi).travelNotes objectAtIndex:indexPath.row];
    TravelNoteDetailViewController *travelNoteCtl = [[TravelNoteDetailViewController alloc] init];
    travelNoteCtl.title = travelNote.title;
    travelNoteCtl.travelNote = travelNote;
    [self.navigationController pushViewController:travelNoteCtl animated:YES];
}

#pragma mark - IBAction
- (IBAction)option:(id)sender {
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"创建旅途计划", @"发给好友", nil];
    as.tag = 0;
    [as showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self makePlan];
    } else if (buttonIndex == 1) {
        [self shareToTalk];
    } else {
        return;
    }
}

- (void)makePlan {
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
    [MobClick event:@"event_create_new_trip_plan_city"];
}

- (void)dealtap:(UITapGestureRecognizer *)tap
{
    CityDescDetailViewController *cddVC = [[CityDescDetailViewController alloc]init];
    cddVC.des = self.poi.desc;
    [self.navigationController pushViewController:cddVC animated:YES];
}

@end






