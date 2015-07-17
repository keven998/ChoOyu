//
//  PoisSearchViewController.m
//  PeachTravel
//
//  Created by dapiao on 15/5/20.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "PoisSearchViewController.h"
#import "TaoziSearchBar.h"
#import "UIBarButtonItem+MJ.h"
#import "CommonPoiDetailViewController.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"
#import "HotelDetailViewController.h"
#import "SpotDetailViewController.h"
#import "TripPoiListTableViewCell.h"

@interface PoisSearchViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UISearchBarDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    UISearchBar *_searchBar;
    NSInteger _currentPageSearch;
    NSMutableArray *_seletedArray;
}
@property (nonatomic, copy) NSString *searchText;

@property (nonatomic, assign) BOOL isLoadingMoreSearch;
@property (nonatomic, assign) BOOL didEndScrollSearch;
@property (nonatomic, assign) BOOL enableLoadMoreSearch;

@end

static NSString *poisOfCityCellIdentifier = @"tripPoiListCell";

@implementation PoisSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    _seletedArray = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    _searchBar = [[UISearchBar alloc]init];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_searchBar setPlaceholder:@"搜索"];
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [_searchBar setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [_searchBar setBackgroundColor:APP_THEME_COLOR];
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.navigationItem.titleView = _searchBar;
    _searchBar.delegate = self;
    [_searchBar becomeFirstResponder];

    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goback)];
    self.navigationItem.rightBarButtonItem = rightBarBtn;
    
    if (_poiType == kRestaurantPoi) {
        _seletedArray = self.tripDetail.restaurantsList;
    } else if (_poiType == kShoppingPoi) {
        _seletedArray = self.tripDetail.shoppingList;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.backgroundColor = APP_PAGE_COLOR;
    _tableView.separatorColor = APP_DIVIDER_COLOR;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [_tableView registerNib:[UINib nibWithNibName:@"TripPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:poisOfCityCellIdentifier];

    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_searchBar resignFirstResponder];
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
        case kSpotPoi:
            [params setObject:[NSNumber numberWithBool:YES] forKey:@"vs"];
            break;
        default:
            break;
    }
    [params setObject:_cityId forKey:@"locId"];
    [params safeSetObject:_searchText forKey:@"keyword"];
    //获取搜索列表信息
    [manager GET:API_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //        NSLog(@"%@^-^-^",responseObject);
        NSString *key = nil;
        switch (_poiType) {
            case kRestaurantPoi:
                key = @"restaurant";
                break;
            case kShoppingPoi:
                key = @"shopping";
                break;
            case kSpotPoi:
                key = @"vs";
                break;
            default:
                break;
        }
        NSArray *jsonDic = [[responseObject objectForKey:@"result"] objectForKey:key];
        if (jsonDic.count == 15) {
            _enableLoadMoreSearch = YES;
        }
        for (id poiDic in jsonDic) {
            [_dataArray addObject:[PoiFactory poiWithJson:poiDic]];
        }
        _currentPageSearch = pageNo;
        
        [_tableView reloadData];
        [self loadMoreCompletedSearch];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self loadMoreCompletedSearch];
    }];
}

- (void) beginLoadingSearch
{
    _isLoadingMoreSearch = YES;
    [self loadSearchDataWithPageNo:(_currentPageSearch + 1)];
    
    NSLog(@"我要加载到第%lu",(long)_currentPageSearch+1);
    
}
- (void) loadMoreCompletedSearch
{
    if (!_isLoadingMoreSearch) return;
    _isLoadingMoreSearch = NO;
    _didEndScrollSearch = YES;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self beginSearch:nil];
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (!_isLoadingMoreSearch && _didEndScrollSearch && _enableLoadMoreSearch) {
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (scrollPosition < 44.0) {
            _didEndScrollSearch = NO;
            [self beginLoadingSearch];
        }
    }
}
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _didEndScrollSearch = YES;
    
}
#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 70;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SuperPoi *poi = [_dataArray objectAtIndex:indexPath.row];
    
    TripPoiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:poisOfCityCellIdentifier forIndexPath:indexPath];
    cell.tripPoi = poi;
    //    如果从攻略列表进来想要添加美食或酒店
    if (_shouldEdit) {
        cell.actionBtn.tag = indexPath.row;
        cell.actionBtn.hidden = NO;
        BOOL isAdded = NO;
        for (SuperPoi *tripPoi in _seletedArray) {
            if ([tripPoi.poiId isEqualToString:poi.poiId]) {
                isAdded = YES;
                break;
            }
        }
        cell.actionBtn.selected = isAdded;
        [cell.actionBtn removeTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        [cell.actionBtn addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    SuperPoi *poi = [_dataArray objectAtIndex:indexPath.row];
    if (_poiType == kRestaurantPoi) {
        CommonPoiDetailViewController *restaurantDetailCtl = [[RestaurantDetailViewController alloc] init];
        restaurantDetailCtl.poiId = poi.poiId;
        [self.navigationController pushViewController:restaurantDetailCtl animated:YES];
        NSLog(@"%@", self.navigationController);
    }
    else if (_poiType == kShoppingPoi) {
        CommonPoiDetailViewController *shoppingDetailCtl = [[ShoppingDetailViewController alloc] init];
        shoppingDetailCtl.poiId = poi.poiId;
        [self.navigationController pushViewController:shoppingDetailCtl animated:YES];
    }
    else if (_poiType == kSpotPoi) {
        SpotDetailViewController *spotDetail = [[SpotDetailViewController alloc]init];
        spotDetail.spotId = poi.poiId;
        [self.navigationController pushViewController:spotDetail animated:YES];
    }
}

/**
 *  添加一个 poi
 *
 *  @param sender
 */
- (IBAction)addPoi:(UIButton *)sender
{
    CGPoint point;
    NSIndexPath *indexPath;
    TripPoiListTableViewCell *cell;
    point = [sender convertPoint:CGPointZero toView:_tableView];
    indexPath = [_tableView indexPathForRowAtPoint:point];
    cell = (TripPoiListTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    SuperPoi *poi;
    poi = [_dataArray objectAtIndex:sender.tag];
    
    if (!cell.actionBtn.isSelected) {
        [_seletedArray addObject:poi];
        
        
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
        }
        
    }
    cell.actionBtn.selected = !cell.actionBtn.selected;
}

-(void)goback
{
    [self.delegate updateSelectedPlan];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)beginSearch:(id)sender;
{
    _searchText = _searchBar.text;
    [_dataArray removeAllObjects];
    [self loadSearchDataWithPageNo:0];
    [_searchBar resignFirstResponder];
}
@end
