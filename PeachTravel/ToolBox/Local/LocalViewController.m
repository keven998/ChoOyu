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
#import "AddSpotTableViewCell.h"
#import "PoiSummary.h"
#import "SpotDetailViewController.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"

#define LOCAL_PAGE_TITLES       @[@"桃∙玩", @"桃∙吃", @"桃∙买", @"桃∙住"]
#define LOCAL_PAGE_NORMALIMAGES       @[@"nearby_ic_tab_spot_normal.png", @"nearby_ic_tab_delicacy_normal.png", @"nearby_ic_tab_shopping_normal.png", @"nearby_ic_tab_stay_normal.png"]
#define LOCAL_PAGE_HIGHLIGHTEDIMAGES       @[@"nearby_ic_tab_spot_select.png", @"nearby_ic_tab_delicacy_select", @"nearby_ic_tab_shopping_select.png", @"nearby_ic_tab_stay_select.png"]

#define PAGE_FUN                0
#define PAGE_FOOD               1
#define PAGE_SHOPPING           2
#define PAGE_STAY               3

@interface LocalViewController ()<DMFilterViewDelegate, SwipeViewDataSource, SwipeViewDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) DMFilterView *filterView;
@property (nonatomic, strong) SwipeView *swipeView;
@property (nonatomic, assign) NSInteger currentPage;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我身边";
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    _didEndScroll = YES;
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    
    _filterView = [[DMFilterView alloc]initWithStrings:LOCAL_PAGE_TITLES normatlImages:LOCAL_PAGE_NORMALIMAGES highLightedImages:LOCAL_PAGE_HIGHLIGHTEDIMAGES containerView:self.view];
    _filterView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.filterView attachToContainerView];
    [self.filterView setDelegate:self];
    _filterView.backgroundColor = [UIColor whiteColor];
    _filterView.titlesColor = UIColorFromRGB(0x999999);
    _filterView.titlesFont = [UIFont systemFontOfSize:9.0];
    _filterView.selectedItemBackgroundColor = [UIColor whiteColor];

    _swipeView = [[SwipeView alloc] initWithFrame:CGRectMake(0, 64.0 + CGRectGetHeight(_filterView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64.0 - CGRectGetHeight(_filterView.frame))];
    _swipeView.dataSource = self;
    _swipeView.delegate = self;
    _swipeView.bounces = NO;
    _swipeView.backgroundColor = [UIColor redColor];
    _swipeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _swipeView.pagingEnabled = YES;
    _swipeView.itemsPerPage = 1;
    [self.view addSubview:_swipeView];
    
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, 64.0 + CGRectGetHeight(_filterView.frame), CGRectGetWidth(self.view.bounds), 1.0)];
    divider.backgroundColor = APP_PAGE_COLOR;
    [self.view addSubview:divider];
    
    
    UIView *fbar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 28.0, CGRectGetWidth(self.view.bounds), 28.0)];
    fbar.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.45];
    fbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:fbar];
    
    _locLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, CGRectGetWidth(fbar.frame) - 64.0, 28.0)];
    _locLabel.textColor = [UIColor whiteColor];
    _locLabel.font = [UIFont systemFontOfSize:10.0];
    [fbar addSubview:_locLabel];
    
    _reLocBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(fbar.frame) - 48.0 , 0.0, 48.0, 28.0)];
    [_reLocBtn addTarget:self action:@selector(relocal:) forControlEvents:UIControlEventTouchUpInside];
    [_reLocBtn setImage:[UIImage imageNamed:@"ic_refresh_white_18.png"] forState:UIControlStateNormal];
    [fbar addSubview:_reLocBtn];
    [self getReverseGeocode];
    
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
    
    if (IS_IOS8) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];

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
        for (int i = 0; i < 5; i++) {
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
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSInteger realPageIndex = _currentPage;

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithFloat:_location.coordinate.latitude] forKey:@"lat"];
    [params setObject:[NSNumber numberWithFloat:_location.coordinate.longitude] forKey:@"lng"];
    
    switch (_currentPage) {
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
    [params setObject:[NSNumber numberWithInt:pageIndex] forKey:@"page"];

    [manager GET:API_NEARBY parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self analysisData:[responseObject objectForKey:@"result"] withRealPageIndex:realPageIndex];
        } else {
            [SVProgressHUD showErrorWithStatus:@"加载失败"];
        }
        
        [self loadMoreCompletedWithCurrentPage:realPageIndex];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self loadMoreCompletedWithCurrentPage:realPageIndex];
        [SVProgressHUD showErrorWithStatus:@"加载失败"];
    }];
    
}

