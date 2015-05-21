//
//  PoisOfCityViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "PoisOfCityViewController.h"
#import "CommonPoiListTableViewCell.h"
#import "TZFilterViewController.h"
#import "CityDestinationPoi.h"
#import "RecommendsOfCity.h"
#import "CommonPoiDetailViewController.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"
#import "SuperWebViewController.h"
#import "PoisSearchViewController.h"
@interface PoisOfCityViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, TZFilterViewDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UISearchDisplayDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

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
@property (nonatomic, strong) UIButton *filterBtn;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UICollectionView *selectPanel;

@property (nonatomic, strong) NSMutableArray *seletedArray;

@end

@implementation PoisOfCityViewController

static NSString *poisOfCityCellIdentifier = @"commonPoiListCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    if (self.shouldEdit) {
        UIBarButtonItem *lbtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(finishAdd:)];
        self.navigationItem.leftBarButtonItem = lbtn;
    } else {
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"ic_navigation_back.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(0, 0, 48, 30)];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.leftBarButtonItem = barButton;
    }
    
    NSMutableArray *rbItems = [[NSMutableArray alloc] init];
    
    if (self.tripDetail) {
        CityDestinationPoi *destination = [self.tripDetail.destinations firstObject];
        _zhName = destination.zhName;
        _cityId = destination.cityId;
        if (self.tripDetail.destinations.count > 1) {
            _filterBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 34, 40)];
            [_filterBtn setImage:[UIImage imageNamed:@"ic_nav_filter_normal.png"] forState:UIControlStateNormal];
            _filterBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [_filterBtn addTarget:self action:@selector(filter:) forControlEvents:UIControlEventTouchUpInside];
            UIBarButtonItem *filterItemBar = [[UIBarButtonItem alloc] initWithCustomView:_filterBtn];
            [rbItems addObject:filterItemBar];
        }
    }
    
    UIBarButtonItem *lbtn = [[UIBarButtonItem alloc] initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(beginSearch:)];
    [rbItems addObject:lbtn];
    self.navigationItem.rightBarButtonItems = rbItems;
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 44)];
    if (_poiType == kRestaurantPoi) {
        _searchBar.placeholder = @"搜索美食";
    } else if (_poiType == kShoppingPoi) {
        _searchBar.placeholder = @"搜索购物";
    }
    _searchBar.delegate = self;
    
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"CommonPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:poisOfCityCellIdentifier];
    [self.view addSubview:self.tableView];
    
