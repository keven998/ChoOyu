//
//  AddPoiViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/26/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "AddPoiViewController.h"
#import "CityDestinationPoi.h"
#import "TripDetail.h"
#import "SpotDetailViewController.h"
#import "CommonPoiDetailViewController.h"
#import "PoisOfCityTableViewCell.h"
#import "PoiDetailViewControllerFactory.h"
#import "SelectionTableViewController.h"

enum {
    FILTER_TYPE_CITY = 1,
    FILTER_TYPE_CATE
};

@interface AddPoiViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UIActionSheetDelegate, SelectDelegate>

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

@property (nonatomic, strong) UICollectionView *selectPanel;

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
@property (nonatomic, copy) NSString *currentCategory;

//类型筛选: 1是城市、2是分类
@property (nonatomic, assign) NSInteger filterType;

@end

@implementation AddPoiViewController

static NSString *addPoiCellIndentifier = @"poisOfCity";

- (id)init {
    if (self = [super init]) {
        _currentPageNormal = 0;
        _isLoadingMoreNormal = YES;
        _didEndScrollNormal = YES;
        _enableLoadMoreNormal = NO;
        _currentCategory = @"景点";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    _tableView.delegate  = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 155.0;

    [self.view addSubview:_tableView];

    if (_tripDetail) {
        UIBarButtonItem *finishBtn = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(addFinish:)];
        self.navigationItem.rightBarButtonItem = finishBtn;
        
        UIBarButtonItem *cbtn = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ic_nav_filter_normal.png"] style:UIBarButtonItemStylePlain target:self action:@selector(categoryFilt)];
        self.navigationItem.leftBarButtonItem = cbtn;
        
        UIButton *tbtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
        [tbtn setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateNormal];
        tbtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [tbtn addTarget:self action:@selector(changeCity) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.titleView = tbtn;
        
        CityDestinationPoi *firstDestination = [_tripDetail.destinations firstObject];
        _cityName = firstDestination.zhName;
        
        [self setupTitleView];
        [self setupSelectPanel];
    } else {
        self.navigationItem.title = [NSString stringWithFormat:@"%@景点", _cityName];
    }
    
    _urlArray = @[API_GET_SPOTLIST_CITY, API_GET_RESTAURANTSLIST_CITY, API_GET_SHOPPINGLIST_CITY, API_GET_HOTELLIST_CITY];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:addPoiCellIndentifier];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 45)];
    _searchBar.delegate = self;
    self.tableView.tableHeaderView = _searchBar;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
    [self.searchController.searchResultsTableView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:addPoiCellIndentifier];
    self.searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchController.searchResultsTableView.backgroundColor = APP_PAGE_COLOR;
    self.searchController.searchResultsTableView.dataSource = self;
    self.searchController.searchResultsTableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.searchResultsTableView.rowHeight = 155.0;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    if (_tripDetail) {
        CityDestinationPoi *firstDestination = [_tripDetail.destinations firstObject];
        _requestUrl = [NSString stringWithFormat:@"%@%@", API_GET_SPOTLIST_CITY ,firstDestination.cityId];
    } else {
        _requestUrl = [NSString stringWithFormat:@"%@%@", API_GET_SPOTLIST_CITY ,_cityId];

    }
    [_tableView setContentOffset:CGPointMake(0, 45)];
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    
    [self loadDataWithPageNo:_currentPageNormal];
}

- (void) setupSelectPanel {
    CGRect collectionViewFrame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49, CGRectGetWidth(self.view.bounds), 49);
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.selectPanel = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:aFlowLayout];
    [self.selectPanel setBackgroundColor:[UIColor grayColor]];
    self.selectPanel.showsHorizontalScrollIndicator = NO;
    self.selectPanel.showsVerticalScrollIndicator = NO;
    self.selectPanel.delegate = self;
    self.selectPanel.dataSource = self;
    self.selectPanel.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    self.selectPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.selectPanel registerClass:[SelectDestCell class] forCellWithReuseIdentifier:@"sdest_cell"];
    
    [self.view addSubview:_selectPanel];
}

