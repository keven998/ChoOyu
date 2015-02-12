//
//  LocalViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/2.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "LocalViewController.h"
#import "DMFilterView.h"
#import "SwipeView.h"
#import "PoisOfCityTableViewCell.h"
#import "PoiSummary.h"
#import "SpotDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "CommonPoiDetailViewController.h"

#define LOCAL_PAGE_TITLES       @[@"景", @"美食", @"逛", @"住"]
#define LOCAL_PAGE_NORMALIMAGES       @[@"nearby_ic_tab_spot_normal.png", @"nearby_ic_tab_delicacy_normal.png", @"nearby_ic_tab_shopping_normal.png", @"nearby_ic_tab_stay_normal.png"]
#define LOCAL_PAGE_HIGHLIGHTEDIMAGES       @[@"nearby_ic_tab_spot_select.png", @"nearby_ic_tab_delicacy_select", @"nearby_ic_tab_shopping_select.png", @"nearby_ic_tab_stay_select.png"]

#define PAGE_FUN                0
#define PAGE_FOOD               1
#define PAGE_SHOPPING           2
#define PAGE_STAY               3

#define RECYCLE_PAGE_TAG        100

@interface LocalViewController ()<DMFilterViewDelegate, SwipeViewDataSource, SwipeViewDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) DMFilterView *filterView;
@property (nonatomic, strong) SwipeView *swipeView;
@property (nonatomic, strong) NSArray *dataSource;

/**
 *  管理四个界面的 currentPage
 */
@property (nonatomic, strong) NSMutableArray *currentPageList;
/**
 *  管理四个界面的是否正在加载更多的状态码   因为下拉的时候如果正在加载的话，不会再次执行加载更多的操作。。。然而四个界面相互独立，互不影响。因此需要四个状态码来管理四个界面。
 */
@property (nonatomic, strong) NSMutableArray *isLoaddingMoreList;

@property (nonatomic, assign) BOOL didEndScroll;

@property (nonatomic, strong) UILabel *locLabel;
@property (nonatomic, strong) UIButton *reLocBtn;

@property (strong, nonatomic) CLLocationManager* locationManager;


@end

@implementation LocalViewController

- (id)init {
    if (self = [super init]) {
        _didEndScroll = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.title = @"我身边";
    self.view.backgroundColor = APP_PAGE_COLOR;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0 , 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"我身边";
    self.navigationItem.titleView = titleLabel;
    
    _filterView = [[DMFilterView alloc]initWithStrings:LOCAL_PAGE_TITLES normatlImages:LOCAL_PAGE_NORMALIMAGES highLightedImages:LOCAL_PAGE_HIGHLIGHTEDIMAGES containerView:self.view];
    _filterView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.filterView attachToContainerView];
    [self.filterView setDelegate:self];
    _filterView.backgroundImage = [[UIImage imageNamed:@"navi_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
//    _filterView.backgroundColor = [UIColor clearColor];
    _filterView.titlesColor = TEXT_COLOR_TITLE_HINT;
    _filterView.titlesFont = [UIFont fontWithName:@"MicrosoftYaHei" size:9.0];
    _filterView.selectedItemBackgroundColor = [UIColor clearColor];

    _swipeView = [[SwipeView alloc] initWithFrame:CGRectMake(0, 64.0 + CGRectGetHeight(_filterView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64.0 - CGRectGetHeight(_filterView.frame))];
    _swipeView.dataSource = self;
    _swipeView.delegate = self;
    _swipeView.bounces = NO;
    _swipeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _swipeView.pagingEnabled = YES;
    _swipeView.itemsPerPage = 1;
    [self.view addSubview:_swipeView];
    
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, 64.0 + CGRectGetHeight(_filterView.frame), CGRectGetWidth(self.view.bounds), 0.6)];
    divider.backgroundColor = APP_DIVIDER_COLOR;
    divider.layer.shadowColor = APP_DIVIDER_COLOR.CGColor;
    divider.layer.shadowOffset = CGSizeMake(0.0, 0.5);
    divider.layer.shadowRadius = 0.5;
    divider.layer.shadowOpacity = 1.0;
    [self.view addSubview:divider];
    
    UIView *fbar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 30.0, CGRectGetWidth(self.view.bounds), 30.0)];
    fbar.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.67];
    fbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:fbar];
    
    _locLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, CGRectGetWidth(fbar.frame) - 64.0, 30.0)];
    _locLabel.textColor = [UIColor whiteColor];
    _locLabel.font = [UIFont fontWithName:@"MicrosoftYaHei" size:11.0];
    [fbar addSubview:_locLabel];
    
    _reLocBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(fbar.frame) - 48.0 , 0.0, 48.0, 30.0)];
    [_reLocBtn addTarget:self action:@selector(relocal:) forControlEvents:UIControlEventTouchUpInside];
    [_reLocBtn setImage:[UIImage imageNamed:@"ic_refresh_white_18.png"] forState:UIControlStateNormal];
    [fbar addSubview:_reLocBtn];
    
