//
//  PoisOfCityViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "PoisOfCityViewController.h"
#import "PoisOfCityTableViewCell.h"
#import "SINavigationMenuView.h"
#import "CityDestinationPoi.h"
#import "PoiSummary.h"
#import "RecommendsOfCity.h"
#import "RestaurantDetailViewController.h"
#import "ShoppingDetailViewController.h"
#import "PoiSummary.h"

@interface PoisOfCityViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SINavigationMenuDelegate>

@property (strong, nonatomic) UIView *tableHeaderView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *rightItemBtn;
@property (nonatomic, strong) SINavigationMenuView *titleMenu;
@property (nonatomic, strong) RecommendsOfCity *dataSource;

@property (nonatomic, assign) NSUInteger currentPage;

@end

@implementation PoisOfCityViewController

static NSString *poisOfCityCellIdentifier = @"poisOfCity";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = self.tableHeaderView;
    [self.tableView registerNib:[UINib nibWithNibName:@"PoisOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:poisOfCityCellIdentifier];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (self.tripDetail.destinations.count > 1) {
        self.navigationItem.titleView = self.titleMenu;
        CityDestinationPoi *poi = [self.tripDetail.destinations firstObject];
        _cityId = poi.cityId;
        _zhName = poi.zhName;
    } else {
        self.navigationItem.title = _zhName;
    }
    
    if (self.shouldEdit) {
        UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(finishAdd:)];
        leftBtn.tintColor = APP_THEME_COLOR;
        self.navigationItem.leftBarButtonItem = leftBtn;
    }
    
    _currentPage = 0;
    self.enableLoadingMore = NO;
    [self loadData:_currentPage];
}

#pragma mark - setter & getter

- (RecommendsOfCity *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[RecommendsOfCity alloc] init];
    }
    return _dataSource;
}

- (SINavigationMenuView *)titleMenu
{
    if (!_titleMenu) {
        NSMutableArray *names = [[NSMutableArray alloc] init];
        for (CityPoi *city in _tripDetail.destinations) {
            [names addObject:city.zhName];
        }
        CGRect frame = CGRectMake(0.0, 0.0, 100, self.navigationController.navigationBar.bounds.size.height);
        _titleMenu = [[SINavigationMenuView alloc] initWithFrame:frame title:[names firstObject]];
        [_titleMenu displayMenuInView:self.navigationController.view];
       
        _titleMenu.items = names;
        _titleMenu.delegate = self;
    }
    return _titleMenu;
}

- (UIView *)tableHeaderView
{
    if (!_tableHeaderView) {
        _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 145)];
        UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, _tableHeaderView.frame.size.width, 100)];
        headerImageView.image = [UIImage imageNamed:@"country.jpg"];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 80, _tableHeaderView.frame.size.width-50, 60)];
        titleLabel.font = [UIFont systemFontOfSize:14.0];
        titleLabel.numberOfLines = 4;
        titleLabel.textColor = [UIColor whiteColor];
        [_tableHeaderView addSubview:self.searchBar];
        [_tableHeaderView addSubview:headerImageView];
        [_tableHeaderView addSubview:titleLabel];
    }
    return _tableHeaderView;
}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        NSString *searchPlaceHolder;
        if (_poiType == kRestaurantPoi) {
            searchPlaceHolder = @"请输入美食名字";
        }
        if (_poiType == kShoppingPoi) {
            searchPlaceHolder = @"请输入购物名字";
        }
        
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.delegate = self;
        [_searchBar setPlaceholder:searchPlaceHolder];
        _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _searchBar.translucent = YES;
    }
    return _searchBar;

}

- (void) beginLoadingMore {
    [super beginLoadingMore];
    [self loadData:_currentPage + 1];
}

#pragma mark - Private Methods

- (void)loadData:(NSUInteger)pageNO
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
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInteger:pageNO] forKey:@"page"];
    
    //获取城市的美食列表信息
    [manager GET:requsetUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self.dataSource addRecommendList:[responseObject objectForKey:@"result"]];
            [self updateView];
            _currentPage = pageNO;
            if (_dataSource.recommendList.count >= 15) {
                self.enableLoadingMore = YES;
                _currentPage++;
            } else if (pageNO > 0){
                [self showHint:@"没有了,别强求~"];
            }
        } else {
            [self showHint:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        
        [self loadMoreCompleted];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [self loadMoreCompleted];
        [self showHint:@"呃～好像没找到网络"];
    }];
}

- (void)updateView
{
    [self.tableView reloadData];
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

#pragma mark - SINavigationMenuDelegate

- (void)didSelectItemAtIndex:(NSUInteger)index withSender:(id)sender
{
    CityDestinationPoi *destination = [self.tripDetail.destinations objectAtIndex:index];
    _cityId = destination.cityId;
    _zhName = destination.zhName;
    [_titleMenu setTitle:_zhName];
    [_dataSource.recommendList removeAllObjects];
    _currentPage = 0;
    [self loadData:_currentPage];
}

#pragma mark - UITableViewDataSource & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.recommendList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PoiSummary *poi = [_dataSource.recommendList objectAtIndex:indexPath.row];
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




@end
