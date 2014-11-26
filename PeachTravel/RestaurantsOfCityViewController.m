//
//  RestaurantsOfCityViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "RestaurantsOfCityViewController.h"
#import "RestaurantOfCityTableViewCell.h"
#import "SINavigationMenuView.h"

@interface RestaurantsOfCityViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SINavigationMenuDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *tableHeaderView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *rightItemBtn;
@property (nonatomic, strong) SINavigationMenuView *titleMenu;

@end

@implementation RestaurantsOfCityViewController

static NSString *restaurantOfCityCellIdentifier = @"restaurantOfCityCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self.view addSubview:self.tableView];
    if (self.cities.count > 1) {
        self.navigationItem.titleView = self.titleMenu;
    } else {
        self.navigationItem.title = _currentCity.zhName;
    }
    _rightItemBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_rightItemBtn setTitle:@"chat" forState:UIControlStateNormal];
    [_rightItemBtn setTitleColor:UIColorFromRGB(0xee528c) forState:UIControlStateNormal];
    [_rightItemBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightItemBtn];
    [self loadDataWithCityId:_currentCity.cityId];
}

#pragma mark - setter & getter

- (SINavigationMenuView *)titleMenu
{
    if (!_titleMenu) {
        NSMutableArray *names = [[NSMutableArray alloc] init];
        for (CityPoi *city in _cities) {
            [names addObject:city.zhName];
        }
        CGRect frame = CGRectMake(0.0, 0.0, 200.0, self.navigationController.navigationBar.bounds.size.height);
        _titleMenu = [[SINavigationMenuView alloc] initWithFrame:frame title:[names firstObject]];
        [_titleMenu displayMenuInView:self.navigationController.view];
       
        _titleMenu.items = names;
        _titleMenu.delegate = self;
    }
    return _titleMenu;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = self.tableHeaderView;
        [_tableView registerNib:[UINib nibWithNibName:@"RestaurantOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:restaurantOfCityCellIdentifier];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = APP_PAGE_COLOR;
    }
    return _tableView;
}

- (UIView *)tableHeaderView
{
    if (!_tableHeaderView) {
        _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 190)];
        UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, _tableHeaderView.frame.size.width, 150)];
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
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        _searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchBar.delegate = self;
        [_searchBar setPlaceholder:@"请输入美食名字"];
        _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _searchBar.translucent = YES;
    }
    return _searchBar;

}

#pragma mark - Private Methods

- (void)loadDataWithCityId:(NSString *)cityId
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *requsetUrl = [NSString stringWithFormat:@"%@%@", API_GET_RESTAURANTSLIST_CITY,cityId];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSNumber numberWithInt:3] forKey:@"noteCnt"];
    
    [SVProgressHUD show];
    
    //获取城市的美食列表信息
    [manager GET:requsetUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        [SVProgressHUD dismiss];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [_currentCity.restaurants setRestaurantsListWithJson:[responseObject objectForKey:@"result"]];
            [self updateView];
        } else {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"err"] objectForKey:@"message"]]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        [SVProgressHUD dismiss];
    }];
}

- (void)updateView
{
    [self.tableView reloadData];
}

#pragma mark - IBAction Methods

- (IBAction)showMoreCities:(UIButton *)sender
{
}

- (IBAction)chat:(id)sender
{
    
}

#pragma mark - SINavigationMenuDelegate

- (void)didSelectItemAtIndex:(NSUInteger)index withSender:(id)sender
{
    _currentCity = [self.cities objectAtIndex:index];
    [_titleMenu setTitle:_currentCity.zhName];
}



#pragma mark - UITableViewDataSource & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _currentCity.restaurants.restaurantsList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantPoi *restaurantPoi = [_currentCity.restaurants.restaurantsList objectAtIndex:indexPath.row];
    if ([restaurantPoi.comments count]) {
        return 166.0;
    }
    return 130;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantPoi *restaurantPoi = [_currentCity.restaurants.restaurantsList objectAtIndex:indexPath.row];
    RestaurantOfCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:restaurantOfCityCellIdentifier];
    cell.restaurantPoi = restaurantPoi;
    return cell;
}
@end