//    [self getReverseGeocode];
    [self relocal:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBarTintColor:APP_THEME_COLOR];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bkg.png"] forBarMetrics:UIBarMetricsDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)relocal:(id)sender {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 0.8;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = INFINITY;
    [_reLocBtn.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    _locLabel.text = @"正在定位...";
    
    if (IS_IOS8) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (IBAction)jumpToMapView:(UIButton *)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"其他软件导航"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    NSArray *platformArray = [ConvertMethods mapPlatformInPhone];
    for (NSDictionary *dic in platformArray) {
        [sheet addButtonWithTitle:[dic objectForKey:@"platform"]];
    }
    [sheet addButtonWithTitle:@"取消"];
    sheet.cancelButtonIndex = sheet.numberOfButtons-1;
    [sheet showInView:self.view];
    sheet.tag = sender.tag;
   
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate= self;
    }
    return _locationManager;
}

#pragma mark - getter & getter

- (NSArray *)dataSource
{
    if (!_dataSource) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 4; i++) {
            NSMutableArray *oneList = [[NSMutableArray alloc] init];
            [tempArray addObject:oneList];
        }
        _dataSource = tempArray;
    }
    return _dataSource;
}

- (NSArray *)currentPageList
{
    if (!_currentPageList) {
        _currentPageList = [@[@(-1), @(-1), @(-1), @(-1)] mutableCopy];
    }
    return _currentPageList;
}

- (NSArray *)isLoaddingMoreList
{
    if (!_isLoaddingMoreList) {
        _isLoaddingMoreList = [@[@NO, @NO, @NO, @NO] mutableCopy];
    }
    return _isLoaddingMoreList;
}

- (void)loadDataWithPageIndex:(NSInteger)pageIndex
{
    if (!_location) {
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSInteger realPageIndex = _swipeView.currentItemView.tag;

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:200];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithFloat:_location.coordinate.latitude] forKey:@"lat"];
    [params setObject:[NSNumber numberWithFloat:_location.coordinate.longitude] forKey:@"lng"];
    
    switch (realPageIndex) {
        case PAGE_FUN:
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"vs"];
            break;
            
        case PAGE_FOOD:
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"restaurant"];
            break;
            
        case PAGE_SHOPPING:
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"shopping"];
            break;
            
        case PAGE_STAY:
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"hotel"];
            break;
            
        default:
            break;
    }
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInteger:pageIndex] forKey:@"page"];
    
    [manager GET:API_NEARBY parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            //防止切换的时候重复加载
            [self analysisData:[responseObject objectForKey:@"result"] withRealPageIndex:realPageIndex];
        } else {
//            [SVProgressHUD showErrorWithStatus:@"加载失败"];
//            [self showHint:@"请求也是失败了"];
        }
        
        [self loadMoreCompletedWithCurrentPage:realPageIndex];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self loadMoreCompletedWithCurrentPage:realPageIndex];
//        [SVProgressHUD showErrorWithStatus:@"加载失败"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self showHint:@"呃～好像没找到网络"];
        
    }];
    
}

