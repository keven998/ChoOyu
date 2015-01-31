//
//  AddPoiViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "AddPoiViewController.h"
#import "AddSpotTableViewCell.h"
#import "CityDestinationPoi.h"
#import "TripDetail.h"
#import "SpotDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "PoiSummary.h"
#import "PoisOfCityTableViewCell.h"
#import "TZFilterViewController.h"


@interface AddPoiViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, TZFilterViewDelegate, UISearchDisplayDelegate>

@property (nonatomic) NSUInteger currentListTypeIndex;
@property (nonatomic) NSUInteger currentCityIndex;
@property (nonatomic, strong) NSArray *urlArray;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UITableView *tableView;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) UISearchDisplayController *searchController;
@property (nonatomic, strong) UIActivityIndicatorView *indicatroView;
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, copy) NSString *requestUrl;

@property (nonatomic, strong) NSMutableArray *searchResultArray;

@property (nonatomic, strong) TZFilterViewController *filterCtl;

//管理普通 tableview 的加载状态
@property (nonatomic) NSUInteger currentPageNormal;
@property (nonatomic, assign) BOOL isLoadingMoreNormal;
@property (nonatomic, assign) BOOL didEndScrollNormal;
@property (nonatomic, assign) BOOL enableLoadMoreNormal;

//管理搜索 tableview 的加载状态
@property (nonatomic) NSUInteger currentPageSearch;
@property (nonatomic, assign) BOOL isLoadingMoreSearch;
@property (nonatomic, assign) BOOL didEndScrollSearch;
@property (nonatomic, assign) BOOL enableLoadMoreSearch;

@property (nonatomic, copy) NSString *searchText;

@end

@implementation AddPoiViewController

static NSString *addSpotCellIndentifier = @"addSpotCell";
static NSString *addRestaurantCellIndentifier = @"poisOfCity";
static NSString *addShoppingCellIndentifier = @"poisOfCity";

- (id)init {
    if (self = [super init]) {
        _currentPageNormal = 0;
        _isLoadingMoreNormal = YES;
        _didEndScrollNormal = YES;
        _enableLoadMoreNormal = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = APP_PAGE_COLOR;
   
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate  = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    if (_tripDetail) {
         self.navigationItem.title = [NSString stringWithFormat:@"第%lu天(%lu安排)", (unsigned long)(_currentDayIndex + 1), (unsigned long)[[self.tripDetail.itineraryList objectAtIndex:_currentDayIndex] count]];
        UIBarButtonItem *finishBtn = [[UIBarButtonItem alloc]initWithTitle:@" 完成" style:UIBarButtonItemStyleBordered target:self action:@selector(addFinish:)];
        self.navigationItem.leftBarButtonItem = finishBtn;
        
        UIBarButtonItem * filterBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(filter:)];
        [filterBtn setImage:[UIImage imageNamed:@"ic_nav_filter_normal.png"]];
        self.navigationItem.rightBarButtonItem = filterBtn;
    } else {
//        self.navigationItem.title = [NSString stringWithFormat:@"玩在%@", _cityName];
        self.navigationItem.title = [NSString stringWithFormat:@"%@美景", _cityName];
    }
    
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    _urlArray = @[API_GET_SPOTLIST_CITY, API_GET_RESTAURANTSLIST_CITY, API_GET_SHOPPINGLIST_CITY, API_GET_HOTELLIST_CITY];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AddSpotTableViewCell" bundle:nil] forCellReuseIdentifier:addSpotCellIndentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:addRestaurantCellIndentifier];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 40)];
    _searchBar.delegate = self;
    self.tableView.tableHeaderView = _searchBar;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    [self.searchController.searchResultsTableView registerNib:[UINib nibWithNibName:@"AddSpotTableViewCell" bundle:nil] forCellReuseIdentifier:addSpotCellIndentifier];
    [self.searchController.searchResultsTableView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:addRestaurantCellIndentifier];
    self.searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchController.searchResultsTableView.backgroundColor = APP_PAGE_COLOR;
    self.searchController.searchResultsTableView.dataSource = self;
    self.searchController.searchResultsTableView.delegate = self;
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    
    if (_tripDetail) {
        CityDestinationPoi *firstDestination = [_tripDetail.destinations firstObject];
        _requestUrl = [NSString stringWithFormat:@"%@%@", API_GET_SPOTLIST_CITY ,firstDestination.cityId];
    } else {
        _requestUrl = [NSString stringWithFormat:@"%@%@", API_GET_SPOTLIST_CITY ,_cityId];

    }
    
    [self loadDataWithPageNo:_currentPageNormal];
}