- (void) setupTitleView {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@[切换]", _cityName]];
    [attributeString addAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor]} range:NSMakeRange(attributeString.length - 4, 4)];
    [attributeString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} range:NSMakeRange(attributeString.length - 4, 4)];
    UIButton *tbtn = (UIButton *)self.navigationItem.titleView;
    [tbtn setAttributedTitle:attributeString forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_shouldEdit) {
        [MobClick beginLogPageView:@"page_add_agenda"];
    } else {
        [MobClick beginLogPageView:@"page_spot_lists"];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_shouldEdit) {
        [MobClick endLogPageView:@"page_add_agenda"];
    } else {
        [MobClick endLogPageView:@"page_spot_lists"];
    }
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
    _didEndScrollNormal = YES;
}

/**
 *  搜索状态下上拉加载更多
 */
- (void) beginLoadingSearch
{
    if (self.searchController.searchResultsTableView.tableFooterView == nil) {
//        self.searchController.searchResultsTableView.tableFooterView = self.footerView;
    }
    _isLoadingMoreSearch = YES;
    [_indicatroView startAnimating];
//    [self loadSearchDataWithPageNo:(_currentPageSearch + 1)];
    
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
    _didEndScrollSearch = YES;
}

#pragma mark - IBAction Methods

- (IBAction)addFinish:(id)sender
{
    [_delegate finishEdit];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  跳转到导航
 *
 *  @param sender
 */
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

/**
 *  添加或者删除景点
 *
 *  @param sender 
 */
- (IBAction)addPoi:(UIButton *)sender
{
    [MobClick event:@"event_add_desination_as_schedule"];
    
    CGPoint point;
    NSIndexPath *indexPath;
    PoisOfCityTableViewCell *cell;
    if (!self.searchController.isActive) {
        point = [sender convertPoint:CGPointZero toView:_tableView];
        indexPath = [_tableView indexPathForRowAtPoint:point];
        cell = (PoisOfCityTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];

    } else {
        point = [sender convertPoint:CGPointZero toView:_searchController.searchResultsTableView];
        indexPath = [_searchController.searchResultsTableView indexPathForRowAtPoint:point];
        cell = (PoisOfCityTableViewCell *)[_searchController.searchResultsTableView cellForRowAtIndexPath:indexPath];
    }
    
    NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    SuperPoi *poi;
    if (!cell.isAdded) {
        if (self.searchController.isActive) {
            poi = [self.searchResultArray objectAtIndex:indexPath.row];
        } else {
            poi = [self.dataSource objectAtIndex:indexPath.row];
        }
        [oneDayArray addObject:poi];
        
        NSIndexPath *lnp = [NSIndexPath indexPathForItem:oneDayArray.count - 1 inSection:0];
        [self.selectPanel performBatchUpdates:^{
            [self.selectPanel insertItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
        } completion:^(BOOL finished) {
            [self.selectPanel scrollToItemAtIndexPath:lnp
                                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }];
    } else {
        SuperPoi *poi;
        if (self.searchController.isActive) {
            poi = [self.searchResultArray objectAtIndex:indexPath.row];
        } else {
            poi = [self.dataSource objectAtIndex:indexPath.row];
        }
        NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
        int index = -1;
        NSInteger count = oneDayArray.count;
        for (int i = 0; i < count; ++i) {
            SuperPoi *tripPoi = [oneDayArray objectAtIndex:i];
            if ([tripPoi.poiId isEqualToString:poi.poiId]) {
                [oneDayArray removeObjectAtIndex:i];
                index = i;
                break;
            }
        }
        if (index != -1) {
            NSIndexPath *lnp = [NSIndexPath indexPathForItem:index inSection:0];
            [self.selectPanel performBatchUpdates:^{
                [self.selectPanel deleteItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
            } completion:^(BOOL finished) {
                [self.selectPanel reloadData];
            }];
        }

    }
    cell.isAdded = !cell.isAdded;

}

- (void) categoryFilt {
    SelectionTableViewController *ctl = [[SelectionTableViewController alloc] init];
    ctl.contentItems = @[@"景点", @"美食", @"购物", @"酒店"];
    ctl.titleTxt = @"切换类别";
    ctl.delegate = self;
    ctl.selectItem = _currentCategory;
    TZNavigationViewController *nav = [[TZNavigationViewController alloc] initWithRootViewController:ctl];
    [self presentViewController:nav animated:YES completion:^{
        _filterType = FILTER_TYPE_CATE;
    }];
}

- (void) changeCity {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (CityDestinationPoi *poi in _tripDetail.destinations) {
        [array addObject:poi.zhName];
    }
    SelectionTableViewController *ctl = [[SelectionTableViewController alloc] init];
    ctl.contentItems = [NSArray arrayWithArray:array];
    ctl.titleTxt = @"切换城市";
    ctl.delegate = self;
    UIButton *tbtn = (UIButton *)self.navigationItem.titleView;
    NSString *title = [tbtn attributedTitleForState:UIControlStateNormal].string;
    ctl.selectItem = [title substringToIndex:title.length - 4];
    TZNavigationViewController *nav = [[TZNavigationViewController alloc] initWithRootViewController:ctl];
    [self presentViewController:nav animated:YES completion:^{
        _filterType = FILTER_TYPE_CITY;
    }];
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
    NSNumber *imageWidth = [NSNumber numberWithInt:300];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    
    NSString *backUrlForCheck = _requestUrl;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    TZProgressHUD *hud;
    if (pageNo == 0) {
        hud = [[TZProgressHUD alloc] init];
        __weak typeof(self)weakSelf = self;
        [hud showHUDInViewController:weakSelf];
    }
    //获取列表信息
    [manager GET:_requestUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        if (hud) {
            [hud hideTZHUD];
        }
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if ([backUrlForCheck isEqualToString:_requestUrl]) {
                NSArray *jsonDic = [responseObject objectForKey:@"result"];
                if (jsonDic.count == 15) {
                    _enableLoadMoreNormal = YES;
                }
                for (id poiDic in [responseObject objectForKey:@"result"]) {
                    [self.dataSource addObject:[PoiFactory poiWithJson:poiDic]];
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
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if (hud) {
            [hud hideTZHUD];
        }
        [self loadMoreCompletedNormal];
        
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

/**
 *  加载搜索的数据
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
    NSNumber *imageWidth = [NSNumber numberWithInt:300];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

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

    [params setObject:[NSNumber numberWithBool:YES] forKey:key];
    
    if (_tripDetail) {
        CityDestinationPoi *poi = [self.tripDetail.destinations objectAtIndex:_currentCityIndex];
        [params safeSetObject:poi.cityId forKey:@"locId"];
    } else {
        [params safeSetObject:_cityId forKey:@"locId"];
    }
   
    [params safeSetObject:_searchText forKey:@"keyWord"];
    
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    
    //获取搜索列表信息
    [manager GET:API_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (self.searchDisplayController.isActive) {
            NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
            if (code == 0) {
                NSArray *jsonDic = [[responseObject objectForKey:@"result"] objectForKey:key];
                if (jsonDic.count == 15) {
                    _enableLoadMoreSearch = YES;
                }
                for (id poiDic in jsonDic) {
                    SuperPoi *poi = [PoiFactory poiWithPoiTypeDesc:key andJson:poiDic];
                    [self.searchResultArray addObject:poi];
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
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [hud hideTZHUD];
        [self loadMoreCompletedSearch];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SuperPoi *poi;
    if ([tableView isEqual:self.tableView]) {
        poi = [self.dataSource objectAtIndex:indexPath.row];
    } else {
        poi = [self.searchResultArray objectAtIndex:indexPath.row];
    }
    BOOL isAdded = NO;
    NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    for (SuperPoi *tripPoi in oneDayArray) {
        if ([tripPoi.poiId isEqualToString:poi.poiId]) {
            isAdded = YES;
        }
    }
    
    PoisOfCityTableViewCell *poiCell = [tableView dequeueReusableCellWithIdentifier:addPoiCellIndentifier forIndexPath:indexPath];
    poiCell.poi = poi;
    poiCell.shouldEdit = _shouldEdit;
    if (_shouldEdit) {
        poiCell.addBtn.tag = indexPath.row;
        poiCell.isAdded = isAdded;
        [poiCell.addBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        poiCell.naviBtn.tag = indexPath.row;
        [poiCell.naviBtn removeTarget:self action:@selector(jumpToMapView:) forControlEvents:UIControlEventTouchUpInside];
        [poiCell.naviBtn addTarget:self action:@selector(jumpToMapView:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return poiCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SuperPoi *tripPoi;
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
        default: {
            CommonPoiDetailViewController *ctl = [PoiDetailViewControllerFactory poiDetailViewControllerWithPoiType:tripPoi.poiType];
            ctl.poiId = tripPoi.poiId;
            [self addChildViewController:ctl];
            [self.view addSubview:ctl.view];
        }
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

-(BOOL)searchDisplayController:(UISearchDisplayController *)controlle shouldReloadTableForSearchString:(NSString *)searchString {
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.001);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (UIView* v in _searchController.searchResultsTableView.subviews) {
            if ([v isKindOfClass: [UILabel class]] &&
                ([[(UILabel*)v text] isEqualToString:@"No Results"] || [[(UILabel*)v text] isEqualToString:@"无结果"]) ) {
                ((UILabel *)v).text = @"";
                break;
            }
        }
    });
    return YES;
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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    SuperPoi *poi;
    if (_searchController.active) {
        poi = [self.searchResultArray objectAtIndex:actionSheet.tag];
    } else {
        poi = [_dataSource objectAtIndex:actionSheet.tag];
    }
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

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    return oneDayArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectDestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sdest_cell" forIndexPath:indexPath];
    
    NSArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    SuperPoi *tripPoi = [oneDayArray objectAtIndex:indexPath.row];
    NSString *txt = [NSString stringWithFormat:@"%ld %@", (indexPath.row + 1), tripPoi.zhName];
    cell.textView.text = txt;
    CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName : cell.textView.font}];
    cell.textView.frame = CGRectMake(0, 0, size.width, 49);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    SuperPoi *tripPoi = [oneDayArray objectAtIndex:indexPath.row];
    NSString *txt = [NSString stringWithFormat:@"%ld %@", (indexPath.row + 1), tripPoi.zhName];
    CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    return CGSizeMake(size.width, 49);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 15.0;
}

#pragma mark - SelectDelegate
- (void) selectItem:(NSString *)str atIndex:(NSIndexPath *)indexPath {
    if (_filterType == FILTER_TYPE_CITY) {
        if (_currentCityIndex == indexPath.row) {
            return;
        }
        _cityName = str;
        [self setupTitleView];
        _currentCityIndex = indexPath.row;
        [self resetContents];
        [MobClick event:@"event_filter_city"];
    } else if (_filterType == FILTER_TYPE_CATE) {
        if (_currentListTypeIndex == indexPath.row) {
            return;
        }
        _currentCategory = str;
        _currentListTypeIndex = indexPath.row;
        [MobClick event:@"event_filter_items"];
        [self resetContents];
    }
}

- (void) resetContents {
    _isLoadingMoreNormal = YES;
    _didEndScrollNormal = YES;
    _enableLoadMoreNormal = NO;
    CityDestinationPoi *poi = [self.tripDetail.destinations objectAtIndex:_currentCityIndex];
    _requestUrl = [NSString stringWithFormat:@"%@%@", _urlArray[_currentListTypeIndex], poi.cityId];
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    _currentPageNormal = 0;
    [self loadDataWithPageNo:_currentPageNormal];
}

@end

@implementation SelectDestCell

@synthesize textView;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        textView = [[UILabel alloc] init];
        textView.font = [UIFont systemFontOfSize:17];
        textView.textColor = [UIColor blueColor];
        textView.textAlignment = NSTextAlignmentCenter;
        textView.numberOfLines = 1;
        [self.contentView addSubview:textView];
    }
    return self;
}

@end