- (void)analysisData:(id)json withRealPageIndex:(NSInteger)realPageIndex
{
    NSString *key;
    NSMutableArray *currentList = [self.dataSource objectAtIndex:realPageIndex];
    TZPoiType type;
    switch (realPageIndex) {
        case PAGE_FUN:
            key = @"vs";
            type = kSpotPoi;
            break;
            
        case PAGE_FOOD:
            key = @"restaurant";
            type = kRestaurantPoi;
            break;
            
        case PAGE_SHOPPING:
            key = @"shopping";
            type = kShoppingPoi;
            break;
            
        case PAGE_STAY:
            key = @"hotel";
            type = kHotelPoi;
            break;
            
        default:
            break;
    }
    NSArray *dataList = [json objectForKey:key];
    for (id poiDic in dataList) {
        PoiSummary *poiSummary = [[PoiSummary alloc] initWithJson:poiDic];
        poiSummary.poiType = type;
        [currentList addObject:poiSummary];
        CLLocation *current=[[CLLocation alloc] initWithLatitude:poiSummary.lat longitude:poiSummary.lng];
        CLLocation *before=[[CLLocation alloc] initWithLatitude:_location.coordinate.latitude longitude:_location.coordinate.longitude];
        CLLocationDistance meters=[current distanceFromLocation:before];
        if (meters>1000 && meters<10000) {
            poiSummary.distanceStr = [NSString stringWithFormat:@"%.1fkm", meters/1000];
        } else if (meters<1000) {
            poiSummary.distanceStr = [NSString stringWithFormat:@"%dm",(int)meters];
        } else if (meters>=10000) {
            poiSummary.distanceStr = @">10km";
        }

    }
    UITableView *currentTableView =  (UITableView *)[_swipeView.currentItemView viewWithTag:RECYCLE_PAGE_TAG];
    if (currentTableView) {
        [currentTableView reloadData];
    }
    
    NSInteger oldPage = [[self.currentPageList objectAtIndex:realPageIndex] integerValue];
    [self.currentPageList replaceObjectAtIndex:realPageIndex withObject:[NSNumber numberWithInteger:++oldPage]];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger tag = [tableView superview].tag;
    PoiSummary *poi = [[_dataSource objectAtIndex:tag] objectAtIndex:indexPath.row];
    switch (tag) {
        case PAGE_FUN: {
            SpotDetailViewController *spotDetailCtl = [[SpotDetailViewController alloc] init];
            spotDetailCtl.spotId = poi.poiId;
            [self addChildViewController:spotDetailCtl];
            [self.view addSubview:spotDetailCtl.view];
        }
            break;
            
        case PAGE_FOOD: {
            CommonPoiDetailViewController *restaurant = [[CommonPoiDetailViewController alloc] init];
            restaurant.poiId = poi.poiId;
            restaurant.poiType = kRestaurantPoi;
            [self addChildViewController:restaurant];
            [self.view addSubview:restaurant.view];
        }
            break;
        
        case PAGE_SHOPPING: {
            CommonPoiDetailViewController *shopping = [[CommonPoiDetailViewController alloc] init];
            shopping.poiId = poi.poiId;
            shopping.poiType = kShoppingPoi;
            [self addChildViewController:shopping];
            [self.view addSubview:shopping.view];
        }
            break;
            
        case PAGE_STAY: {
            CommonPoiDetailViewController *hotel = [[CommonPoiDetailViewController alloc] init];
            hotel.poiId = poi.poiId;
            hotel.poiType = kHotelPoi;
            [self addChildViewController:hotel];
            [self.view addSubview:hotel.view];
        }
            break;
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 155;
}


#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger page = [tableView superview].tag;
    NSArray *datas = [self.dataSource objectAtIndex:page];
    return datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger page = [tableView superview].tag;
   
    PoisOfCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poisOfCity"];
    cell.shouldEdit = NO;
    cell.isNearByCell = YES;
    cell.naviBtn.tag = indexPath.row;
    [cell.naviBtn removeTarget:self action:@selector(jumpToMapView:) forControlEvents:UIControlEventTouchUpInside];
    [cell.naviBtn addTarget:self action:@selector(jumpToMapView:) forControlEvents:UIControlEventTouchUpInside];
    cell.poi = [[_dataSource objectAtIndex:page] objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - SwipeViewDataSource

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return LOCAL_PAGE_TITLES.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UITableView *tbView = nil;
    if (view == nil)
    {
        view = [[UIView alloc] initWithFrame:self.swipeView.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.backgroundColor = APP_PAGE_COLOR;
        view.tag = index;
        tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)];
        tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tbView.contentInset = UIEdgeInsetsMake(5.0, 0.0, 5.0, 0.0);
        tbView.dataSource = self;
        tbView.delegate = self;
        tbView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tbView.tag = RECYCLE_PAGE_TAG;
        tbView.backgroundColor = APP_PAGE_COLOR;
        
        [view addSubview:tbView];
        [tbView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:@"poisOfCity"];
    } else {
        view.tag = index;
        tbView = (UITableView *)[view viewWithTag:RECYCLE_PAGE_TAG];
//        [tbView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:@"poisOfCity"];
        [tbView setContentOffset:CGPointZero animated:NO];
        [tbView reloadData];
    }

    return view;
}