#pragma mark - setter & getter

- (TZFilterViewController *)filterCtl
{
    if (!_filterCtl) {
        NSMutableArray *titiles = [[NSMutableArray alloc] init];
        for (CityDestinationPoi *poi in _tripDetail.destinations) {
            [titiles addObject:poi.zhName];
        }
        _filterCtl = [[TZFilterViewController alloc] init];
        _filterCtl.filterItemsArray = @[titiles, @[@"景点", @"美食", @"购物", @"酒店"]];
        _filterCtl.filterTitles = @[@"城市",@"类型"];
        _filterCtl.lineCountPerFilterType = @[@1, @2];
        _filterCtl.selectedItmesIndex = @[@0, @0];
        _filterCtl.delegate = self;
    }
    return _filterCtl;
}

- (NSMutableArray *)searchResultArray
{
    if (!_searchResultArray) {
        _searchResultArray = [[NSMutableArray alloc] init];
    }
    return _searchResultArray;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 44.0)];
        _footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _footerView.backgroundColor = APP_PAGE_COLOR;
        _indicatroView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 32.0, 32.0)];
        [_indicatroView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [_footerView addSubview:_indicatroView];
        [_indicatroView setCenter:CGPointMake(CGRectGetWidth(self.tableView.bounds)/2.0, 44.0/2.0)];
    }
    return _footerView;
}

#pragma mark - private methods

/**
 *  非搜索状态下上拉加载更多
 */
- (void) beginLoadingMoreNormal
{
    if (self.tableView.tableFooterView == nil) {
        self.tableView.tableFooterView = self.footerView;
    }
    _isLoadingMoreNormal = YES;
    [_indicatroView startAnimating];
    [self loadDataWithPageNo:(_currentPageNormal + 1)];
    
    NSLog(@"我要加载到第%lu",(long)_currentPageNormal+1);
    
}

/**
 *  非搜索状态下加载完成
 */
- (void) loadMoreCompletedNormal
{
    if (!_isLoadingMoreNormal) return;
    [_indicatroView stopAnimating];
    _isLoadingMoreNormal = NO;
}

/**
 *  搜索状态下上拉加载更多
 */
- (void) beginLoadingSearch
{
    if (self.searchController.searchResultsTableView.tableFooterView == nil) {
        self.searchController.searchResultsTableView.tableFooterView = self.footerView;
    }
    _isLoadingMoreSearch = YES;
    [_indicatroView startAnimating];
    [self loadSearchDataWithPageNo:(_currentPageSearch + 1)];
    
    NSLog(@"我要加载到第%lu",(long)_currentPageSearch+1);
    
}

/**
 *  搜索状态下加载完成
 */
- (void) loadMoreCompletedSearch
{
    if (!_isLoadingMoreSearch) return;
    [_indicatroView stopAnimating];
    _isLoadingMoreSearch = NO;
}

#pragma mark - IBAction Methods

