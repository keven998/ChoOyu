//
//  SuggestionDestinationTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 5/30/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "SuggestionDestinationTableViewController.h"



@interface SuggestionDestinationTableViewController () <UISearchBarDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;

/**
 *  联想的城市数据
 */
@property (nonatomic, strong) NSMutableArray *searchResultArray;


@end

@implementation SuggestionDestinationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"确定所在城市";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.separatorColor = COLOR_LINE;
    
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    _searchBar.backgroundColor = [UIColor whiteColor];
    [_searchBar setPlaceholder:@"输入城市名或拼音"];
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchBar.showsCancelButton = NO;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"suggestCell"];
    self.tableView.tableHeaderView = _searchBar;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_searchBar endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)searchResultArray
{
    if (!_searchResultArray) {
        _searchResultArray = [[NSMutableArray alloc] init];
    }
    return _searchResultArray;
}

- (void) cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  搜索城市的时候联想查询
 */
- (void)loadSuggestionData
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params safeSetObject:_searchBar.text forKey:@"keyword"];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageSize"];
    [params setObject:[NSNumber numberWithInt:0] forKey:@"page"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"loc"];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [manager GET:API_SUGGESTION parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self analysisSearchData:[responseObject objectForKey:@"result"]];
            [self.tableView reloadData];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showHint:@"呃～好像没找到网络"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}

- (void)analysisSearchData:(id)json
{
    [self.searchResultArray removeAllObjects];
    for (id dic in [json objectForKey:@"locality"]) {
        CityDestinationPoi *loc = [[CityDestinationPoi alloc] initWithJson:dic];
        [self.searchResultArray addObject:loc];
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
    return _searchResultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CityDestinationPoi *poi = [self.searchResultArray objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"suggestCell"];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.text = poi.zhName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CityDestinationPoi *cityPoi = [self.searchResultArray objectAtIndex:indexPath.row];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate didSelectDestination:cityPoi];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_searchBar endEditing:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [_searchBar endEditing:YES];
}

#pragma mark - UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText != nil && ![searchText isBlankString]) {
        [self loadSuggestionData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _searchBar.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
