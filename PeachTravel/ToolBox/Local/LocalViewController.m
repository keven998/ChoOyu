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

#define LOCAL_PAGE_TITLES       @[@"桃∙景", @"桃∙吃", @"桃∙购", @"桃∙住"]
#define LOCAL_PAGE_NORMALIMAGES       @[@"nearby_ic_tab_spot_normal.png", @"nearby_ic_tab_delicacy_normal.png", @"nearby_ic_tab_shopping_normal.png", @"nearby_ic_tab_stay_normal.png"]
#define LOCAL_PAGE_HIGHLIGHTEDIMAGES       @[@"nearby_ic_tab_spot_select.png", @"nearby_ic_tab_delicacy_select", @"nearby_ic_tab_shopping_select.png", @"nearby_ic_tab_stay_select.png"]

#define PAGE_FUN                0
#define PAGE_FOOD               1
#define PAGE_SHOPPING           2
#define PAGE_STAY               3

@interface LocalViewController ()<DMFilterViewDelegate, SwipeViewDataSource, SwipeViewDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate> {
    CLLocationManager* locationManager;
}

@property (nonatomic, strong) DMFilterView *filterView;
@property (nonatomic, strong) SwipeView *swipeView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) UILabel *locLabel;
@property (nonatomic, strong) UIButton *reLocBtn;

@property (strong, nonatomic) CLLocation *location;

@end

@implementation LocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我身边";
    self.view.backgroundColor = APP_PAGE_COLOR;
    
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
    [self loadData];
    
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
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate= self;
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
        [locationManager requestAlwaysAuthorization];
    } else {
        [locationManager startUpdatingLocation];
    }
}

#pragma mark - MKMapViewDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [locationManager stopUpdatingLocation];
    CLLocation *location = [locations firstObject];
    _location = location;
    [self getReverseGeocode];
    [_reLocBtn.layer removeAnimationForKey:@"rotationAnimation"];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            [locationManager stopUpdatingLocation];
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            [locationManager startUpdatingLocation];
            
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [locationManager startUpdatingLocation];
            
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
//            NSDictionary *dictionary = clPlaceMark.addressDictionary;
            NSString *city = [clPlaceMark.addressDictionary objectForKey:@"Name"];
            _locLabel.text = city;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }];
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

- (void)loadData {

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:3] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInt:0] forKey:@"page"];
    [params setObject:[NSNumber numberWithFloat:_lat] forKey:@"lat"];
    [params setObject:[NSNumber numberWithFloat:_lng] forKey:@"lng"];
    
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

    [SVProgressHUD show];
    [manager GET:API_NEARBY parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [SVProgressHUD dismiss];
            [self analysisData:[responseObject objectForKey:@"result"]];
        } else {
            [SVProgressHUD showErrorWithStatus:@"加载失败"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:@"加载失败"];
    }];
    
}

- (void)analysisData:(id)json
{
    NSString *key;
    NSMutableArray *currentList = [self.dataSource objectAtIndex:_currentPage];
    tripPoiType type;
    switch (_currentPage) {
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
        CLLocation *before=[[CLLocation alloc] initWithLatitude:_lat longitude:_lng];
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
//    switch (_currentPage) {
//        case PAGE_FOOD:
//            
//            break;
//            
//        default:
//            break;
//    }
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
    if (![[self.dataSource objectAtIndex:_currentPage] count]) {
        NSLog(@"点击我，我要加载数据") ;
        [self loadData];
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


@end