#pragma mark - SwipeViewDelegate

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    NSInteger page = swipeView.currentPage;
    
    if (_filterView.selectedIndex != page) {
        [_filterView setSelectedIndex:page];
    }
    /**
     *  如果要显示的页面已经有数据了，那么只是切换不加载数据
     */
    if (![[self.dataSource objectAtIndex:page] count] && ![[self.isLoaddingMoreList objectAtIndex:page] boolValue]) {
        [self.isLoaddingMoreList replaceObjectAtIndex:page withObject:@YES];
        NSLog(@"我在加载数据 = %ld", (long)page);
        [self loadDataWithPageIndex:0];
    }
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView {
    return swipeView.bounds.size;
}

#pragma mark - DMFilterViewDelegate

- (void)filterView:(DMFilterView *)filterView didSelectedAtIndex:(NSInteger)index {
    if (_swipeView.currentPage == index) {
        UITableView *currentTableView =  (UITableView *)[_swipeView.currentItemView viewWithTag:RECYCLE_PAGE_TAG];
        [currentTableView setContentOffset:CGPointZero animated:YES];
    } else {
        [_swipeView setCurrentPage:index];
    }
}

#pragma mark - MKMapViewDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    CLLocation *location = [locations firstObject];
    _location = location;
    [self getReverseGeocode];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self performSelector:@selector(stopRefreashWithStatus:) withObject:@"获取当前位置失败" afterDelay:0.8];
}

- (void)stopRefreashWithStatus:(NSString *)msg {
    [_reLocBtn.layer removeAnimationForKey:@"rotationAnimation"];
    _locLabel.text = msg;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            [self.locationManager stopUpdatingLocation];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"去设置里打开“桃子”的定位服务吧~" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
            break;
            
        case kCLAuthorizationStatusDenied: {
            [self.locationManager stopUpdatingLocation];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"去设置里打开“桃子”的定位服务吧~" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        }
            break;

            
        case kCLAuthorizationStatusAuthorizedAlways:
            
            break;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            
            break;
            
        default:
            break;
    }
}

- (void)getReverseGeocode
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocationCoordinate2D myCoOrdinate;
    
    myCoOrdinate.latitude = _location.coordinate.latitude;
    myCoOrdinate.longitude = _location.coordinate.longitude;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:myCoOrdinate.latitude longitude:myCoOrdinate.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (error)
        {
            NSLog(@"failed with error: %@", error);
            [self performSelector:@selector(stopRefreashWithStatus:) withObject:@"获取位置信息失败" afterDelay:0.8];
            return;
        }
        if(placemarks.count > 0)
        {
            CLPlacemark *clPlaceMark = [placemarks firstObject];
            NSString *city = [clPlaceMark.addressDictionary objectForKey:@"Name"];
            [self performSelector:@selector(stopRefreashWithStatus:) withObject:city afterDelay:0.8];
            for (NSMutableArray *array in self.dataSource) {
                [array removeAllObjects];
            }
            UITableView *tbView = (UITableView *)[_swipeView.currentItemView viewWithTag:RECYCLE_PAGE_TAG];
            [tbView reloadData];
            int currentPage = _swipeView.currentPage;
            _isLoaddingMoreList = nil;
            _dataSource = nil;
            _currentPageList = nil;
            [self loadDataWithPageIndex:currentPage];
            [self.isLoaddingMoreList replaceObjectAtIndex:currentPage withObject:@YES];
        }
    }];
}

