//
//  PoisOfCityViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "PoisOfCityViewController.h"
#import "PoisOfCityTableViewCell.h"
#import "TZFilterViewController.h"
#import "CityDestinationPoi.h"
#import "PoiSummary.h"
#import "RecommendsOfCity.h"
#import "CommonPoiDetailViewController.h"
#import "ShoppingDetailViewController.h"
#import "PoiSummary.h"
#import "SuperWebViewController.h"

@interface PoisOfCityViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, TZFilterViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIButton *rightItemBtn;
@property (nonatomic, strong) RecommendsOfCity *dataSource;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UISearchDisplayController *searchController;
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

@property (nonatomic, strong) TZProgressHUD *hud;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic) BOOL isShowing;
@end

@implementation PoisOfCityViewController

static NSString *poisOfCityCellIdentifier = @"poisOfCity";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"ic_navigation_back.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 48, 30)];
    //[button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont systemFontOfSize:17.0];
    button.titleEdgeInsets = UIEdgeInsetsMake(2, 1, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.backBarButtonItem = barButton;
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(11, 64, self.view.frame.size.width-22, self.view.frame.size.height-64)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 190.0;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:poisOfCityCellIdentifier];
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];

    [self.searchController.searchResultsTableView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:poisOfCityCellIdentifier];
    self.searchController.searchResultsTableView.backgroundColor = APP_PAGE_COLOR;
    self.searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchController.searchResultsTableView.backgroundColor = APP_PAGE_COLOR;
    _searchController.searchResultsTableView.delegate = self;
    _searchController.searchResultsTableView.dataSource = self;
    
    _searchBar.delegate = self;
    
    if (self.tripDetail) {
        CityDestinationPoi *destination = [self.tripDetail.destinations firstObject];
        _zhName = destination.zhName;
        _cityId = destination.cityId;
        if (self.tripDetail.destinations.count > 1) {
            UIBarButtonItem * filterBtn = [[UIBarButtonItem alloc]initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(filter:)];
            [filterBtn setImage:[UIImage imageNamed:@"ic_nav_filter_normal.png"]];
            self.navigationItem.rightBarButtonItem = filterBtn;
        }
    }
    if (_poiType == kRestaurantPoi) {
        self.navigationItem.title = [NSString stringWithFormat:@"吃在%@", _zhName];
    } else if (_poiType == kShoppingPoi) {
        self.navigationItem.title = [NSString stringWithFormat:@"买在%@", _zhName];
    }
    
    if (self.shouldEdit) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 25)];
        [button setTitle:@"完成" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13.0];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.cornerRadius = 2.0;
        [button addTarget:self action:@selector(finishAdd:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = barButton;
    }
    NSString *searchPlaceHolder;
    if (_poiType == kRestaurantPoi) {
        searchPlaceHolder = @"请输入美食名字";
    } else if (_poiType == kShoppingPoi) {
        searchPlaceHolder = @"请输入购物名字";
    }
    _currentPageNormal = 0;
    
    if (!_shouldEdit) {
        _hud = [[TZProgressHUD alloc] init];
        [_hud showHUD];
        [self loadIntroductionOfCity];
    } else {
        [self loadDataPoisOfCity:_currentPageNormal];
        [SVProgressHUD show];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _isShowing = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _isShowing = NO;
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
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
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager GET:requsetUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            self.dataSource = [[RecommendsOfCity alloc] initWithJson:[responseObject objectForKey:@"result"]];
            [self loadDataPoisOfCity:_currentPageNormal];
        } else {
            //            [self showHint:@"呃～好像没找到网络"];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showHint:@"呃～好像没找到网络"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
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
    NSNumber *imageWidth = [NSNumber numberWithInt:130];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInteger:pageNO] forKey:@"page"];
    
    //获取城市的美食.购物列表信息
    [manager GET:requsetUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_hud) {
            [_hud hideTZHUD];
            _hud = nil;
        }
        [SVProgressHUD dismiss];
        [self loadMoreCompletedNormal];
        if ([backUpCityId isEqualToString:_cityId]) {
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0) {
                NSArray *jsonDic = [responseObject objectForKey:@"result"];
                if (jsonDic.count == 15) {
                    _enableLoadMoreNormal = YES;
                } else if (jsonDic.count == 0) {
                    [self showHint:@"没有了~"];
                }
                [self.dataSource addRecommendList:jsonDic];
                [self updateView];
                _currentPageNormal = pageNO;
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        if (_hud) {
            [_hud hideTZHUD];
            _hud = nil;
        }
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
    __weak typeof(PoisOfCityViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    //获取搜索列表信息
    [manager GET:API_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
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

- (void)updateView
{
    [self.tableView reloadData];
}

- (void)filter:(id)sender
{
    if (!self.filterCtl.filterViewIsShowing) {
        typeof(PoisOfCityViewController *)weakSelf = self;
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
    PoiSummary *poi;
    if (self.searchController.isActive) {
        poi = [_searchResultArray objectAtIndex:sender.tag];
    } else {
        poi = [_dataSource.recommendList objectAtIndex:sender.tag];
    }
    tripPoi.poiId = poi.poiId;
    tripPoi.zhName = poi.zhName;
    tripPoi.enName = poi.enName;
    tripPoi.images = poi.images;
    tripPoi.priceDesc = poi.priceDesc;
    tripPoi.desc = poi.desc;
    tripPoi.rating = poi.rating;
    tripPoi.address = poi.address;
    tripPoi.poiType = _poiType;
    if (_poiType == kRestaurantPoi) {
        [self.tripDetail.restaurantsList addObject:tripPoi];
    } else if (_poiType == kShoppingPoi) {
        [self.tripDetail.shoppingList addObject:tripPoi];
    }
    
    NSIndexPath *path;
    if (self.searchController.isActive) {
        path = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [self.searchController.searchResultsTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        if (self.tableView.numberOfSections>1) {
            path = [NSIndexPath indexPathForItem:sender.tag inSection:1];
        } else {
            path = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        }
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [SVProgressHUD showHint:@"已收集"];
}

- (IBAction)deletePoi:(UIButton *)sender
{
    PoiSummary *poi;
    if (self.searchController.isActive) {
        poi = [_searchResultArray objectAtIndex:sender.tag];
    } else {
        poi = [_dataSource.recommendList objectAtIndex:sender.tag];

    }
    
    NSMutableArray *oneDayArray;
    if (_poiType == kRestaurantPoi) {
        oneDayArray = self.tripDetail.restaurantsList;
    }
    if (_poiType == kShoppingPoi) {
        oneDayArray = self.tripDetail.shoppingList;
    }
    for (TripPoi *tripPoi in oneDayArray) {
        if ([tripPoi.poiId isEqualToString:poi.poiId]) {
            [oneDayArray removeObject:tripPoi];
            break;
        }
    }
    
    NSIndexPath *path;
    if (self.searchController.isActive) {
        path = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [self.searchController.searchResultsTableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        if (self.tableView.numberOfSections>1) {
            path = [NSIndexPath indexPathForItem:sender.tag inSection:1];
        } else {
            path = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        }

        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
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
    [_delegate finishEdit];
    
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    if (_poiType == kRestaurantPoi) {
        requsetUrl = [NSString stringWithFormat:@"%@%@", RESTAURANT_CITY_HTML,_cityId];
        webCtl.titleStr = [NSString stringWithFormat:@"%@吃什么", _zhName];
        
    } else if (_poiType == kShoppingPoi) {
        requsetUrl = [NSString stringWithFormat:@"%@%@", SHOPPING_CITY_HTML,_cityId];
        webCtl.titleStr = [NSString stringWithFormat:@"%@买什么", _zhName];
    }
    webCtl.urlStr = requsetUrl;
    
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
    
    if (_poiType == kRestaurantPoi) {
        self.navigationItem.title = [NSString stringWithFormat:@"吃在%@", _zhName];
    } else if (_poiType == kShoppingPoi) {
        self.navigationItem.title = [NSString stringWithFormat:@"买在%@", _zhName];
    }
    
    [_dataSource.recommendList removeAllObjects];
    _currentPageNormal = 0;
    [self.tableView reloadData];
    [self loadDataPoisOfCity:_currentPageNormal];
}


#pragma mark - UITableViewDataSource & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (![tableView isEqual:self.tableView]) {
        return self.searchResultArray.count;
    }
    if (![_dataSource.desc isBlankString] && _dataSource.desc != nil) {
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
    if (![_dataSource.desc isBlankString] && _dataSource.desc != nil) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (![tableView isEqual:self.tableView]) {
        return 0;
    }
    if (![_dataSource.desc isBlankString] && _dataSource.desc != nil) {
        if (section == 0) {
            return 150;
        }
        return 0;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (![_dataSource.desc isBlankString] && _dataSource.desc != nil) {
        if (section == 0) {
            UIView *sectionheaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 150)];
            sectionheaderView.backgroundColor = APP_PAGE_COLOR;
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, sectionheaderView.bounds.size.width, sectionheaderView.bounds.size.height-60)];
            btn.layer.cornerRadius = 2.0;
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, sectionheaderView.bounds.size.width, 30)];
            if (_poiType == kRestaurantPoi) {
                titleLabel.text = @"  吃什么";
            }
            if (_poiType == kShoppingPoi) {
                titleLabel.text = @"  买什么";
            }
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.backgroundColor = APP_THEME_COLOR;
            [sectionheaderView addSubview:titleLabel];
            
            NSUInteger len = [_dataSource.desc length];
            NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:_dataSource.desc];
            [desc addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE_SUBTITLE  range:NSMakeRange(0, len)];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineBreakMode = NSLineBreakByTruncatingTail;
            style.lineSpacing = 3.0;
            [desc addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, len)];
            [btn setAttributedTitle:desc forState:UIControlStateNormal];
            
            desc = [[NSMutableAttributedString alloc] initWithAttributedString:desc];
            [desc addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE  range:NSMakeRange(0, len)];
            [btn setAttributedTitle:desc forState:UIControlStateHighlighted];
            btn.backgroundColor = [UIColor whiteColor];
            [btn addTarget:self action:@selector(showIntruductionOfCity) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
            btn.titleLabel.numberOfLines = 4;
            [btn setContentEdgeInsets:UIEdgeInsetsMake(8, 15, 8, 50)];
            UIImageView *accessImageView = [[UIImageView alloc] initWithFrame:CGRectMake(sectionheaderView.frame.size.width-25, (btn.frame.size.height-10)/2, 6, 10)];
            accessImageView.image = [UIImage imageNamed:@"cell_accessory_pink.png"];
            [btn addSubview:accessImageView];
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
    cell.poi = poi;
    cell.actionBtn.tag = indexPath.row;
    
    //如果从攻略列表进来想要添加美食或酒店
    if (_shouldEdit) {
        BOOL isAdded = NO;
        NSMutableArray *tempArray;
        if (_poiType == kShoppingPoi) {
            tempArray = self.tripDetail.shoppingList;
        }
        if (_poiType == kRestaurantPoi) {
            tempArray = self.tripDetail.restaurantsList;
        }
        for (TripPoi *tripPoi in tempArray) {
            if ([tripPoi.poiId isEqualToString:poi.poiId]) {
                isAdded = YES;
                break;
            }
        }
        cell.isAdded = isAdded;
        if (isAdded) {
            [cell.actionBtn removeTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
            [cell.actionBtn addTarget:self action:@selector(deletePoi:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [cell.actionBtn removeTarget:self action:@selector(deletePoi:) forControlEvents:UIControlEventTouchUpInside];
            [cell.actionBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        }
    } else {
        cell.actionBtn.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PoiSummary *poi = [_dataSource.recommendList objectAtIndex:indexPath.row];
    if (_poiType == kRestaurantPoi) {
        CommonPoiDetailViewController *restaurantDetailCtl = [[CommonPoiDetailViewController alloc] init];
        restaurantDetailCtl.restaurantId = poi.poiId;
        
        [self addChildViewController:restaurantDetailCtl];
        [self.view addSubview:restaurantDetailCtl.view];
        
        NSLog(@"%@", self.navigationController);
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
    [self.searchResultArray removeAllObjects];
    [self.searchController.searchResultsTableView reloadData];
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
