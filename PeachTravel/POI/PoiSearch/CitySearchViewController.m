//
//  CitySearchViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/22/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "CitySearchViewController.h"
#import "SearchDestinationRecommendViewController.h"
#import "PoiManager.h"

@interface CitySearchViewController () <SearchDestinationRecommendDelegate, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate>

@property (nonatomic, strong) SearchDestinationRecommendViewController *searchRecommendViewController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation CitySearchViewController

static NSString *reusableCellIdentifier = @"searchResultCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addChildViewController:self.searchRecommendViewController];
    [self.view addSubview:self.searchRecommendViewController.view];
    self.searchRecommendViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.searchRecommendViewController willMoveToParentViewController:self];
    [self setSearchBar];
}

- (void)setSearchBar
{
    _searchBar = [[UISearchBar alloc]init];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    [_searchBar setPlaceholder:@"搜索城市"];
    _searchBar.tintColor = [UIColor whiteColor];
    _searchBar.showsCancelButton = YES;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"icon_search_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [_searchBar setTranslucent:YES];
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.navigationItem.titleView = _searchBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (SearchDestinationRecommendViewController *)searchRecommendViewController
{
    if (!_searchRecommendViewController) {
        _searchRecommendViewController = [[SearchDestinationRecommendViewController alloc] init];
        _searchRecommendViewController.delegate = self;
        _searchRecommendViewController.poiType = kCityPoi;
    }
    return _searchRecommendViewController;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        
        [_tableView registerNib:[UINib nibWithNibName:@"SearchResultTableViewCell" bundle:nil]forCellReuseIdentifier:reusableCellIdentifier];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (void)loadDataSourceWithKeyWord:(NSString *)keyWord
{
    [PoiManager searchPoiWithKeyword:keyWord andSearchCount:20 andPoiType:kCityPoi completionBlock:^(BOOL isSuccess, NSArray *searchResultList) {
        
    }];
}

#pragma mark - UITableViewDataSource 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar endEditing:YES];
    [self.searchRecommendViewController addSearchHistoryText:searchBar.text];
    [self loadDataSourceWithKeyWord:searchBar.text];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        [self.dataSource removeAllObjects];
        [_tableView reloadData];
        _tableView.hidden = YES;
        _searchRecommendViewController.view.hidden = NO;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark- SearchDestinationRecommendDelegate

- (void)didSelectItemWithSearchText:(NSString *)searchText
{
    [_searchBar endEditing:YES];
    [self loadDataSourceWithKeyWord:searchText];
    _searchBar.text = searchText;
}


@end
