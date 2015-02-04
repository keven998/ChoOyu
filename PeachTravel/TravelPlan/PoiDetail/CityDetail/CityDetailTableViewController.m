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

@interface CityDetailTableViewController () <UITableViewDataSource, UITableViewDelegate, CityHeaderViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) UIImageView *tableViewBkg;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) CityPoi *cityPoi;
@property (nonatomic, strong) CityHeaderView *cityHeaderView;
@property (nonatomic, strong) TZProgressHUD *hud;
@property (nonatomic, strong) UIView *customNavigationBar;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *cityPicture;

@end

@implementation CityDetailTableViewController

static NSString * const reuseIdentifier = @"travelNoteCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.delegate = self;
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _cityPicture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 188)];
    _cityPicture.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _cityPicture.contentMode = UIViewContentModeScaleAspectFill;
    _cityPicture.clipsToBounds = YES;
    [self.view addSubview:_cityPicture];
    [self.view addSubview:_scrollView];

    
    [self.tableView registerNib:[UINib nibWithNibName:@"TravelNoteTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    [self loadCityData];
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 72, 64.0)];
    [leftBtn setImage:[UIImage imageNamed:@"ic_city_back.png"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"ic_city_back_highlight.png"] forState:UIControlStateHighlighted];

    [leftBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    leftBtn.imageEdgeInsets = UIEdgeInsetsMake(17, 15, 0, 0);
    
    UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - 72, 0, 72, 64.0)];
    [moreBtn setImage:[UIImage imageNamed:@"ic_city_more.png"] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageNamed:@"ic_city_more_highlight.png"] forState:UIControlStateHighlighted];

    [moreBtn addTarget:self action:@selector(option:) forControlEvents:UIControlEventTouchUpInside];
    moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    moreBtn.imageEdgeInsets = UIEdgeInsetsMake(17, 0, 0, 15);
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont fontWithName:@"MicrosoftYaHei" size:17];
    title.tag = 123;
    
    _customNavigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 64)];
    _customNavigationBar.backgroundColor = APP_THEME_COLOR;
    [_customNavigationBar addSubview:title];
    _customNavigationBar.alpha = 0.0;
    title.center = CGPointMake(CGRectGetWidth(_customNavigationBar.bounds)/2, 40);
    [self.view addSubview:_customNavigationBar];
    
    [self.view addSubview:leftBtn];
    [self.view addSubview:moreBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
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
    self.navigationItem.title = _cityPoi.zhName;
    

    _cityHeaderView = [[CityHeaderView alloc] init];
    _cityHeaderView.delegate = self;
    [_cityHeaderView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
    _cityHeaderView.cityPoi = _cityPoi;
    
    
    CGRect frame = CGRectMake(10, _cityHeaderView.frame.size.height+10, self.view.frame.size.width-20, 50+130*_cityPoi.travelNotes.count+10);
    
    _tableViewBkg = [[UIImageView alloc] initWithFrame:frame];
    _tableViewBkg.userInteractionEnabled = YES;
    _tableViewBkg.image = [[UIImage imageNamed:@"ic_city_card_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 6, 12, 6)];

    [self.tableView setFrame:CGRectMake(1, 0, self.view.frame.size.width-22, 50+130*_cityPoi.travelNotes.count)];

    [_tableViewBkg addSubview:_tableView];
    
    [_scrollView addSubview:_tableViewBkg];
    [_scrollView addSubview:_cityHeaderView];
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width, frame.origin.y+frame.size.height+10)];
    
    [_cityHeaderView.favoriteBtn addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showSpotsBtn addTarget:self action:@selector(viewSpots:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showRestaurantsBtn addTarget:self action:@selector(viewRestaurants:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.showShoppingBtn addTarget:self action:@selector(viewShopping:) forControlEvents:UIControlEventTouchUpInside];
    [_cityHeaderView.playNotes addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    

    [self.tableView reloadData];
    
    if (_cityPoi.images.count > 0) {
        TaoziImage *taoziImage = [_cityPoi.images objectAtIndex:0];
        NSString *url = taoziImage.imageUrl;
        [_cityPicture sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"spot_detail_default.png"]];
    }
    
    UILabel *title = (UILabel *)[_customNavigationBar viewWithTag:123];
    title.text = _cityPoi.zhName;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.scrollEnabled = NO;
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
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    }
    
    NSString *requsetUrl = [NSString stringWithFormat:@"%@%@", API_GET_CITYDETAIL, _cityId];
    
    _hud = [[TZProgressHUD alloc] init];
    __weak typeof(CityDetailTableViewController *)weakSelf = self;
    [_hud showHUDInViewController:weakSelf];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:(kWindowWidth-22)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
   
    //获取城市信息
    [manager GET:requsetUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            _cityPoi = [[CityPoi alloc] initWithJson:[responseObject objectForKey:@"result"]];
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
    NSNumber *imageWidth = [NSNumber numberWithInt:100];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithInt:3] forKey:@"pageSize"];
    [params setObject:_cityPoi.cityId forKey:@"locId"];
    [params setObject:[NSNumber numberWithInt:0] forKey:@"page"];
    [manager GET:API_SEARCH_TRAVELNOTE parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            id travelNotes = [responseObject objectForKey:@"result"];
            if ([travelNotes isKindOfClass:[NSArray class]]) {
                _cityPoi.travelNotes = travelNotes;
            }
            [self.tableView reloadData];
        } else {
            
        }
        [_hud hideTZHUD];
        [self updateView];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [_hud hideTZHUD];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

/** 
 *  实现父类的发送 poi 到桃talk 的值传递
 *
 *  @param taoziMessageCtl
 */
- (void)setChatMessageModel:(TaoziChatMessageBaseViewController *)taoziMessageCtl
{
    taoziMessageCtl.messageId = _cityPoi.cityId;
    taoziMessageCtl.messageImage = ((TaoziImage *)[_cityPoi.images firstObject]).imageUrl;
    taoziMessageCtl.messageDesc = _cityPoi.desc;
    taoziMessageCtl.messageName = _cityPoi.zhName;
    taoziMessageCtl.messageTimeCost = _cityPoi.timeCostDesc;
    taoziMessageCtl.descLabel.text = _cityPoi.desc;
    taoziMessageCtl.chatType = TZChatTypeCity;
}

#pragma mark - IBAction Methods

- (IBAction)favorite:(id)sender
{
    //先将收藏的状态改变
    _cityHeaderView.favoriteBtn.selected = !_cityPoi.isMyFavorite;
    _cityHeaderView.favoriteBtn.userInteractionEnabled = NO;
    [super asyncFavorite:_cityPoi.cityId poiType:@"locality" isFavorite:!_cityPoi.isMyFavorite completion:^(BOOL isSuccess) {
        _cityHeaderView.favoriteBtn.userInteractionEnabled = YES;
        if (isSuccess) {
            _cityPoi.isMyFavorite = !_cityPoi.isMyFavorite;
        } else {      //如果失败了，再把状态改回来
            _cityHeaderView.favoriteBtn.selected = !_cityPoi.isMyFavorite;
        }
    }];
}

- (IBAction)viewSpots:(id)sender
{
    AddPoiViewController *addCtl = [[AddPoiViewController alloc] init];
    addCtl.cityId = _cityId;
    addCtl.cityName = _cityPoi.zhName;
    addCtl.shouldEdit = NO;
    [self.navigationController pushViewController:addCtl animated:YES];
}

- (IBAction)play:(id)sender {
    SuperWebViewController *funOfCityWebCtl = [[SuperWebViewController alloc] init];
    funOfCityWebCtl.urlStr = [NSString stringWithFormat:@"%@%@", FUN_CITY_HTML, _cityPoi.cityId];
    funOfCityWebCtl.titleStr = @"畅游攻略";//_cityPoi.zhName;
    [self.navigationController pushViewController:funOfCityWebCtl animated:YES];
}

- (IBAction)viewRestaurants:(id)sender
{
    NSLog(@"应该进入城市的美食信息");

    PoisOfCityViewController *restaurantOfCityCtl = [[PoisOfCityViewController alloc] init];
    restaurantOfCityCtl.shouldEdit = NO;
    restaurantOfCityCtl.cityId = _cityPoi.cityId;
    restaurantOfCityCtl.zhName = _cityPoi.zhName;
    restaurantOfCityCtl.poiType = kRestaurantPoi;
    
    [self.navigationController pushViewController:restaurantOfCityCtl animated:YES];
}

- (IBAction)viewShopping:(id)sender
{
    NSLog(@"应该进入城市的购物信息");

    PoisOfCityViewController *shoppingOfCityCtl = [[PoisOfCityViewController alloc] init];
    shoppingOfCityCtl.shouldEdit = NO;
    shoppingOfCityCtl.cityId = _cityPoi.cityId;
    shoppingOfCityCtl.zhName = _cityPoi.zhName;
    shoppingOfCityCtl.poiType = kShoppingPoi;
    
    [self.navigationController pushViewController:shoppingOfCityCtl animated:YES];
}

- (IBAction)showMoreTravelNote:(id)sender
{
    TravelNoteListViewController *travelListCtl = [[TravelNoteListViewController alloc] init];
    travelListCtl.isSearch = NO;
    travelListCtl.cityId = self.cityPoi.cityId;
    travelListCtl.cityName = self.cityPoi.zhName;
    [self.navigationController pushViewController:travelListCtl animated:YES];
}

#pragma mark - CityHeaderViewDelegate

- (void)updateCityHeaderView
{
    [UIView animateWithDuration:0.2 animations:^{
        [self.tableViewBkg setFrame:CGRectMake(10, _cityHeaderView.frame.size.height+10, _tableViewBkg.frame.size.width, _tableViewBkg.frame.size.height)];

    } completion:^(BOOL finished) {
    }];
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width, _tableViewBkg.frame.origin.y+_tableViewBkg.frame.size.height)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.cityPoi.travelNotes.count >= 1) {
        return 1;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 34.0;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cityPoi.travelNotes.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat width = CGRectGetWidth(tableView.frame);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 34.0)];
    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 2)];
    spaceView.backgroundColor = APP_SUB_THEME_COLOR;
    [view addSubview:spaceView];
    
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 108, 20)];
    text.text = @"精选游记";
    text.textColor = APP_SUB_THEME_COLOR;
    text.font = [UIFont boldSystemFontOfSize:16.0];
    text.userInteractionEnabled = YES;
    [view addSubview:text];
    
    UIButton *allNotes = [[UIButton alloc] initWithFrame:CGRectMake(width - 118, 0, 118, 34.0)];
    [allNotes setTitle:@"更多精选游记" forState:UIControlStateNormal];
    [allNotes setTitleColor:APP_SUB_THEME_COLOR forState:UIControlStateNormal];
    [allNotes setTitleColor:APP_SUB_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
    allNotes.titleLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:12.0];
    [allNotes setImage:[UIImage imageNamed:@"ic_city_access.png"] forState:UIControlStateNormal];
    allNotes.imageEdgeInsets = UIEdgeInsetsMake(2, 100, 0, -15);
    allNotes.contentEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 18);
    allNotes.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [allNotes addTarget:self action:@selector(showMoreTravelNote:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:allNotes];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TravelNoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    TravelNote *travelNote = [self.cityPoi.travelNotes objectAtIndex:indexPath.row];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TravelNote *travelNote = [self.cityPoi.travelNotes objectAtIndex:indexPath.row];
    TravelNoteDetailViewController *travelNoteCtl = [[TravelNoteDetailViewController alloc] init];
    travelNoteCtl.title = travelNote.title;
    travelNoteCtl.urlStr = travelNote.detailUrl;
    travelNoteCtl.travelNoteTitle = travelNote.title;
    travelNoteCtl.desc = travelNote.summary;
    TaoziImage *image = [travelNote.images firstObject];
    travelNoteCtl.travelNoteCover = image.imageUrl;
    travelNoteCtl.travelNoteId = travelNote.travelNoteId;
    [self.navigationController pushViewController:travelNoteCtl animated:YES];
    
}

