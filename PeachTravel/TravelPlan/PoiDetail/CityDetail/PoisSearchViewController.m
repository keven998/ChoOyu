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
@interface PoisSearchViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    TaoziSearchBar *_searchBar;
    NSInteger _currentPageSearch;
}
@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, strong) NSMutableArray *seletedArray;
@end

@implementation PoisSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    _searchBar = [TaoziSearchBar searchBar];
    _searchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH-50, 30);
    [_searchBar becomeFirstResponder];
    _currentPageSearch = 0;
    self.navigationItem.titleView = _searchBar;
    UIBarButtonItem *rightBarBtn = [[UIBarButtonItem alloc]initWithTitle:@"搜索" style:UIBarButtonItemStylePlain target:self action:@selector(beginSearch:)];
    self.navigationItem.rightBarButtonItem = rightBarBtn;
    
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(goback)];
    self.navigationItem.leftBarButtonItem = leftBarBtn;
    
    
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
        default:
            break;
    }
    
    [params setObject:_cityId forKey:@"locId"];
    [params safeSetObject:_searchText forKey:@"keyWord"];
    
    //获取搜索列表信息
    [manager GET:API_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"%@^-^-^",responseObject);
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
        
        for (id poiDic in jsonDic) {
            [_dataArray addObject:[PoiFactory poiWithJson:poiDic]];
        }
        
        
        [_tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}
- (void) beginLoadingSearch
{
    [self loadSearchDataWithPageNo:(_currentPageSearch + 1)];
}

#pragma mark - UIScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_tableView]) {
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (scrollPosition < 44.0) {
            
            [self beginLoadingSearch];
        }
    }
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
    cell.cellAction.hidden = NO;
    [cell.cellAction setTitle:@"收集" forState:UIControlStateNormal];
    [cell.cellAction setTitle:@"已收集" forState:UIControlStateSelected];
    [cell.cellAction setBackgroundImage:[ConvertMethods createImageWithColor:TEXT_COLOR_TITLE_DESC] forState:UIControlStateSelected];
    
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
    if (_poiType == kShoppingPoi) {
        CommonPoiDetailViewController *shoppingDetailCtl = [[ShoppingDetailViewController alloc] init];
        shoppingDetailCtl.poiId = poi.poiId;
        [self.navigationController pushViewController:shoppingDetailCtl animated:YES];
    }
}
- (IBAction)addPoi:(UIButton *)sender
{
    CommonPoiListTableViewCell *cell = (CommonPoiListTableViewCell *)[self.view viewWithTag:(sender.tag)];
    cell.cellAction.selected = !cell.cellAction.selected;
}
-(void)goback
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)beginSearch:(id)sender;
{
    _searchText = _searchBar.text;
    [_dataArray removeAllObjects];
    [self loadSearchDataWithPageNo:0];
    [_searchBar resignFirstResponder];
}
@end