- (void)analysisData:(id)json withRealPageIndex:(NSInteger)realPageIndex
{
    NSString *key;
    NSMutableArray *currentList = [self.dataSource objectAtIndex:realPageIndex];
    tripPoiType type;
    switch (realPageIndex) {
        case PAGE_FUN:
            key = @"vs";
            type = TripSpotPoi;
            break;
        case PAGE_FOOD:
            key = @"restaurant";
            type = TripRestaurantPoi;

            break;
        case PAGE_SHOPPING:
            key = @"shopping";
            type = TripShoppingPoi;

            break;
        case PAGE_STAY:
            key = @"hotel";
            type = TripHotelPoi;

            break;
            
        default:
            break;
    }
    NSArray *dataList = [json objectForKey:key];
    for (id poiDic in dataList) {
        PoiSummary *poiSummary = [[PoiSummary alloc] initWithJson:poiDic];
        [currentList addObject:poiSummary];
        CLLocation *current=[[CLLocation alloc] initWithLatitude:poiSummary.lat longitude:poiSummary.lng];
        CLLocation *before=[[CLLocation alloc] initWithLatitude:_location.coordinate.latitude longitude:_location.coordinate.longitude];
        CLLocationDistance meters=[current distanceFromLocation:before];
        if (meters>1000) {
            poiSummary.distanceStr = [NSString stringWithFormat:@"%.1fkm", meters/1000];
        } else {
            poiSummary.distanceStr = [NSString stringWithFormat:@"%dm",(int)meters];

        }

    }
    UITableView *currentTableView =  (UITableView *)[_swipeView viewWithTag:1];
    if (currentTableView) {
        [currentTableView reloadData];
    }
    
    NSInteger oldPage = [[self.currentPageList objectAtIndex:realPageIndex] integerValue];
    NSLog(@"我将第%d 页的纵向第%d 加了一页", realPageIndex, oldPage);
    [self.currentPageList replaceObjectAtIndex:realPageIndex withObject:[NSNumber numberWithInt:++oldPage]];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PoiSummary *poi = [[_dataSource objectAtIndex:_currentPage] objectAtIndex:indexPath.row];
    switch (_currentPage) {
        case PAGE_FUN: {
            SpotDetailViewController *spotDetailCtl = [[SpotDetailViewController alloc] init];
            spotDetailCtl.spotId = poi.poiId;
            [self.navigationController pushViewController:spotDetailCtl animated:YES];
        }
            break;
            
        case PAGE_FOOD: {
            RestaurantDetailViewController *restaurant = [[RestaurantDetailViewController alloc] init];
            restaurant.restaurantId = poi.poiId;
            [self.navigationController pushViewController:restaurant animated:YES];
        }
            break;
        
        case PAGE_SHOPPING: {
            ShoppingDetailViewController *restaurant = [[ShoppingDetailViewController alloc] init];
            restaurant.shoppingId = poi.poiId;
            [self.navigationController pushViewController:restaurant animated:YES];
        }
            
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (_currentPage) {
        case PAGE_FUN:
            return 138.0;
            break;
            
        default:
            break;
    }
    return 185.0;
}


#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *datas = [self.dataSource objectAtIndex:_currentPage];
    return datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_currentPage == PAGE_FUN) {
        AddSpotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addSpotCell"];
        PoiSummary *poi = [[_dataSource objectAtIndex:_currentPage] objectAtIndex:indexPath.row];
        TripPoi *trippoi = [[TripPoi alloc] init];
        trippoi.poiId = poi.poiId;
        trippoi.images = poi.images;
        trippoi.zhName = poi.zhName;
        trippoi.enName = poi.enName;
        trippoi.desc = poi.desc;
        trippoi.rating = poi.rating;
        trippoi.timeCost = poi.timeCost;
        trippoi.lat = poi.lat;
        trippoi.lng = poi.lng;
        trippoi.distanceStr = poi.distanceStr;
        cell.tripPoi = trippoi;
        cell.addBtn.tag = indexPath.row;
        cell.shouldEdit = NO;
        return cell;
    }
    PoisOfCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"poisOfCity"];
    cell.shouldEdit = NO;
    cell.poi = [[_dataSource objectAtIndex:_currentPage] objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - SwipeViewDataSource

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return LOCAL_PAGE_TITLES.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    UITableView *tbView = nil;
    _currentPage = index;
    if (view == nil)
    {
        view = [[UIView alloc] initWithFrame:self.swipeView.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tbView = [[UITableView alloc] initWithFrame:view.bounds];
        tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tbView.contentInset = UIEdgeInsetsMake(10.0, 0.0, 10.0, 0.0);
        tbView.dataSource = self;
        tbView.delegate = self;
        tbView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tbView.tag = 1;
        tbView.backgroundColor = APP_PAGE_COLOR;
        
        [view addSubview:tbView];
        if (index == PAGE_FUN) {
            [tbView registerNib:[UINib nibWithNibName:@"AddSpotTableViewCell" bundle:nil] forCellReuseIdentifier:@"addSpotCell"];
        } else {
            [tbView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:@"poisOfCity"];
        }
    
    } else {
        tbView = (UITableView *)[view viewWithTag:1];
        if (index == PAGE_FUN) {
            [tbView registerNib:[UINib nibWithNibName:@"AddSpotTableViewCell" bundle:nil] forCellReuseIdentifier:@"addSpotCell"];
        } else {
            [tbView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:@"poisOfCity"];
        }
        [tbView reloadData];
    }

    return view;
}


#pragma mark - SwipeViewDelegate

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    _currentPage = swipeView.currentPage;
    [_filterView setSelectedIndex:_currentPage];
    /**
     *  如果要显示的页面已经有数据了，那么只是切换不加载数据
     */
    if (![[self.dataSource objectAtIndex:_currentPage] count]) {
        NSLog(@"点击我，我要加载数据") ;
        [self loadDataWithPageIndex:0];
    }

}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView {
    return swipeView.bounds.size;
}