#pragma mark - IBAction
- (IBAction)option:(id)sender {
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新建旅程", @"Talk", nil];
    as.tag = 0;
    [as showInView:self.view];
}

#pragma UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (_tableView != nil && [scrollView isEqual:_tableView]) {
        CGFloat y = scrollView.contentOffset.y;
        if (y <= 0) {
            CGRect frame = _cityPicture.frame;
            frame.size.height = 188 - y;
            frame.origin.y = 0;
            _cityPicture.frame = frame;
        } else {
            CGRect frame = _cityPicture.frame;
            frame.origin.y = -y;
            _cityPicture.frame = frame;
        }
    
//        _customNavigationBar.backgroundColor = [APP_THEME_COLOR colorWithAlphaComponent:alpha];
//        _customNavigationBar.alpha = (scrollView.contentOffset.y/200) > 1 ? 1 : scrollView.contentOffset.y/200;

//    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        Destinations *destinations = [[Destinations alloc] init];
        MakePlanViewController *makePlanCtl = [[MakePlanViewController alloc] init];
        ForeignViewController *foreignCtl = [[ForeignViewController alloc] init];
        DomesticViewController *domestic = [[DomesticViewController alloc] init];
        CityDestinationPoi *poi = [[CityDestinationPoi alloc] init];
        poi.zhName = _cityPoi.zhName;
        poi.cityId = _cityPoi.cityId;
        [destinations.destinationsSelected addObject:poi];
        makePlanCtl.destinations = destinations;
        domestic.destinations = destinations;
        foreignCtl.destinations = destinations;
        foreignCtl.title = @"国外";
        domestic.title = @"国内";
        makePlanCtl.viewControllers = @[domestic, foreignCtl];
        domestic.makePlanCtl = makePlanCtl;
        foreignCtl.makePlanCtl = makePlanCtl;
        domestic.notify = NO;
        foreignCtl.notify = NO;
        [self.navigationController pushViewController:makePlanCtl animated:YES];
    } else if (buttonIndex == 1) {
        [self shareToTalk];
    } else {
        return;
    }
}


@end





