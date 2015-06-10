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

@interface CityDetailTableViewController () <UITableViewDataSource, UITableViewDelegate, CityHeaderViewDelegate, UIActionSheetDelegate>
{
    UIButton *_favoriteBtn;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CityHeaderView *cityHeaderView;
@property (nonatomic, strong) TZProgressHUD *hud;
//@property (nonatomic, strong) UIImageView *customNavigationBar;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *cityPicture;

@end

@implementation CityDetailTableViewController

static NSString * const reuseIdentifier = @"travelNoteCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"城市";
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIButton *planBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 38, 44)];
    [planBtn setImage:[UIImage imageNamed:@"ic_add_city.png"] forState:UIControlStateNormal];
    [planBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [planBtn addTarget:self action:@selector(makePlan) forControlEvents:UIControlEventTouchUpInside];
//    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:planBtn]];
    
    UIButton *talkBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 44)];
    [talkBtn setImage:[UIImage imageNamed:@"ic_ztl_lt"] forState:UIControlStateNormal];
    [talkBtn addTarget:self action:@selector(shareToTalk) forControlEvents:UIControlEventTouchUpInside];
    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:talkBtn]];
    
    _favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 44)];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_ztl_sc_2"] forState:UIControlStateNormal];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_ztl_sc_1"] forState:UIControlStateHighlighted];
    [_favoriteBtn setImage:[UIImage imageNamed:@"ic_ztl_sc_1"] forState:UIControlStateSelected];
    
    
    [_favoriteBtn addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
    [barItems addObject:[[UIBarButtonItem alloc]initWithCustomView:_favoriteBtn]];
    
    self.navigationItem.rightBarButtonItems = barItems;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.delegate = self;
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    _cityPicture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetWidth(self.view.bounds)*0.6)];
    _cityPicture.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _cityPicture.contentMode = UIViewContentModeScaleAspectFill;
    _cityPicture.clipsToBounds = YES;
    [self.view addSubview:_cityPicture];
    [self.view addSubview:_scrollView];
    
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
    _cityHeaderView.delegate = nil;
    _cityHeaderView = nil;
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    _tableView = nil;
}

- (void)updateView
{
    _cityHeaderView = [[CityHeaderView alloc] init];
    _cityHeaderView.delegate = self;
    [_cityHeaderView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    _cityHeaderView.cityPoi = (CityPoi *)self.poi;
    
    CGRect frame = CGRectMake(0, _cityHeaderView.frame.size.height+10, CGRectGetWidth(self.view.bounds), 40+90*((CityPoi *)self.poi).travelNotes.count);
    [self.tableView setFrame:frame];
    [_scrollView addSubview:_tableView];
    [_scrollView addSubview:_cityHeaderView];
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width, frame.origin.y+frame.size.height)];
    
    [_cityHeaderView.showSpotsBtn addTarget:self action:@selector(viewSpots:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showRestaurantsBtn addTarget:self action:@selector(viewRestaurants:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showShoppingBtn addTarget:self action:@selector(viewShopping:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showTipsBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dealtap:)];
    
    [_cityHeaderView.cityDesc addGestureRecognizer:tap];
    
    if (self.poi.images.count > 0) {
        TaoziImage *taoziImage = [self.poi.images objectAtIndex:0];
        NSString *url = taoziImage.imageUrl;
        [_cityPicture sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"spot_detail_default.png"]];
    }
    _favoriteBtn.selected=self.poi.isMyFavorite;
//    UILabel *title = (UILabel *)[_customNavigationBar viewWithTag:123];
//    title.text = self.poi.zhName;
}

- (void)updateTableView
{
    CGRect frame = CGRectMake(0, _cityHeaderView.frame.size.height + 10, self.view.frame.size.width, 40+90*((CityPoi *)self.poi).travelNotes.count + 64);
    [self.tableView setFrame:frame];
    [_scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width, frame.origin.y+frame.size.height)];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        _tableView.scrollEnabled = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
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
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
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
            [self.tableView reloadData];
            [self updateTableView];
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

- (IBAction)favorite:(UIButton *)sender
{
    [MobClick event:@"event_city_favorite"];
    //先将收藏的状态改变
//    _cityHeaderView.favoriteBtn.selected = !self.poi.isMyFavorite;
//    _cityHeaderView.favoriteBtn.userInteractionEnabled = NO;
    
    [super asyncFavoritePoiWithCompletion:^(BOOL isSuccess) {
//        _cityHeaderView.favoriteBtn.userInteractionEnabled = YES;
//        if (!isSuccess) {
//            _cityHeaderView.favoriteBtn.selected = !_cityHeaderView.favoriteBtn.selected;
//
//        }
        if (isSuccess) {
            _favoriteBtn.selected = !_favoriteBtn.selected;
        }
    }];
    
    
}

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

#pragma mark - CityHeaderViewDelegate

- (void)updateCityHeaderView
{
    [UIView animateWithDuration:0.2 animations:^{
        [self.tableView setFrame:CGRectMake(0, _cityHeaderView.frame.size.height+10, _tableView.frame.size.width, _tableView.frame.size.height)];
    } completion:nil];
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width, _tableView.frame.origin.y+_tableView.frame.size.height)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 40;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((CityPoi *)self.poi).travelNotes.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat width = CGRectGetWidth(tableView.frame);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, width, 20)];
    text.text = @"精选游记";
    text.textColor = TEXT_COLOR_TITLE_SUBTITLE;
    text.font = [UIFont boldSystemFontOfSize:17.0];
    text.textAlignment = NSTextAlignmentCenter;
    text.userInteractionEnabled = YES;
    [view addSubview:text];
    
    UIButton *allNotes = [[UIButton alloc] initWithFrame:CGRectMake(width - 118, 4, 118, 36)];
    [allNotes setTitle:@"更多" forState:UIControlStateNormal];
    [allNotes setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    allNotes.titleLabel.font = [UIFont systemFontOfSize:13.0];

    allNotes.titleEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 14);
    allNotes.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [allNotes addTarget:self action:@selector(showMoreTravelNote:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:allNotes];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TravelNoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    TravelNote *travelNote = [((CityPoi *)self.poi).travelNotes objectAtIndex:indexPath.row];
    TaoziImage *image = [travelNote.images firstObject];
    cell.travelNoteImage = image.imageUrl;
    cell.title = travelNote.title;
    cell.desc = travelNote.summary;
    
    cell.property = [NSString stringWithFormat:@"%@  %@  %@", travelNote.authorName, travelNote.source, travelNote.publishDateStr];
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_tableView != nil) {
        CGFloat y = scrollView.contentOffset.y;
        if (y <= 0) {
            CGRect frame = _cityPicture.frame;
            frame.size.height = kWindowWidth*0.6 - y;
            frame.origin.y = 0;
            _cityPicture.frame = frame;
        } else {
            CGRect frame = _cityPicture.frame;
            frame.origin.y = -y;
            _cityPicture.frame = frame;
        }
    }
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