//    self.tableView.tableHeaderView = _searchBar;
//    self.tableView.tableFooterView = _footerView;
    
    if (_poiType == kRestaurantPoi) {
        self.navigationItem.title = [NSString stringWithFormat:@"吃在%@", _zhName];
    } else if (_poiType == kShoppingPoi) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@购物", _zhName];
    }
    
    NSString *searchPlaceHolder;
    if (_poiType == kRestaurantPoi) {
        searchPlaceHolder = @"输入美食";
    } else if (_poiType == kShoppingPoi) {
        searchPlaceHolder = @"输入购物";
    }
    _currentPageNormal = 0;
    
    _hud = [[TZProgressHUD alloc] init];
    __weak typeof(PoisOfCityViewController *)weakSelf = self;
    [_hud showHUDInViewController:weakSelf];
    
    if (_poiType == kRestaurantPoi) {
        _seletedArray = self.tripDetail.restaurantsList;
    } else if (_poiType == kShoppingPoi) {
        _seletedArray = self.tripDetail.shoppingList;
    }

    if (!_shouldEdit) {
        [self loadIntroductionOfCity];
    } else {
        [self loadDataPoisOfCity:_currentPageNormal];
        [self setupSelectPanel];
        [_tableView setContentOffset:CGPointMake(0, 49)];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    if (_shouldEdit) {
        [MobClick beginLogPageView:@"page_add_agenda"];
    } else {
        if (_poiType == kRestaurantPoi) {
            [MobClick beginLogPageView:@"page_delicacy_lists"];
        } else if (_poiType == kShoppingPoi) {
            [MobClick beginLogPageView:@"page_shopping_lists"];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_shouldEdit) {
        [MobClick endLogPageView:@"page_add_agenda"];
    } else {
        if (_poiType == kRestaurantPoi) {
            [MobClick endLogPageView:@"page_delicacy_lists"];
        } else if (_poiType == kShoppingPoi) {
            [MobClick endLogPageView:@"page_shopping_lists"];
        }
    }
}

- (void)goBack
{
    if (self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - private method
- (void) setupSelectPanel {
    CGRect collectionViewFrame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49, CGRectGetWidth(self.view.bounds), 49);
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.selectPanel = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:aFlowLayout];
    [self.selectPanel setBackgroundColor:[UIColor whiteColor]];
    self.selectPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.selectPanel.showsHorizontalScrollIndicator = NO;
    self.selectPanel.showsVerticalScrollIndicator = NO;
    self.selectPanel.delegate = self;
    self.selectPanel.dataSource = self;
    self.selectPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.selectPanel.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    [self.selectPanel registerClass:[SelectDestCell class] forCellWithReuseIdentifier:@"sdest_cell"];
    [self.view addSubview:_selectPanel];
}

#pragma mark - setter & getter

- (UISearchDisplayController *)searchController
{
    if (!_searchController) {
        _searchController= [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
        [_searchController.searchResultsTableView registerNib:[UINib nibWithNibName:@"CommonPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:poisOfCityCellIdentifier];
        _searchController.searchResultsTableView.backgroundColor = APP_PAGE_COLOR;
        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchController.searchResultsTableView.backgroundColor = APP_PAGE_COLOR;
        _searchController.searchResultsTableView.delegate = self;
        _searchController.searchResultsTableView.dataSource = self;
        _searchController.delegate = self;
    }
    return _searchController;
}

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
    NSNumber *imageWidth = [NSNumber numberWithInt:300];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInteger:pageNO] forKey:@"page"];
    
    //获取城市的美食.购物列表信息
    [manager GET:requsetUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (_hud) {
            [_hud hideTZHUD];
            _hud = nil;
        }
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
    NSNumber *imageWidth = [NSNumber numberWithInt:300];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithInteger:pageNo] forKey:@"page"];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

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
    [params safeSetObject:_searchText forKey:@"keyWord"];
    
    NSLog(@"searchController.searchResultsTableView frame :%@", NSStringFromCGRect(_searchController.searchResultsTableView.frame));
    
    //获取搜索列表信息
    [manager GET:API_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
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
                    [self.searchResultArray addObject:[PoiFactory poiWithJson:poiDic]];
                }
                [self.searchController.searchResultsTableView reloadData];
                _currentPageSearch = pageNo;
            } else {
//                if (self.isShowing) {
//                    [SVProgressHUD showHint:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
//                }
            }
            [self loadMoreCompletedSearch];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self loadMoreCompletedSearch];
