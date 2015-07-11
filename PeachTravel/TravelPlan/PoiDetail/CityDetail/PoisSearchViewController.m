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
#import "CommonPoiListTableViewCell.h"
#import "CommonPoiDetailViewController.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"
#import "HotelDetailViewController.h"
#import "SpotDetailViewController.h"

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
    
    //    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goback)];
    //    self.navigationItem.leftBarButtonItem = leftBarBtn;
    
    
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
    [_tableView registerNib:[UINib nibWithNibName:@"CommonPoiListTableViewCell" bundle:nil] forCellReuseIdentifier:@"commonPoiListCell"];
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
    
    return 90;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommonPoiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commonPoiListCell" forIndexPath:indexPath];
    SuperPoi *poi = _dataArray[indexPath.row];
    
    cell.tripPoi = poi;
    cell.cellAction.tag = indexPath.row;
    if (_tripDetail) {
        cell.cellAction.hidden = NO;
        if(_poiType == kSpotPoi){
            [cell.cellAction setTitle:@"添加" forState:UIControlStateNormal];
            [cell.cellAction setTitle:@"已添加" forState:UIControlStateSelected];
            [cell.cellAction addTarget:self action:@selector(addSpotPoi:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [cell.cellAction setTitle:@"收集" forState:UIControlStateNormal];
            [cell.cellAction setTitle:@"已收集" forState:UIControlStateSelected];
            [cell.cellAction addTarget:self action:@selector(addPoi:) forControlEvents:UIControlEventTouchUpInside];
        }
        [cell.cellAction setBackgroundImage:[ConvertMethods createImageWithColor:TEXT_COLOR_TITLE_DESC] forState:UIControlStateSelected];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
 *  添加或者删除景点
 *
 *  @param sender
 */
- (IBAction)addSpotPoi:(UIButton *)sender
{
    [MobClick event:@"event_add_desination_as_schedule"];
    
    CGPoint point;
    NSIndexPath *indexPath;
    CommonPoiListTableViewCell *cell;
    point = [sender convertPoint:CGPointZero toView:_tableView];
    indexPath = [_tableView indexPathForRowAtPoint:point];
    cell = (CommonPoiListTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    
    NSMutableArray *oneDayArray = [self.tripDetail.itineraryList objectAtIndex:_currentDayIndex];
    SuperPoi *poi;
    if (!cell.cellAction.selected) {
        
        poi = [_dataArray objectAtIndex:indexPath.row];
        
        [oneDayArray addObject:poi];
        
        //        NSIndexPath *lnp = [NSIndexPath indexPathForItem:oneDayArray.count - 1 inSection:0];
        //        [self.selectPanel performBatchUpdates:^{
        //            [self.selectPanel insertItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
        //        } completion:^(BOOL finished) {
        //            [self.selectPanel scrollToItemAtIndexPath:lnp
        //                                     atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        //        }];
    } else {
        SuperPoi *poi;
        poi = [_dataArray objectAtIndex:indexPath.row];
        
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
            //            NSIndexPath *lnp = [NSIndexPath indexPathForItem:index inSection:0];
            //            [self.selectPanel performBatchUpdates:^{
            //                [self.selectPanel deleteItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
            //            } completion:^(BOOL finished) {
            //                [self.selectPanel reloadData];
            //            }];
        }
        
    }
    cell.cellAction.selected = !cell.cellAction.selected;
    
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
    CommonPoiListTableViewCell *cell;
    point = [sender convertPoint:CGPointZero toView:_tableView];
    indexPath = [_tableView indexPathForRowAtPoint:point];
    cell = (CommonPoiListTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    
    SuperPoi *poi;
    poi = [_dataArray objectAtIndex:sender.tag];
    
    if (!cell.cellAction.isSelected) {
        [_seletedArray addObject:poi];
        
        //        NSIndexPath *lnp = [NSIndexPath indexPathForItem:_seletedArray.count - 1 inSection:0];
        //        [self.selectPanel performBatchUpdates:^{
        //            [self.selectPanel insertItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
        //        } completion:^(BOOL finished) {
        //            [self.selectPanel scrollToItemAtIndexPath:lnp
        //                                     atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        //        }];
        
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
            //            NSIndexPath *lnp = [NSIndexPath indexPathForItem:index inSection:0];
            //            [self.selectPanel performBatchUpdates:^{
            //                [self.selectPanel deleteItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
            //            } completion:^(BOOL finished) {
            //                [self.selectPanel reloadData];
            //            }];
        }
        
    }
    cell.cellAction.selected = !cell.cellAction.selected;
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
