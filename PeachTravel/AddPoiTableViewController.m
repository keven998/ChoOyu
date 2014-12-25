//
//  AddPoiTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "AddPoiTableViewController.h"
#import "AddSpotTableViewCell.h"
#import "SINavigationMenuView.h"
#import "CityDestinationPoi.h"
#import "TripDetail.h"
#import "AddHotelTableViewCell.h"
#import "SpotDetailViewController.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"
#import "PoiSummary.h"
#import "PoisOfCityTableViewCell.h"


@interface AddPoiTableViewController () <SINavigationMenuDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSUInteger currentListTypeIndex;
@property (nonatomic) NSUInteger currentCityIndex;
@property (nonatomic, strong) NSArray *urlArray;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic) NSUInteger currentPage;

@property (nonatomic, strong) SINavigationMenuView *sortPoiView;
@property (nonatomic, strong) SINavigationMenuView *sortCityView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;

@property (nonatomic, copy) NSString *requestUrl;

@property (nonatomic, strong) NSMutableArray *searchResultArray;


@end

@implementation AddPoiTableViewController

static NSString *addSpotCellIndentifier = @"addSpotCell";
static NSString *addRestaurantCellIndentifier = @"poisOfCity";
static NSString *addShoppingCellIndentifier = @"poisOfCity";
static NSString *addHotelCellIndentifier = @"addHotelCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _urlArray = @[API_GET_SPOTLIST_CITY, API_GET_RESTAURANTSLIST_CITY, API_GET_SHOPPINGLIST_CITY, API_GET_HOTELLIST_CITY];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"AddSpotTableViewCell" bundle:nil] forCellReuseIdentifier:addSpotCellIndentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:addRestaurantCellIndentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"AddHotelTableViewCell" bundle:nil] forCellReuseIdentifier:addHotelCellIndentifier];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.tableHeaderView = self.searchBar;
    
    UIButton *finishBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    finishBtn.layer.cornerRadius = 2.0;
    finishBtn.layer.borderColor = APP_THEME_COLOR.CGColor;
    finishBtn.layer.borderWidth = 1.0;
    [finishBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(addFinish:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barItem1 = [[UIBarButtonItem alloc] initWithCustomView:self.sortPoiView];
    UIBarButtonItem *barItem2 = [[UIBarButtonItem alloc] initWithCustomView:finishBtn];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.sortCityView];
    self.navigationItem.rightBarButtonItems = @[barItem2, barItem1];
    CityDestinationPoi *firstDestination = [_tripDetail.destinations firstObject];
    _requestUrl = [NSString stringWithFormat:@"%@%@", API_GET_SPOTLIST_CITY ,firstDestination.cityId];
    
    _currentPage = 0;
    [SVProgressHUD show];
    [self loadDataWithPageNo:_currentPage];
//    [SVProgressHUD show];
}


#pragma mark - setter & getter

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(20, 20, self.view.bounds.size.width-40, 38)];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.delegate = self;
        [_searchBar setPlaceholder:@"搜索好玩 好吃 好住"];
        _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _searchBar.translucent = YES;
        _searchController = [[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
        _searchController.active = NO;
        _searchController.searchResultsDataSource = self;
        _searchController.searchResultsDelegate = self;

    }
    return _searchBar;
}

- (NSMutableArray *)searchResultArray
{
    if (!_searchResultArray) {
        _searchResultArray = [[NSMutableArray alloc] init];
    }
    return _searchResultArray;
}

- (SINavigationMenuView *)sortPoiView
{
    if (!_sortPoiView) {
        CGRect frame = CGRectMake(0, 0, 50, 30);
        _sortPoiView = [[SINavigationMenuView alloc] initWithFrame:frame withImage:@"ic_nav_filter_normal.png"];
        [_sortPoiView displayMenuInView:self.navigationController.view];
        _sortPoiView.items = @[@"景点", @"美食", @"购物", @"酒店"];
        _sortPoiView.delegate = self;
    }
    return _sortPoiView;
}

