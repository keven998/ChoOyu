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
    if (self.cities.count) {
        self.navigationItem.titleView = self.titleMenu;
    }
    _rightItemBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_rightItemBtn setTitle:@"chat" forState:UIControlStateNormal];
    [_rightItemBtn setTitleColor:UIColorFromRGB(0xee528c) forState:UIControlStateNormal];
    [_rightItemBtn addTarget:self action:@selector(chat:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightItemBtn];
}

#pragma mark - setter & getter

- (SINavigationMenuView *)titleMenu
{
    if (!_titleMenu) {
        CGRect frame = CGRectMake(0.0, 0.0, 200.0, self.navigationController.navigationBar.bounds.size.height);
        _titleMenu = [[SINavigationMenuView alloc] initWithFrame:frame title:@"安顺"];
        [_titleMenu displayMenuInView:self.navigationController.view];
        _titleMenu.items = @[@"安顺", @"大阪",@"葡萄牙",@"大不列颠及北爱尔兰"];
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

#pragma mark - IBAction Methods

- (IBAction)showMoreCities:(UIButton *)sender
{
}

- (IBAction)chat:(id)sender
{
    
}

#pragma mark - SINavigationMenuDelegate

- (void)didSelectItemAtIndex:(NSUInteger)index
{
    [_titleMenu setTitle:_titleMenu.items[index]];
}



#pragma mark - UITableViewDataSource & delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 166.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantOfCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:restaurantOfCityCellIdentifier];
    return cell;
}
@end