#pragma mark - DMFilterViewDelegate

- (void)filterView:(DMFilterView *)filterView didSelectedAtIndex:(NSInteger)index {
    [_swipeView setCurrentPage:index];
    _currentPage = index;
}

#pragma mark - MKMapViewDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    CLLocation *location = [locations firstObject];
    _location = location;
    [self getReverseGeocode];
    [_reLocBtn.layer removeAnimationForKey:@"rotationAnimation"];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            [self.locationManager stopUpdatingLocation];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            
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
        if (error)
        {
            NSLog(@"failed with error: %@", error);
            return;
        }
        if(placemarks.count > 0)
        {
            CLPlacemark *clPlaceMark = [placemarks firstObject];
            NSString *city = [clPlaceMark.addressDictionary objectForKey:@"Name"];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            _locLabel.text = city;
            [self loadDataWithPageIndex:0];

            for (NSMutableArray *array in self.dataSource) {
                [array removeAllObjects];
            }
            self.currentPageList = nil;
            self.currentPageList = nil;
        }
    }];
}

- (void) beginLoadingMoreWithTableView:(UITableView *)tableView
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
    [self.isLoaddingMoreList replaceObjectAtIndex:_currentPage withObject:@YES];
    [indicatroView startAnimating];
    
    [self loadDataWithPageIndex:[[self.currentPageList objectAtIndex:_currentPage] integerValue]+1];
    
    NSLog(@"我开始加载新的内容了，新的内容是在横向第%d页，纵向第%d页", _currentPage,[[self.currentPageList objectAtIndex:_currentPage] integerValue]+1 );

}

- (void) loadMoreCompletedWithCurrentPage:(NSInteger)pageIndex {
    if (![[self.isLoaddingMoreList objectAtIndex:pageIndex] boolValue]) {
        return;
    }
    
    NSLog(@"我完成加载了");
    [self.isLoaddingMoreList replaceObjectAtIndex:pageIndex withObject:@NO];

    UIView *view = [self.swipeView itemViewAtIndex:pageIndex];
    UITableView *tableView = (UITableView *)[view viewWithTag:1];
    tableView.tableFooterView = nil;
}


#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    UIView *view = [self.swipeView itemViewAtIndex:_currentPage];
    UITableView *tableView = (UITableView *)[view viewWithTag:1];
    if (![tableView isEqual:scrollView]) {
        NSLog(@"警告。。。我已经销毁掉了，所以不应该加载数据了");
        return;
    }
    if ([scrollView isKindOfClass:[UITableView class]]) {
        BOOL isLoadingMore = [self.isLoaddingMoreList[_currentPage] boolValue];
        if (!isLoadingMore && _didEndScroll) {
            CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
            if (scrollPosition < 44) {
                NSLog(@"哈哈哈哈哈。滑倒地步了，我要加载了");
                //如果当前界面没有内容那么不加载内容，因为在点击的时候会加载内容
                if (![[self.dataSource objectAtIndex:_currentPage] count] == 0) {
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


@end