- (void)beginLoadingMoreWithTableView:(UITableView *)tableView
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44.0)];
    footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    footerView.backgroundColor = APP_PAGE_COLOR;
    
    UIActivityIndicatorView *indicatroView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32.0, 32.0)];
    [indicatroView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [footerView addSubview:indicatroView];
    [indicatroView setCenter:CGPointMake(CGRectGetWidth(self.view.bounds)/2.0, 44.0/2.0)];
    
    tableView.tableFooterView = footerView;
    
    //将对应页面正在加载的状态改为 yes
    NSInteger page = [tableView superview].tag;
    [self.isLoaddingMoreList replaceObjectAtIndex:page withObject:@YES];
    [indicatroView startAnimating];
    
    [self loadDataWithPageIndex:[[self.currentPageList objectAtIndex:page] integerValue]+1];
}

- (void)loadMoreCompletedWithCurrentPage:(NSInteger)pageIndex {
    if (![[self.isLoaddingMoreList objectAtIndex:pageIndex] boolValue]) {
        return;
    }
    
    NSLog(@"我完成加载了");
    [self.isLoaddingMoreList replaceObjectAtIndex:pageIndex withObject:@NO];

    UIView *view = [self.swipeView itemViewAtIndex:pageIndex];
    UITableView *tableView = (UITableView *)[view viewWithTag:RECYCLE_PAGE_TAG];
    tableView.tableFooterView = nil;
}

- (void)dealloc
{
    _swipeView.delegate = nil;
    _swipeView.dataSource = nil;
    _swipeView = nil;
    _filterView.delegate = nil;
    _filterView = nil;
    self.dataSource = nil;
    [_currentPageList removeAllObjects];
    _currentPageList = nil;
    [_locationManager stopUpdatingLocation];
    _locationManager.delegate = nil;
    _locationManager = nil;
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIView *view = [self.swipeView currentItemView];
    UITableView *tableView = (UITableView *)[view viewWithTag:RECYCLE_PAGE_TAG];
    if (![tableView isEqual:scrollView]) {
        NSLog(@"警告。。。我已经销毁掉了，所以不应该加载数据了");
        return;
    }
    if ([scrollView isKindOfClass:[UITableView class]]) {
        BOOL isLoadingMore = [self.isLoaddingMoreList[view.tag] boolValue];
        if (!isLoadingMore && _didEndScroll) {
            CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
            if (scrollPosition < 44) {
                NSLog(@"哈哈哈哈哈。滑倒地步了，我要加载了");
                //如果当前界面没有内容那么不加载内容，因为在点击的时候会加载内容
                if (![[self.dataSource objectAtIndex:view.tag] count] == 0) {
                    [self beginLoadingMoreWithTableView:(UITableView *)scrollView];
                }
                _didEndScroll = NO;
            }
        }
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"scrollViewDidEndDecelerating");
    _didEndScroll = YES;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    NSInteger tag = _swipeView.currentItemView.tag;
    PoiSummary *poi = [[_dataSource objectAtIndex:tag] objectAtIndex:actionSheet.tag];
    NSArray *platformArray = [ConvertMethods mapPlatformInPhone];
    switch (buttonIndex) {
        case 0:
            switch ([[[platformArray objectAtIndex:0] objectForKey:@"type"] intValue]) {
                case kAMap:
                    [ConvertMethods jumpGaodeMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                    break;
                    
                case kBaiduMap: {
                    [ConvertMethods jumpBaiduMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    break;
                    
                case kAppleMap: {
                    [ConvertMethods jumpAppleMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    
                default:
                    break;
            }
            break;
            
        case 1:
            switch ([[[platformArray objectAtIndex:1] objectForKey:@"type"] intValue]) {
                case kAMap:
                    [ConvertMethods jumpGaodeMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                    break;
                    
                case kBaiduMap: {
                    [ConvertMethods jumpBaiduMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    break;
                    
                case kAppleMap: {
                    [ConvertMethods jumpAppleMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        case 2:
            switch ([[[platformArray objectAtIndex:2] objectForKey:@"type"] intValue]) {
                case kAMap:
                    [ConvertMethods jumpGaodeMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                    break;
                    
                case kBaiduMap: {
                    [ConvertMethods jumpBaiduMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }
                    break;
                    
                case kAppleMap: {
                    [ConvertMethods jumpAppleMapAppWithPoiName:poi.zhName lat:poi.lat lng:poi.lng];
                }                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}


@end