//        if (self.isShowing) {
//            [SVProgressHUD showHint:@"呃～好像没找到网络"];
//        }
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
    CGPoint point;
    NSIndexPath *indexPath;
    CommonPoiListTableViewCell *cell;
    if (!self.searchController.isActive) {
        point = [sender convertPoint:CGPointZero toView:_tableView];
        indexPath = [_tableView indexPathForRowAtPoint:point];
        cell = (CommonPoiListTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    } else {
        point = [sender convertPoint:CGPointZero toView:_searchController.searchResultsTableView];
        indexPath = [_searchController.searchResultsTableView indexPathForRowAtPoint:point];
        cell = (CommonPoiListTableViewCell *)[_searchController.searchResultsTableView cellForRowAtIndexPath:indexPath];
    }
    
    SuperPoi *poi;
    if (self.searchController.isActive) {
        poi = [_searchResultArray objectAtIndex:sender.tag];
    } else {
        poi = [_dataSource.recommendList objectAtIndex:sender.tag];
    }
   
    if (!cell.cellAction.isSelected) {
        [_seletedArray addObject:poi];
        
        NSIndexPath *lnp = [NSIndexPath indexPathForItem:_seletedArray.count - 1 inSection:0];
        [self.selectPanel performBatchUpdates:^{
            [self.selectPanel insertItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
        } completion:^(BOOL finished) {
            [self.selectPanel scrollToItemAtIndexPath:lnp
                                     atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        }];
        
    } else {
        int index = -1;
        NSInteger count = _seletedArray.count;
        for (int i = 0; i < count; ++i) {
            SuperPoi *tripPoi = [_seletedArray objectAtIndex:i];
            if ([tripPoi.poiId isEqualToString:poi.poiId]) {
                [_seletedArray removeObjectAtIndex:i];
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
    cell.cellAction.selected = !cell.cellAction.selected;
}

- (IBAction)finishAdd:(id)sender
{
    [_delegate finishEdit];
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}


/**
 *  点击搜索按钮开始搜索
 *
 *  @param sender 
 */
- (IBAction)beginSearch:(id)sender
{
//    [self.searchController setActive:YES animated:YES];
//    [_searchBar becomeFirstResponder];
    PoisSearchViewController *poiSearchCtl = [[PoisSearchViewController alloc]init];
    poiSearchCtl.poiType = _poiType;
    poiSearchCtl.tripDetail = _tripDetail;
    poiSearchCtl.cityId = _cityId;
    poiSearchCtl.zhName = _zhName;
    [self.navigationController pushViewController:poiSearchCtl animated:YES];
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

- (void)showIntruductionOfCity
{
    SuperWebViewController *webCtl = [[SuperWebViewController alloc] init];
    if (_poiType == kRestaurantPoi) {
        webCtl.titleStr = @"美食攻略";
        [MobClick event:@"event_delicacy_strategy"];
        
    } else if (_poiType == kShoppingPoi) {
        webCtl.titleStr = @"购物攻略";
        [MobClick event:@"event_shopping_strategy"];

    }
    webCtl.urlStr = _dataSource.detailUrl;
    webCtl.hideToolBar = YES;
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
    _didEndScrollNormal = YES;
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
    _didEndScrollSearch = YES;
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
        self.navigationItem.title = [NSString stringWithFormat:@"%@购物", _zhName];
    }
    
    [_dataSource.recommendList removeAllObjects];
    _currentPageNormal = 0;
    [self.tableView reloadData];
    [self loadDataPoisOfCity:_currentPageNormal];
    
    [_filterBtn setTitle:_zhName forState:UIControlStateNormal];
}


#pragma mark - UITableViewDataSource & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //如果是搜索的情况
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
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
            return 160;
        }
        return 0;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (![_dataSource.desc isBlankString] && _dataSource.desc != nil) {
        if (section == 0) {
            UIView *sectionheaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 160)];
            sectionheaderView.backgroundColor = APP_PAGE_COLOR;
            
            UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(11, 20, sectionheaderView.bounds.size.width-22, 4)];
            spaceView.backgroundColor = APP_THEME_COLOR;
            
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(11, 20, sectionheaderView.bounds.size.width-22, sectionheaderView.bounds.size.height-30)];
            btn.layer.cornerRadius = 3.0;
            
            UIButton *tagBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 18, 80, 80)];
            tagBtn.titleLabel.numberOfLines = 2.0;
            [tagBtn setBackgroundImage:[UIImage imageNamed:@"ic_city_border.png"] forState:UIControlStateNormal];
            if (_poiType == kRestaurantPoi) {
                [tagBtn setTitle:@"美食\n攻略" forState:UIControlStateNormal];
            } else if (_poiType == kShoppingPoi) {
                [tagBtn setTitle:@"购物\n攻略" forState:UIControlStateNormal];
            }
            tagBtn.titleLabel.font  = [UIFont boldSystemFontOfSize:17.0];
            [tagBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 5, 0)];
            [tagBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
            tagBtn.userInteractionEnabled = YES;
            [btn addSubview:tagBtn];
            
            NSUInteger len = [_dataSource.desc length];
            NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:_dataSource.desc];
            [desc addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE_SUBTITLE  range:NSMakeRange(0, len)];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineBreakMode = NSLineBreakByTruncatingTail;
            style.lineSpacing = 1;
            [desc addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, len)];
            [btn setAttributedTitle:desc forState:UIControlStateNormal];
            
            desc = [[NSMutableAttributedString alloc] initWithAttributedString:desc];
            [desc addAttribute:NSForegroundColorAttributeName value:TEXT_COLOR_TITLE  range:NSMakeRange(0, len)];
            [btn setAttributedTitle:desc forState:UIControlStateHighlighted];
            btn.backgroundColor = [UIColor whiteColor];
            [btn addTarget:self action:@selector(showIntruductionOfCity) forControlEvents:UIControlEventTouchUpInside];
            btn.titleLabel.font = [UIFont systemFontOfSize:12.0];
            btn.titleLabel.numberOfLines = 4;
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(26, 100, 35, 10)];
            
            UILabel *moreLabel = [[UILabel alloc] initWithFrame:CGRectMake(btn.bounds.size.width-49, btn.bounds.size.height-26, 30, 20)];
            moreLabel.textColor = TEXT_COLOR_TITLE_SUBTITLE;
            moreLabel.font = [UIFont systemFontOfSize:11.0];
            moreLabel.text = @"详情";
            
            UIImageView *moreImage = [[UIImageView alloc] initWithFrame:CGRectMake(btn.bounds.size.width-20, btn.bounds.size.height-22, 7, 11)];
            moreImage.image = [UIImage imageNamed:@"more_btn.png"];
            [btn addSubview:moreLabel];
            [btn addSubview:moreImage];
            
            [sectionheaderView addSubview:btn];
            [sectionheaderView addSubview:spaceView];
            return sectionheaderView;
        }
        return nil;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SuperPoi *poi ;
    if (![tableView isEqual:self.tableView]) {
        poi = [self.searchResultArray objectAtIndex:indexPath.row];
    } else {
        poi = [_dataSource.recommendList objectAtIndex:indexPath.row];
    }
    CommonPoiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:poisOfCityCellIdentifier forIndexPath:indexPath];
    cell.tripPoi = poi;
    //如果从攻略列表进来想要添加美食或酒店
    if (_shouldEdit) {
        cell.cellAction.tag = indexPath.row;
        cell.cellAction.hidden = NO;
        [cell.cellAction setTitle:@"收集" forState:UIControlStateNormal];
        [cell.cellAction setTitle:@"已收集" forState:UIControlStateSelected];
        [cell.cellAction setBackgroundImage:[ConvertMethods createImageWithColor:TEXT_COLOR_TITLE_DESC] forState:UIControlStateSelected];
        BOOL isAdded = NO;
        for (SuperPoi *tripPoi in _seletedArray) {
            if ([tripPoi.poiId isEqualToString:poi.poiId]) {
                isAdded = YES;
                break;
            }
        }
        cell.cellAction.selected = isAdded;
        [cell.cellAction removeTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        [cell.cellAction addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
    }
//    else {
//        [cell.cellAction setTitle:@"地图" forState:UIControlStateNormal];
//        [cell.cellAction removeTarget:self action:@selector(jumpToMapView:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.cellAction addTarget:self action:@selector(jumpToMapView:) forControlEvents:UIControlEventTouchUpInside];
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    SuperPoi *poi;
    if (self.searchController.isActive) {
        poi = [_searchResultArray objectAtIndex:indexPath.row];
    } else {
        poi = [_dataSource.recommendList objectAtIndex:indexPath.row];
    }
    
    if (_poiType == kRestaurantPoi) {
        CommonPoiDetailViewController *restaurantDetailCtl = [[RestaurantDetailViewController alloc] init];
        restaurantDetailCtl.poiId = poi.poiId;
        [self.navigationController pushViewController:restaurantDetailCtl animated:YES];
        NSLog(@"%@", self.navigationController);
    }
    if (_poiType == kShoppingPoi) {
        CommonPoiDetailViewController *shoppingDetailCtl = [[ShoppingDetailViewController alloc] init];
        shoppingDetailCtl.poiId = poi.poiId;
        [self.navigationController pushViewController:shoppingDetailCtl animated:YES];
    }
}

#pragma mark - SearchBarDelegate


//
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchController setActive:YES animated:YES];
}

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

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
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

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    SuperPoi *poi;
    if (_searchController.active)
    {
        poi = [self.searchResultArray objectAtIndex:actionSheet.tag];
    }
    else
    {
        poi = [_dataSource.recommendList objectAtIndex:actionSheet.tag];
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
                }
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _seletedArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectDestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sdest_cell" forIndexPath:indexPath];
    SuperPoi *tripPoi = [_seletedArray objectAtIndex:indexPath.row];
    
    NSString *txt = [NSString stringWithFormat:@"%ld %@", (indexPath.row + 1), tripPoi.zhName];
    cell.textView.text = txt;
    CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName : cell.textView.font}];
    cell.textView.frame = CGRectMake(0, 0, size.width, 49);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SuperPoi *tripPoi = [_seletedArray objectAtIndex:indexPath.row];
    NSString *txt = [NSString stringWithFormat:@"%ld %@", (indexPath.row + 1), tripPoi.zhName];
    CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    return CGSizeMake(size.width, 49);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 15.0;
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