- (IBAction)addFinish:(id)sender
{
    [_delegate finishEdit];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  添加或者删除景点
 *
 *  @param sender 
 */
- (IBAction)addPoi:(UIButton *)sender
{
    CGPoint point = [sender convertPoint:CGPointZero toView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
    PoisOfCityTableViewCell *cell = (PoisOfCityTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    PoiSummary *poi;
    if (!cell.isAdded) {
        if (self.searchController.isActive) {
            poi = [self.searchResultArray objectAtIndex:indexPath.row];
        } else {
            poi = [self.dataSource objectAtIndex:indexPath.row];
        }
        [oneDayArray addObject:poi];
        
        [SVProgressHUD showHint:@"已添加"];
        
        self.navigationItem.title = [NSString stringWithFormat:@"第%lu天(%lu安排)", (unsigned long)(_currentDayIndex + 1), (unsigned long)[oneDayArray count]];

    } else {
        
        PoiSummary *poi;
        if (self.searchController.isActive) {
            poi = [self.searchResultArray objectAtIndex:indexPath.row];
        } else {
            poi = [self.dataSource objectAtIndex:indexPath.row];
        }
        NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
        for (PoiSummary *tripPoi in oneDayArray) {
            if ([tripPoi.poiId isEqualToString:poi.poiId]) {
                [oneDayArray removeObject:tripPoi];
                break;
            }
        }
        self.navigationItem.title = [NSString stringWithFormat:@"第%lu天(%lu安排)", (unsigned long)(_currentDayIndex + 1), (unsigned long)[oneDayArray count]];

    }
    cell.isAdded = !cell.isAdded;

}

- (void)filter:(id)sender
{
    if (!self.filterCtl.filterViewIsShowing) {
        typeof(AddPoiViewController *)weakSelf = self;
        [self.filterCtl showFilterViewInViewController:weakSelf.navigationController];
    } else {
        [self.filterCtl hideFilterView];
    }
}

#pragma mark - Private Methods

- (void)loadDataWithPageNo:(NSUInteger)pageNo
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
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    
    NSString *backUrlForCheck = _requestUrl;
    
    //获取列表信息
    [manager GET:_requestUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if ([backUrlForCheck isEqualToString:_requestUrl]) {
                NSArray *jsonDic = [responseObject objectForKey:@"result"];
                if (jsonDic.count == 15) {
                    _enableLoadMoreNormal = YES;
                }
                for (id poiDic in [responseObject objectForKey:@"result"]) {
                    [self.dataSource addObject:[[PoiSummary alloc] initWithJson:poiDic]];
                }
                [self.tableView reloadData];
                _currentPageNormal = pageNo;
            } else {
                NSLog(@"用户切换页面了，我不应该加载数据");
            }
            
            
        } else {
            if (self.isShowing) {
                [SVProgressHUD showHint:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
            }
        }
        [self loadMoreCompletedNormal];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self loadMoreCompletedNormal];
        
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
}

/**
 *  加载搜索的数据
 *
 *  @param pageNo     第几页
 *  @param searchText 搜索关键字
 */
- (void)loadSearchDataWithPageNo:(NSUInteger)pageNo
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:130];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    switch (_currentListTypeIndex) {
        case 0:
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"vs"];
            break;
        case 1:
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"restaurant"];
            break;
        case 2:
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"shopping"];
            break;
        case 3:
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"hotel"];
            break;
        default:
            break;
    }
    CityDestinationPoi *poi = [self.tripDetail.destinations objectAtIndex:_currentCityIndex];
    
    [params setObject:poi.cityId forKey:@"locId"];
    [params setObject:_searchText forKey:@"keyWord"];
    
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(AddPoiViewController *)weakSelf = self;
    [hud showHUDInViewController:weakSelf];
    
    //获取搜索列表信息
    [manager GET:API_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [hud hideTZHUD];
        if (self.searchDisplayController.isActive) {
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0) {
                NSString *key = nil;
                switch (_currentListTypeIndex) {
                    case 0:
                        key = @"vs";
                        break;
                    case 1:
                        key = @"restaurant";
                        break;
                    case 2:
                        key = @"shopping";
                        break;
                    case 3:
                        key = @"hotel";
                        break;
                    default:
                        break;
                }
                NSArray *jsonDic = [[responseObject objectForKey:@"result"] objectForKey:key];
                if (jsonDic.count == 15) {
                    _enableLoadMoreSearch = YES;
                }
                [self.searchResultArray removeAllObjects];
                for (id poiDic in jsonDic) {
                    [self.searchResultArray addObject:[[PoiSummary alloc] initWithJson:poiDic]];
                }
                [self.searchController.searchResultsTableView reloadData];
                _currentPageSearch = pageNo;
            } else {
                if (self.isShowing) {
                    [SVProgressHUD showHint:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
                }
            }
            [self loadMoreCompletedSearch];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [hud hideTZHUD];
        [self loadMoreCompletedSearch];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
}

#pragma mark - TZFilterViewDelegate
- (void)didSelectedItems:(NSArray *)itemIndexPath
{
    NSInteger filterCityIndex = [[itemIndexPath firstObject] integerValue];
    NSInteger filterPoiIndex = [[itemIndexPath lastObject] integerValue];
    if (_currentListTypeIndex != filterPoiIndex) {
        _isLoadingMoreNormal = YES;
        _didEndScrollNormal = YES;
        _enableLoadMoreNormal = NO;
        _currentListTypeIndex = filterPoiIndex;
        CityDestinationPoi *poi = [self.tripDetail.destinations objectAtIndex:_currentCityIndex];
        _requestUrl = [NSString stringWithFormat:@"%@%@", _urlArray[_currentListTypeIndex], poi.cityId];
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
        _currentPageNormal = 0;
        [self loadDataWithPageNo:_currentPageNormal];
        
    }
    
    if (_currentCityIndex != filterCityIndex) {
        _isLoadingMoreNormal = YES;
        _didEndScrollNormal = YES;
        _enableLoadMoreNormal = NO;
        _currentCityIndex = filterCityIndex;
        CityDestinationPoi *poi = [self.tripDetail.destinations objectAtIndex:_currentCityIndex];
        _requestUrl = [NSString stringWithFormat:@"%@%@", _urlArray[_currentListTypeIndex], poi.cityId];
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
        _currentPageNormal = 0;
        [self loadDataWithPageNo:_currentPageNormal];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.tableView]) {
        return self.dataSource.count;
    } else if ([tableView isEqual:self.searchController.searchResultsTableView]) {
        return self.searchResultArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 190.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PoiSummary *poi;
    if ([tableView isEqual:self.tableView]) {
        poi = [self.dataSource objectAtIndex:indexPath.row];
    } else {
        poi = [self.searchResultArray objectAtIndex:indexPath.row];
    }
    BOOL isAdded = NO;
    NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    for (PoiSummary *tripPoi in oneDayArray) {
        if ([tripPoi.poiId isEqualToString:poi.poiId]) {
            isAdded = YES;
        }
    }
    
    PoisOfCityTableViewCell *poiCell = [tableView dequeueReusableCellWithIdentifier:addRestaurantCellIndentifier forIndexPath:indexPath];
    poiCell.poi = poi;
    poiCell.actionBtn.tag = indexPath.row;
    poiCell.shouldEdit = _shouldEdit;
    if (_shouldEdit) {
        poiCell.isAdded = isAdded;
        [poiCell.actionBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        poiCell.hideActionBtn = YES;
    }
    
    return poiCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PoiSummary *tripPoi;
    if ([tableView isEqual:self.tableView]) {
       tripPoi = [self.dataSource objectAtIndex:indexPath.row];
    } else {
        tripPoi = [self.searchResultArray objectAtIndex:indexPath.row];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (tripPoi.poiType) {
        case kSpotPoi: {
            SpotDetailViewController *spotDetailCtl = [[SpotDetailViewController alloc] init];
            spotDetailCtl.spotId = tripPoi.poiId;
            [self addChildViewController:spotDetailCtl];
            [self.view addSubview:spotDetailCtl.view];
            
        }
            break;
        case kRestaurantPoi: {
            CommonPoiDetailViewController *restaurantDetailCtl = [[CommonPoiDetailViewController alloc] init];
            restaurantDetailCtl.poiId = tripPoi.poiId;
            restaurantDetailCtl.poiType = kRestaurantPoi;
            [self addChildViewController:restaurantDetailCtl];
            [self.view addSubview:restaurantDetailCtl.view];
        }
            
            break;
        case kShoppingPoi: {
            CommonPoiDetailViewController *shoppingDetailCtl = [[CommonPoiDetailViewController alloc] init];
            shoppingDetailCtl.poiId = tripPoi.poiId;
            shoppingDetailCtl.poiType = kShoppingPoi;
            [self addChildViewController:shoppingDetailCtl];
            [self.view addSubview:shoppingDetailCtl.view];
        }
            
            break;
        case kHotelPoi: {
            CommonPoiDetailViewController *hotelDetailCtl = [[CommonPoiDetailViewController alloc] init];
            hotelDetailCtl.poiId = tripPoi.poiId;
            hotelDetailCtl.poiType = kHotelPoi;
            [self addChildViewController:hotelDetailCtl];
            [self.view addSubview:hotelDetailCtl.view];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - SearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchResultArray removeAllObjects];
    _searchText = nil;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    _currentPageSearch = 0;
    _searchText = searchBar.text;
    [self loadSearchDataWithPageNo:_currentPageSearch];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    _isLoadingMoreSearch = YES;
    _didEndScrollSearch = YES;
    _enableLoadMoreSearch = NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    [self.searchResultArray removeAllObjects];
    [self.searchController.searchResultsTableView reloadData];
    [self.tableView reloadData];
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.tableView]) {
        if (!_isLoadingMoreNormal && _didEndScrollNormal && _enableLoadMoreNormal) {
            CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
            if (scrollPosition < 44.0) {
                _didEndScrollNormal = NO;
                [self beginLoadingMoreNormal];
            }
        }
    } else if ([scrollView isEqual:self.searchController.searchResultsTableView]) {
        if (!_isLoadingMoreSearch && _didEndScrollSearch && _enableLoadMoreSearch) {
            CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
            if (scrollPosition < 44.0) {
                _didEndScrollSearch = NO;
                [self beginLoadingSearch];
            }
        }
        
    }
    
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.tableView]) {
        _didEndScrollNormal = YES;
    } else if ([scrollView isEqual:self.searchController.searchResultsTableView]) {
        _didEndScrollSearch = YES;
    }
    
}

@end