- (SINavigationMenuView *)sortCityView
{
    if (!_sortCityView) {
        CGRect frame = CGRectMake(0, 0, 50, 30);
        NSMutableArray *titiles = [[NSMutableArray alloc] init];
        for (CityDestinationPoi *poi in _tripDetail.destinations) {
            [titiles addObject:poi.zhName];
        }
        _sortCityView = [[SINavigationMenuView alloc] initWithFrame:frame title:[titiles firstObject]];
        [_sortCityView displayMenuInView:self.navigationController.view];
        _sortCityView.items = titiles;
        _sortCityView.delegate = self;
    }
    return _sortCityView;
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
    TripPoi *poi = [self.dataSource objectAtIndex:sender.tag];
    [oneDayArray addObject:poi];
    [_delegate finishEdit];
    NSIndexPath *path = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)deletePoi:(UIButton *)sender
{
    TripPoi *poi = [self.dataSource objectAtIndex:sender.tag];
    NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    for (TripPoi *tripPoi in oneDayArray) {
        if ([tripPoi.poiId isEqualToString:poi.poiId]) {
            [oneDayArray removeObject:tripPoi];
            break;
        }
    }
    NSIndexPath *path = [NSIndexPath indexPathForItem:sender.tag inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    
    //获取列表信息
    [manager GET:_requestUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            for (id poiDic in [responseObject objectForKey:@"result"]) {
                [self.dataSource addObject:[[TripPoi alloc] initWithJson:poiDic]];
                [self.tableView reloadData];
            }
            _currentPage = pageNo;
        } else {
//            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
            [SVProgressHUD showHint:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        [self loadMoreCompleted];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
//        [SVProgressHUD dismiss];
        [SVProgressHUD showHint:@"呃～好像没找到网络"];
    }];
}

/**
 *  实现父类加载更多的方法
 */
- (void)beginLoadingMore {
    [super beginLoadingMore];
    [self loadDataWithPageNo:_currentPage+1];
}


#pragma mark - SINavigationMenuDelegate

- (void)didSelectItemAtIndex:(NSUInteger)index withSender:(id)sender
{
    if ([sender isEqual:self.sortPoiView]) {
        if (_currentListTypeIndex != index) {
            _currentListTypeIndex = index;
            CityDestinationPoi *poi = [self.tripDetail.destinations objectAtIndex:_currentCityIndex];
            _requestUrl = [NSString stringWithFormat:@"%@%@", _urlArray[_currentListTypeIndex], poi.cityId];
            [self.sortPoiView setTitle:[self.sortPoiView.items objectAtIndex:index]];
            [self.dataSource removeAllObjects];
            [self.tableView reloadData];
            _currentPage = 0;
            [self loadDataWithPageNo:_currentPage];
        }
        
    } else {
        if (_currentCityIndex != index) {
            _currentCityIndex = index;
            CityDestinationPoi *poi = [self.tripDetail.destinations objectAtIndex:_currentCityIndex];
            _requestUrl = [NSString stringWithFormat:@"%@%@", _urlArray[_currentListTypeIndex], poi.cityId];
            [self.sortCityView setTitle:[self.sortCityView.items objectAtIndex:index]];
            [self.dataSource removeAllObjects];
            [self.tableView reloadData];
            _currentPage = 0;
            [self loadDataWithPageNo:_currentPage];
        }
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.tableView]) {
        return self.dataSource.count;
    } else {
        return self.searchResultArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 138.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TripPoi *poi = [self.dataSource objectAtIndex:indexPath.row];
    BOOL isAdded = NO;
    NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    for (TripPoi *tripPoi in oneDayArray) {
        if ([tripPoi.poiId isEqualToString:poi.poiId]) {
            isAdded = YES;
        }
    }
    
    if (poi.poiType == TripSpotPoi) {
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
    
    if (poi.poiType == TripRestaurantPoi || poi.poiType == TripShoppingPoi) {
        PoiSummary *restaurantPoi = [[PoiSummary alloc] init];
        restaurantPoi.poiId = poi.poiId;
        restaurantPoi.zhName = poi.zhName;
        restaurantPoi.enName = poi.enName;
        restaurantPoi.desc = poi.desc;
        restaurantPoi.priceDesc = poi.priceDesc;
        restaurantPoi.commentCount = 0;
        restaurantPoi.telephone = poi.telephone;
        restaurantPoi.images = poi.images;
        
        PoisOfCityTableViewCell *restaurantCell = [tableView dequeueReusableCellWithIdentifier:addRestaurantCellIndentifier forIndexPath:indexPath];
        restaurantCell.poi = restaurantPoi;
        restaurantCell.actionBtn.tag = indexPath.row;
        [restaurantCell.actionBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        return restaurantCell;
    }

    if (poi.poiType == TripHotelPoi) {
        AddHotelTableViewCell *addHotelCell = [tableView dequeueReusableCellWithIdentifier:addHotelCellIndentifier forIndexPath:indexPath];
        addHotelCell.tripPoi = poi;
        addHotelCell.addBtn.tag = indexPath.row;
        [addHotelCell.addBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        return addHotelCell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TripPoi *tripPoi = [self.dataSource objectAtIndex:indexPath.row];
    switch (tripPoi.poiType) {
        case TripSpotPoi: {
            SpotDetailViewController *spotDetailCtl = [[SpotDetailViewController alloc] init];
            spotDetailCtl.spotId = tripPoi.poiId;
            [self.navigationController pushViewController:spotDetailCtl animated:YES];
        }
            break;
        case TripRestaurantPoi: {
            RestaurantDetailViewController *restaurantDetailCtl = [[RestaurantDetailViewController alloc] init];
            restaurantDetailCtl.restaurantId = tripPoi.poiId;
            [self.navigationController pushViewController:restaurantDetailCtl animated:YES];
        }
            
            break;
        case TripShoppingPoi: {
            ShoppingDetailViewController *shoppingDetailCtl = [[ShoppingDetailViewController alloc] init];
            shoppingDetailCtl.shoppingId = tripPoi.poiId;
            [self.navigationController pushViewController:shoppingDetailCtl animated:YES];
        }
            
            break;
        case TripHotelPoi:
            
            break;
            
        default:
            break;
    }
}

@end
