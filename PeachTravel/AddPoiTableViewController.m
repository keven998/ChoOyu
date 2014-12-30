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
@property (nonatomic, assign) BOOL didEndScrollNormalSearch;
@property (nonatomic, assign) BOOL enableLoadMoreNormalSearch;

@property (nonatomic, copy) NSString *searchText;

@end

@implementation AddPoiTableViewController

static NSString *addSpotCellIndentifier = @"addSpotCell";
static NSString *addRestaurantCellIndentifier = @"poisOfCity";
static NSString *addShoppingCellIndentifier = @"poisOfCity";

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
    
    _currentPageNormal = 0;
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
    [params setObject:[NSNumber numberWithInt:pageNo] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    
    NSString *backUrlForCheck = _requestUrl;
    [SVProgressHUD show];
    
    //获取列表信息
    [manager GET:_requestUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if ([backUrlForCheck isEqualToString:_requestUrl]) {
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
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
    [params setObject:[NSNumber numberWithInt:pageNo] forKey:@"page"];
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
                for (id poiDic in [[responseObject objectForKey:@"result"] objectForKey:key]) {
                    [self.searchResultArray addObject:[[TripPoi alloc] initWithJson:poiDic]];
                }
                [self.searchController.searchResultsTableView reloadData];
                _currentPageSearch = pageNo;
            } else {
                [SVProgressHUD showHint:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD showHint:@"呃～好像没找到网络"];
    }];
}


#pragma mark - TZFilterViewDelegate
- (void)didSelectedItems:(NSArray *)itemIndexPath
{
    NSInteger filterCityIndex = [[itemIndexPath firstObject] integerValue];
    NSInteger filterPoiIndex = [[itemIndexPath lastObject] integerValue];
    if (_currentListTypeIndex != filterPoiIndex) {
        _currentListTypeIndex = filterPoiIndex;
        CityDestinationPoi *poi = [self.tripDetail.destinations objectAtIndex:_currentCityIndex];
        _requestUrl = [NSString stringWithFormat:@"%@%@", _urlArray[_currentListTypeIndex], poi.cityId];
        [self.dataSource removeAllObjects];
        [self.tableView reloadData];
        _currentPageNormal = 0;
        [self loadDataWithPageNo:_currentPageNormal];
    }
    
    if (_currentCityIndex != filterCityIndex) {
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
    NSLog(@"%@",tableView);
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
            [addSpotCell.addBtn addTarget:self action:@selector(deletePoi:) forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            [addSpotCell.addBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        }
        return addSpotCell;
    }
    
    if (poi.poiType == kRestaurantPoi || poi.poiType == kShoppingPoi || poi.poiType == kHotelPoi) {
        PoiSummary *poi = [[PoiSummary alloc] init];
        poi.poiId = poi.poiId;
        poi.zhName = poi.zhName;
        poi.enName = poi.enName;
        poi.desc = poi.desc;
        poi.priceDesc = poi.priceDesc;
        poi.commentCount = 0;
        poi.telephone = poi.telephone;
        poi.images = poi.images;
        
        PoisOfCityTableViewCell *restaurantCell = [tableView dequeueReusableCellWithIdentifier:addRestaurantCellIndentifier forIndexPath:indexPath];
        restaurantCell.poi = poi;
        restaurantCell.actionBtn.tag = indexPath.row;
        [restaurantCell.actionBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        return restaurantCell;
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
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    [self.searchResultArray removeAllObjects];
    [self.searchController.searchResultsTableView reloadData];
    [self.tableView reloadData];
}



@end
