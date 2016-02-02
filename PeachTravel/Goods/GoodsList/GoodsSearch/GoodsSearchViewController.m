//
//  GoodsSearchViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 12/22/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

#import "GoodsSearchViewController.h"
#import "SearchDestinationRecommendViewController.h"
#import "GoodsListTableViewCell.h"
#import "GoodsManager.h"
#import "GoodsDetailViewController.h"

@interface GoodsSearchViewController () <SearchDestinationRecommendDelegate, UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate>

@property (nonatomic, strong) SearchDestinationRecommendViewController *searchRecommendViewController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation GoodsSearchViewController

static NSString *reusableCellIdentifier = @"goodsListCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addChildViewController:self.searchRecommendViewController];
    [self.view addSubview:self.searchRecommendViewController.view];
    self.searchRecommendViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [self.searchRecommendViewController willMoveToParentViewController:self];
    [self setSearchBar];
    [self.view addSubview:self.tableView];
    _tableView.hidden = YES;
}

- (void)setSearchBar
{
    _searchBar = [[UISearchBar alloc]init];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    [_searchBar setPlaceholder:@"搜索商品"];
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
        _searchRecommendViewController.isSearchGoods = YES;
    }
    return _searchRecommendViewController;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kWindowWidth, kWindowHeight-64)];
        _tableView.backgroundColor = APP_PAGE_COLOR;
        
        [_tableView registerNib:[UINib nibWithNibName:@"GoodsListTableViewCell" bundle:nil] forCellReuseIdentifier:reusableCellIdentifier];
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
    _tableView.hidden = NO;
    [GoodsManager asyncSearchGoodsWithSearchKey:keyWord completionBlock:^(BOOL isSuccess, NSArray *goodsList) {
        if ([goodsList count] == 0) {
            NSString *searchStr = [NSString stringWithFormat:@"没有找到“%@”的相关结果", _searchBar.text];
            [SVProgressHUD showHint:searchStr];
        }
        _dataSource = [goodsList mutableCopy];
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 108;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoodsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goodsListCell" forIndexPath:indexPath];
    cell.goodsDetail = [_dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GoodsDetailViewController *ctl = [[GoodsDetailViewController alloc] init];
    GoodsDetailModel *goodsDetail = [_dataSource objectAtIndex:indexPath.row];
    ctl.goodsId = goodsDetail.goodsId;
    [self.navigationController pushViewController:ctl animated:YES];
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
