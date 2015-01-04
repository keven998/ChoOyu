//
//  PoisOfCityViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "PoisOfCityTableViewController.h"
#import "PoisOfCityTableViewCell.h"
#import "TZFilterViewController.h"
#import "CityDestinationPoi.h"
#import "PoiSummary.h"
#import "RecommendsOfCity.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"
#import "PoiSummary.h"
#import "SuperWebViewController.h"

@interface PoisOfCityTableViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, TZFilterViewDelegate>

@property (nonatomic, strong) UIButton *rightItemBtn;
@property (nonatomic, strong) RecommendsOfCity *dataSource;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchController;
@property (nonatomic, strong) UIActivityIndicatorView *indicatroView;
@property (nonatomic, strong) UIView *footerView;
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

@implementation PoisOfCityTableViewController

static NSString *poisOfCityCellIdentifier = @"poisOfCity";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:poisOfCityCellIdentifier];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self.searchController.searchResultsTableView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:poisOfCityCellIdentifier];
    self.searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchController.searchResultsTableView.backgroundColor = APP_PAGE_COLOR;
    
    _searchBar.delegate = self;
    _searchController.searchResultsTableView.delegate = self;
    _searchController.searchResultsTableView.dataSource = self;
    if (self.tripDetail.destinations.count > 1) {
        UIBarButtonItem * filterBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(filter:)];
        self.navigationItem.rightBarButtonItem = filterBtn;
        [filterBtn setImage:[UIImage imageNamed:@"ic_nav_filter_normal.png"]];
        CityDestinationPoi *destination = [self.tripDetail.destinations firstObject];
        _zhName = destination.zhName;
        _cityId = destination.cityId;

    } else {
        self.navigationItem.title = _zhName;
    }
    
    if (self.shouldEdit) {
        UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(finishAdd:)];
        leftBtn.tintColor = APP_THEME_COLOR;
        self.navigationItem.leftBarButtonItem = leftBtn;
    }
    NSString *searchPlaceHolder;
    if (_poiType == kRestaurantPoi) {
        searchPlaceHolder = @"请输入美食名字";
    }
    if (_poiType == kShoppingPoi) {
        searchPlaceHolder = @"请输入购物名字";
    }
    _currentPageNormal = 0;
    [self loadIntroductionOfCity];
}

#pragma mark - setter & getter

- (RecommendsOfCity *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[RecommendsOfCity alloc] init];
    }
    return _dataSource;
}

- (NSMutableArray *)searchResultArray
{
    if (!_searchResultArray) {
        _searchResultArray = [[NSMutableArray alloc] init];
    }
    return _searchResultArray;
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

- (TZFilterViewController *)filterCtl
{
    if (!_filterCtl) {
        _filterCtl = [[TZFilterViewController alloc] init];
        NSMutableArray *titiles = [[NSMutableArray alloc] init];
        for (CityDestinationPoi *poi in _tripDetail.destinations) {
            [titiles addObject:poi.zhName];
        }
        _filterCtl.filterTitles = @[@"城市"];
        _filterCtl.lineCountPerFilterType = @[@2];
        _filterCtl.selectedItmesIndex = @[@0];
        _filterCtl.filterItemsArray = @[titiles];
        _filterCtl.delegate = self;
    }
    return _filterCtl;
}

#pragma mark - Private Methods

- (void)loadIntroductionOfCity
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *requsetUrl;
    if (_poiType == kRestaurantPoi) {
        requsetUrl = [NSString stringWithFormat:@"%@%@/restaurant", API_GET_GUIDE_CITY,_cityId];
        
    }
    if (_poiType == kShoppingPoi) {
        requsetUrl = [NSString stringWithFormat:@"%@%@/shopping", API_GET_GUIDE_CITY,_cityId];
    }
    
    //获取城市的美食列表信息
    [manager GET:requsetUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            self.dataSource = [[RecommendsOfCity alloc] initWithJson:[responseObject objectForKey:@"result"]];
            
            [self loadDataPoisOfCity:_currentPageNormal];
        } else {
            [self showHint:@"呃～好像没找到网络"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showHint:@"呃～好像没找到网络"];
    }];
}
/**
 *  加载城市的poi列表
 *
 *  @param pageNO
 */
