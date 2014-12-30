//
//  AddPoiTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "AddPoiTableViewController.h"
#import "AddSpotTableViewCell.h"
#import "CityDestinationPoi.h"
#import "TripDetail.h"
#import "SpotDetailViewController.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"
#import "HotelDetailViewController.h"
#import "PoiSummary.h"
#import "PoisOfCityTableViewCell.h"
#import "TZFilterViewController.h"


@interface AddPoiTableViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, TZFilterViewDelegate, UISearchDisplayDelegate>

@property (nonatomic) NSUInteger currentListTypeIndex;
@property (nonatomic) NSUInteger currentCityIndex;
@property (nonatomic, strong) NSArray *urlArray;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchController;
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

@implementation AddPoiTableViewController

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
    self.navigationItem.title = @"添加想去";

    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
    _urlArray = @[API_GET_SPOTLIST_CITY, API_GET_RESTAURANTSLIST_CITY, API_GET_SHOPPINGLIST_CITY, API_GET_HOTELLIST_CITY];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AddSpotTableViewCell" bundle:nil] forCellReuseIdentifier:addSpotCellIndentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:addRestaurantCellIndentifier];
    [self.searchController.searchResultsTableView registerNib:[UINib nibWithNibName:@"AddSpotTableViewCell" bundle:nil] forCellReuseIdentifier:addSpotCellIndentifier];
    [self.searchController.searchResultsTableView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:addRestaurantCellIndentifier];
    self.searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchController.searchResultsTableView.backgroundColor = APP_PAGE_COLOR;
    self.searchController.searchResultsTableView.dataSource = self;
    self.searchController.searchResultsTableView.delegate = self;

    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    
    UIButton *finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    [finishBtn setImage:[UIImage imageNamed:@"ic_cell_item_chooesed.png"] forState:UIControlStateNormal];
    finishBtn.layer.cornerRadius = 2.0;
    finishBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    finishBtn.layer.borderColor = APP_THEME_COLOR.CGColor;
    finishBtn.layer.borderWidth = 1.0;
    [finishBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(addFinish:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:finishBtn];
    
    UIBarButtonItem * filterBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(filter:)];
    self.navigationItem.leftBarButtonItem = filterBtn;
    [filterBtn setImage:[UIImage imageNamed:@"ic_nav_filter_normal.png"]];
    
    CityDestinationPoi *firstDestination = [_tripDetail.destinations firstObject];
    _requestUrl = [NSString stringWithFormat:@"%@%@", API_GET_SPOTLIST_CITY ,firstDestination.cityId];
    
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addPoi:(UIButton *)sender
{
    NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    TripPoi *poi;
    if (self.searchController.isActive) {
        poi = [self.searchResultArray objectAtIndex:sender.tag];
    } else {
        poi = [self.dataSource objectAtIndex:sender.tag];
    }
    [oneDayArray addObject:poi];
    [_delegate finishEdit];
    NSIndexPath *path = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    if (self.searchController.isActive) {
        [self.searchController.searchResultsTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (IBAction)deletePoi:(UIButton *)sender
{
    TripPoi *poi;
    if (self.searchController.isActive) {
        poi = [self.searchResultArray objectAtIndex:sender.tag];
    } else {
        poi = [self.dataSource objectAtIndex:sender.tag];
    }
    NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    for (TripPoi *tripPoi in oneDayArray) {
        if ([tripPoi.poiId isEqualToString:poi.poiId]) {
            [oneDayArray removeObject:tripPoi];
            break;
        }
    }
    NSIndexPath *path = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    if (self.searchController.isActive) {
        [self.searchController.searchResultsTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)filter:(id)sender
{
    if (!self.filterCtl.filterViewIsShowing) {
        typeof(AddPoiTableViewController *)weakSelf = self;
        [self.filterCtl showFilterViewInViewController:weakSelf.navigationController];
    } else {
        [self.filterCtl hideFilterView];
    }
}

#pragma mark - Private Methods

- (void)loadDataWithPageNo:(NSUInteger)pageNo
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
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
                    [self.dataSource addObject:[[TripPoi alloc] initWithJson:poiDic]];
                }
                [self.tableView reloadData];
                _currentPageNormal = pageNo;
            } else {
                NSLog(@"用户切换页面了，我不应该加载数据");
            }
            
            [SVProgressHUD dismiss];
        } else {
            [SVProgressHUD showHint:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        [self loadMoreCompletedNormal];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self loadMoreCompletedNormal];

        [SVProgressHUD showHint:@"呃～好像没找到网络"];
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
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
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
    [SVProgressHUD show];
    
    //获取搜索列表信息
    [manager GET:API_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [SVProgressHUD dismiss];
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
                for (id poiDic in jsonDic) {
                    [self.searchResultArray addObject:[[TripPoi alloc] initWithJson:poiDic]];
                }
                [self.searchController.searchResultsTableView reloadData];
                _currentPageSearch = pageNo;
            } else {
                [SVProgressHUD showHint:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
            }
            [self loadMoreCompletedSearch];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self loadMoreCompletedSearch];
        [SVProgressHUD showHint:@"呃～好像没找到网络"];
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
    return 138.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TripPoi *poi;
    if ([tableView isEqual:self.tableView]) {
        poi = [self.dataSource objectAtIndex:indexPath.row];
    } else {
        poi = [self.searchResultArray objectAtIndex:indexPath.row];
    }
    BOOL isAdded = NO;
    NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    for (TripPoi *tripPoi in oneDayArray) {
        if ([tripPoi.poiId isEqualToString:poi.poiId]) {
            isAdded = YES;
        }
    }
    
    if (poi.poiType == kSpotPoi) {
        AddSpotTableViewCell *addSpotCell = [tableView dequeueReusableCellWithIdentifier:addSpotCellIndentifier];
        addSpotCell.tripPoi = poi;
        addSpotCell.shouldEdit = YES;
        addSpotCell.isAdded = isAdded;
        addSpotCell.addBtn.tag = indexPath.row;
        if (isAdded) {
            [addSpotCell.addBtn removeTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
            [addSpotCell.addBtn addTarget:self action:@selector(deletePoi:) forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            [addSpotCell.addBtn removeTarget:self action:@selector(deletePoi:) forControlEvents:UIControlEventTouchUpInside];
            [addSpotCell.addBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        }
        return addSpotCell;
    }
    
    if (poi.poiType == kRestaurantPoi || poi.poiType == kShoppingPoi || poi.poiType == kHotelPoi) {
        PoiSummary *poiSummary = [[PoiSummary alloc] init];
        poiSummary.poiId = poi.poiId;
        poiSummary.zhName = poi.zhName;
        poiSummary.enName = poi.enName;
        poiSummary.desc = poi.desc;
        poiSummary.priceDesc = poi.priceDesc;
        poiSummary.commentCount = 0;
        poiSummary.telephone = poi.telephone;
        poiSummary.images = poi.images;
        poiSummary.rating = poi.rating;
        PoisOfCityTableViewCell *poiCell = [tableView dequeueReusableCellWithIdentifier:addRestaurantCellIndentifier forIndexPath:indexPath];
        poiCell.poi = poiSummary;
        poiCell.actionBtn.tag = indexPath.row;
        poiCell.isAdded = isAdded;
        if (isAdded) {
            [poiCell.actionBtn removeTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
            [poiCell.actionBtn addTarget:self action:@selector(deletePoi:) forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            [poiCell.actionBtn removeTarget:self action:@selector(deletePoi:) forControlEvents:UIControlEventTouchUpInside];
            [poiCell.actionBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        }

        return poiCell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TripPoi *tripPoi = [self.dataSource objectAtIndex:indexPath.row];
    switch (tripPoi.poiType) {
        case kSpotPoi: {
            SpotDetailViewController *spotDetailCtl = [[SpotDetailViewController alloc] init];
            spotDetailCtl.spotId = tripPoi.poiId;
            [self.navigationController pushViewController:spotDetailCtl animated:YES];
        }
            break;
        case kRestaurantPoi: {
            RestaurantDetailViewController *restaurantDetailCtl = [[RestaurantDetailViewController alloc] init];
            restaurantDetailCtl.restaurantId = tripPoi.poiId;
            [self.navigationController pushViewController:restaurantDetailCtl animated:YES];
        }
            
            break;
        case kShoppingPoi: {
            ShoppingDetailViewController *shoppingDetailCtl = [[ShoppingDetailViewController alloc] init];
            shoppingDetailCtl.shoppingId = tripPoi.poiId;
            [self.navigationController pushViewController:shoppingDetailCtl animated:YES];
        }
            
            break;
        case kHotelPoi: {
            HotelDetailViewController *hotelDetailCtl = [[HotelDetailViewController alloc] init];
            hotelDetailCtl.hotelId = tripPoi.poiId;
            [self.navigationController pushViewController:hotelDetailCtl animated:YES];
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
