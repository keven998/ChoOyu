//
//  ShoppingOfCityViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/25/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "ShoppingOfCityViewController.h"
#import "ShoppingOfCityTableViewCell.h"

@interface ShoppingOfCityViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *tableHeaderView;
@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation ShoppingOfCityViewController

static NSString *shoppingOfCityCellIdentifier = @"shoppingOfCityCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = APP_PAGE_COLOR;
    [self.view addSubview:self.tableView];
}

#pragma mark - setter & getter

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = self.tableHeaderView;
        [_tableView registerNib:[UINib nibWithNibName:@"ShoppingOfCityTableViewCell" bundle:nil] forCellReuseIdentifier:shoppingOfCityCellIdentifier];
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
    ShoppingOfCityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:shoppingOfCityCellIdentifier];
    return cell;
}
@end