- (void)loadDataPoisOfCity:(NSUInteger)pageNO
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *requsetUrl;
    if (_poiType == kRestaurantPoi) {
        requsetUrl = [NSString stringWithFormat:@"%@%@", API_GET_RESTAURANTSLIST_CITY,_cityId];
        
    }
    if (_poiType == kShoppingPoi) {
        requsetUrl = [NSString stringWithFormat:@"%@%@", API_GET_SHOPPINGLIST_CITY,_cityId];
    }
    
    //加载之前备份一个城市的 id 与从网上取完数据后的 id 对比，如果不一致说明用户切换了城市
    NSString *backUpCityId = _cityId;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInteger:pageNO] forKey:@"page"];
    
    //获取城市的美食.购物列表信息
    [manager GET:requsetUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self loadMoreCompletedNormal];
        if ([backUpCityId isEqualToString:_cityId]) {
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0) {
                NSArray *jsonDic = [responseObject objectForKey:@"result"];
                if (jsonDic.count == 15) {
                    _enableLoadMoreNormal = YES;
                }
                [self.dataSource addRecommendList:jsonDic];
                [self updateView];
                _currentPageNormal = pageNO;
                if (_dataSource.recommendList.count >= 15) {
                    
                } else if (pageNO > 0){
                    [self showHint:@"没有了,别强求~"];
                }
            } else {
                [self showHint:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self loadMoreCompletedNormal];
        [self showHint:@"呃～好像没找到网络"];
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
    switch (_poiType) {
        case kRestaurantPoi:
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"restaurant"];
            break;
        case kShoppingPoi:
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"shopping"];
            break;
        default:
            break;
    }
    
    [params setObject:_cityId forKey:@"locId"];
    [params setObject:_searchText forKey:@"keyWord"];
    [SVProgressHUD show];
    
    //获取搜索列表信息
    [manager GET:API_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if (self.searchDisplayController.isActive) {
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0) {
                NSString *key = nil;
                switch (_poiType) {
                    case kRestaurantPoi:
                        key = @"restaurant";
                        break;
                    case kShoppingPoi:
                        key = @"shopping";
                        break;
                   
                    default:
                        break;
                }
                NSArray *jsonDic = [[responseObject objectForKey:@"result"] objectForKey:key];
                if (jsonDic.count == 15) {
                    _enableLoadMoreSearch = YES;
                }
                for (id poiDic in jsonDic) {
                    [self.searchResultArray addObject:[[PoiSummary alloc] initWithJson:poiDic]];
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

- (void)updateView
{
    [self.tableView reloadData];
}

- (void)filter:(id)sender
{
    if (!self.filterCtl.filterViewIsShowing) {
        typeof(PoisOfCityTableViewController *)weakSelf = self;
        [self.filterCtl showFilterViewInViewController:weakSelf.navigationController];
    } else {
        [self.filterCtl hideFilterView];
    }
}


#pragma mark - IBAction Methods

/**
 *  添加一个 poi
 *
 *  @param sender
 */
- (IBAction)addPoi:(UIButton *)sender
{
    TripPoi *tripPoi = [[TripPoi alloc] init];
    PoiSummary *restaurantPoi = [_dataSource.recommendList objectAtIndex:sender.tag];
    tripPoi.poiId = restaurantPoi.poiId;
    tripPoi.zhName = restaurantPoi.zhName;
    tripPoi.enName = restaurantPoi.enName;
    tripPoi.images = restaurantPoi.images;
    tripPoi.priceDesc = restaurantPoi.priceDesc;
    tripPoi.desc = restaurantPoi.desc;
    tripPoi.address = restaurantPoi.address;
    tripPoi.poiType = kRestaurantPoi;
    [self.tripDetail.restaurantsList addObject:tripPoi];
}

/**
 *  导航
 *
 *  @param sender
 */
- (IBAction)viewMap:(UIButton *)sender
{
    
}

- (IBAction)finishAdd:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [_delegate finishEdit];
}

- (IBAction)showMoreCities:(UIButton *)sender
{
}

- (IBAction)chat:(id)sender
{
    
}

- (IBAction)jumpToCommentList:(id)sender
{
    //TODO:进入评论列表
}

- (void)showIntruductionOfCity
{
    NSString *requsetUrl;
    if (_poiType == kRestaurantPoi) {
        requsetUrl = [NSString stringWithFormat:@"%@%@", RESTAURANT_CITY_HTML,_cityId];
        
    }
    if (_poiType == kShoppingPoi) {
        requsetUrl = [NSString stringWithFormat:@"%@%@", SHOPPING_CITY_HTML,_cityId];
    }
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    webCtl.urlStr = requsetUrl;
    webCtl.titleStr = _zhName;
    [self.navigationController pushViewController:webCtl animated:YES];
}

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
    [self loadDataPoisOfCity:(_currentPageNormal + 1)];
    
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

#pragma mark - TZFilterViewDelegate
-(void)didSelectedItems:(NSArray *)itemIndexPath
{
    CityDestinationPoi *destination = [self.tripDetail.destinations objectAtIndex:[[itemIndexPath firstObject] integerValue]];
    _cityId = destination.cityId;
    _zhName = destination.zhName;
    [_dataSource.recommendList removeAllObjects];
    _currentPageNormal = 0;
    [self.tableView reloadData];
    [self loadIntroductionOfCity];

}


#pragma mark - UITableViewDataSource & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![tableView isEqual:self.tableView]) {
        return self.searchResultArray.count;
    }
    if (![_dataSource.desc isBlankString]) {
        if (section == 0) {
            return 0;
        } else {
            return _dataSource.recommendList.count;
        }
    }
    return _dataSource.recommendList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (![tableView isEqual:self.tableView]) {
        return 1;
    }
    if (!_dataSource) {
        return 0;
    }
    if (![_dataSource.desc isBlankString]) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PoiSummary *poi = [_dataSource.recommendList objectAtIndex:indexPath.row];
    if ([poi.comments count]) {
        return 187.0;
    }
    return 141;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (![tableView isEqual:self.tableView]) {
        return 0;
    }
    if (![_dataSource.desc isBlankString]) {
        if (section == 0) {
            return 106;
        }
        return 0;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (![_dataSource.desc isBlankString]) {
        if (section == 0) {
            UIView *sectionheaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 106)];
            sectionheaderView.backgroundColor = [UIColor whiteColor];
            UIButton *btn = [[UIButton alloc] initWithFrame:sectionheaderView.frame];
            [btn setTitleColor:TEXT_COLOR_TITLE_SUBTITLE forState:UIControlStateNormal];
            [btn setAttributedTitle:[_dataSource.desc  stringByAddLineSpacingAndTextColor:TEXT_COLOR_TITLE_SUBTITLE]forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(showIntruductionOfCity) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = [UIFont systemFontOfSize:12.0];
            btn.titleLabel.numberOfLines = 4;
            [btn setContentEdgeInsets:UIEdgeInsetsMake(8, 15, 8, 50)];
            UIImageView *accessImageView = [[UIImageView alloc] initWithFrame:CGRectMake(sectionheaderView.frame.size.width-25, (sectionheaderView.frame.size.height-10)/2, 6, 10)];
            accessImageView.image = [UIImage imageNamed:@"cell_accessory_pink.png"];
            [sectionheaderView addSubview:accessImageView];
            [sectionheaderView addSubview:btn];
            return sectionheaderView;
        }
        return nil;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PoiSummary *poi ;
    if (![tableView isEqual:self.tableView]) {
        poi = [self.searchResultArray objectAtIndex:indexPath.row];
    } else {
        poi = [_dataSource.recommendList objectAtIndex:indexPath.row];
    }
    PoisOfCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:poisOfCityCellIdentifier];
    cell.shouldEdit = _shouldEdit;
    if (_shouldEdit) {
        [cell.actionBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [cell.actionBtn addTarget:self action:@selector(viewMap:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.poi = poi;
    cell.actionBtn.tag = indexPath.row;
    cell.jumpCommentBtn.tag = indexPath.row;
    [cell.jumpCommentBtn addTarget:self action:@selector(jumpToCommentList:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PoiSummary *poi = [_dataSource.recommendList objectAtIndex:indexPath.row];
    if (_poiType == kRestaurantPoi) {
        RestaurantDetailViewController *restaurantDetailCtl = [[RestaurantDetailViewController alloc] init];
        restaurantDetailCtl.restaurantId = poi.poiId;
        [self.navigationController pushViewController:restaurantDetailCtl animated:YES];
    }
    if (_poiType == kShoppingPoi) {
        ShoppingDetailViewController *shoppingDetailCtl = [[ShoppingDetailViewController alloc] init];
        shoppingDetailCtl.shoppingId = poi.poiId;
        [self.navigationController pushViewController:shoppingDetailCtl animated:YES];
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
