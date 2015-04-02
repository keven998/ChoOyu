//
//  MakePlanViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 11/18/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "MakePlanViewController.h"
#import "DomesticViewController.h"
#import "ForeignViewController.h"
#import "DestinationToolBar.h"
#import "TripDetailRootViewController.h"
#import "AccountManager.h"
#import "LoginViewController.h"
#import "SearchDestinationTableViewCell.h"

@interface MakePlanViewController () <UISearchBarDelegate, UISearchControllerDelegate,UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, DestinationToolBarDelegate>

@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *searchResultArray;

@end

@implementation MakePlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"ic_navigation_back.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 48, 30)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:TEXT_COLOR_TITLE forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont systemFontOfSize:17.0];
    button.titleEdgeInsets = UIEdgeInsetsMake(2, 1, 0, 0);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.view.backgroundColor = [UIColor whiteColor];
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(20, 20, self.view.bounds.size.width-40, 38)];
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.delegate = self;
    [_searchBar setPlaceholder:@"输入城市名或拼音"];
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _searchBar.translucent = YES;
    _searchBar.showsCancelButton = YES;
    _searchBar.hidden = YES;
    _searchController = [[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
    _searchController.active = NO;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsDelegate = self;
    [_searchController.searchResultsTableView registerNib:[UINib nibWithNibName:@"SearchDestinationTableViewCell" bundle:nil] forCellReuseIdentifier:@"searchCell"];
    _searchController.delegate = self;
    
    [self.view addSubview:_searchBar];
    
    UIBarButtonItem * searchBtn = [[UIBarButtonItem alloc]initWithTitle:@"搜索 " style:UIBarButtonItemStyleBordered target:self action:@selector(beginSearch:)];
    searchBtn.tintColor = APP_THEME_COLOR;
    
    [self.view addSubview:self.destinationToolBar];
    
    for (CityDestinationPoi *poi in self.destinations.destinationsSelected) {
        [self.destinationToolBar addUnit:@"ic_cell_item_unchoose" withName:poi.zhName andUnitHeight:26];
    }
    [self.view addSubview:self.nextView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_destinations"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_destinations"];
}

- (void)dealloc {
    _destinationToolBar = nil;
    _searchBar = nil;
    _searchController = nil;
}

- (DestinationToolBar *)destinationToolBar
{
    if (!_destinationToolBar) {
        _destinationToolBar = [[DestinationToolBar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-49.5, self.view.bounds.size.width-62.5, 49.5) andNextBtnTitle:nil];
        _destinationToolBar.backgroundColor = APP_SUB_THEME_COLOR;
        _destinationToolBar.delegate = self;
    }
    return _destinationToolBar;
}
- (NSMutableArray *)searchResultArray
{
    if (!_searchResultArray) {
        _searchResultArray = [[NSMutableArray alloc] init];
    }
    return _searchResultArray;
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)nextView
{
    if (!_nextView) {
        _nextView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-62.5, self.view.bounds.size.height-76, 62.5, 76)];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 27, 62.5, 49)];
        imageView.backgroundColor = APP_SUB_THEME_COLOR;
        UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(4.5, 13, 54, 54)];
        nextBtn.layer.cornerRadius = 27.0;
        nextBtn.layer.borderWidth = 2.0;
        nextBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        [nextBtn setBackgroundImage:[ConvertMethods createImageWithColor:APP_SUB_THEME_COLOR] forState:UIControlStateNormal];
        [nextBtn setImage:[UIImage imageNamed:@"ic_select_dest_done.png"] forState:UIControlStateNormal];
        nextBtn.clipsToBounds = YES;
        [nextBtn addTarget:self action:@selector(makePlan:) forControlEvents:UIControlEventTouchUpInside];
        [_nextView addSubview:imageView];
        [_nextView addSubview:nextBtn];
    }
    return _nextView;
}

- (IBAction)beginSearch:(id)sender
{
    [_searchBar setFrame:CGRectMake(0, 20, self.view.bounds.size.width-40, 38)];
    [_searchController setActive:YES animated:YES];
    _searchBar.hidden = NO;
}

/**
 *  重写父类方法
 */
- (void)finishSwithPages
{
    [self.view bringSubviewToFront:_destinationToolBar];
    [self.view bringSubviewToFront:_nextView];
    if (self.selectedIndext == 1) {
        [MobClick event:@"event_go_aboard"];
    }
}

/**
 *  开始制作攻略
 *
 *  @param sender 
 */
- (IBAction)makePlan:(id)sender
{
    [MobClick event:@"event_select_done_go_next"];
    if (!_shouldOnlyChangeDestinationWhenClickNextStep) {
        AccountManager *accountManager = [AccountManager shareAccountManager];
        if ([accountManager isLogin]) {
            TripDetailRootViewController *tripDetailCtl = [[TripDetailRootViewController alloc] init];
            tripDetailCtl.canEdit = YES;
            tripDetailCtl.destinations = self.destinations.destinationsSelected;
            tripDetailCtl.isMakeNewTrip = YES;
            tripDetailCtl.hidesBottomBarWhenPushed = YES;
            NSMutableArray *array = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            [array replaceObjectAtIndex:(array.count - 1) withObject:tripDetailCtl];
            
            [self.navigationController setViewControllers:array animated:YES];
        } else {
            [SVProgressHUD showHint:@"请先登录"];
            [self performSelector:@selector(login) withObject:nil afterDelay:0.3];
        }
    } else {
        [_myDelegate updateDestinations:_destinations.destinationsSelected];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)login
{
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    UINavigationController *nctl = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    loginViewController.isPushed = NO;
    [nctl.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bkg.png"] forBarMetrics:UIBarMetricsDefault];
    nctl.navigationBar.translucent = YES;
    [self presentViewController:nctl animated:YES completion:nil];
}

- (void)hideDestinationBar
{
    [UIView animateWithDuration:0.3 animations:^{
        self.nextView.alpha = 0.0;
        self.destinationToolBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.nextView.alpha = 0;
        self.destinationToolBar.alpha = 0;
    }];
}

- (void)showDestinationBar
{
    [UIView animateWithDuration:0.0 animations:^{
        self.nextView.alpha = 1.0;
        self.destinationToolBar.alpha = 1.0;
    } completion:^(BOOL finished) {
    }];
}

/**
 *  开始搜索
 */
- (void)loadDataSourceWithKeyWord:(NSString *)keyWord
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:keyWord forKey:@"keyWord"];
    [params setObject:[NSNumber numberWithBool:YES] forKey:@"loc"];
    [params setObject:[NSNumber numberWithBool:NO] forKey:@"vs"];
    [params setObject:[NSNumber numberWithBool:NO] forKey:@"restaurant"];
    [params setObject:[NSNumber numberWithBool:NO] forKey:@"hotel"];
    [params setObject:[NSNumber numberWithBool:NO] forKey:@"shopping"];
    [params setObject:[NSNumber numberWithInt:15] forKey:@"pageCnt"];
    
     __weak typeof(MakePlanViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    [hud showHUD];
    
    [manager GET:API_SEARCH parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self analysisData:[responseObject objectForKey:@"result"]];
        } else {
            [SVProgressHUD showHint:@"请求也是失败了"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        [SVProgressHUD showHint:@"呃～好像没找到网络"];
    }];
    
}

- (void)analysisData:(id)json
{
    [self.searchResultArray removeAllObjects];
    for (id dic in [json objectForKey:@"locality"]) {
        CityDestinationPoi *poi = [[CityDestinationPoi alloc] initWithJson:dic];
        [self.searchResultArray addObject:poi];
    }
    [self.searchController.searchResultsTableView reloadData];
}

#pragma mark - DestinationToolBarDelegate

- (void)removeUintCell:(NSInteger)index
{
    CityDestinationPoi *city = [_destinations.destinationsSelected objectAtIndex:index];
    [_destinations.destinationsSelected removeObjectAtIndex:index];
    [[NSNotificationCenter defaultCenter] postNotificationName:updateDestinationsSelectedNoti object:nil userInfo:@{@"city":city}];
    if (_destinations.destinationsSelected.count == 0) {
        [self hideDestinationBar];
    }
}

#pragma mark - tableview datasource & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResultArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CityDestinationPoi *city = [self.searchResultArray objectAtIndex:indexPath.row];
    SearchDestinationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchCell" forIndexPath:indexPath];
    CityDestinationPoi *poi = [self.searchResultArray objectAtIndex:indexPath.row];
    cell.titleLabel.text = poi.zhName;
    BOOL find = NO;
    for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
        if ([city.cityId isEqualToString:cityPoi.cityId]) {
            find = YES;
            break;
        }
    }
    cell.statusBtn.selected = find;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"event_select_city"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CityDestinationPoi *city = [self.searchResultArray objectAtIndex:indexPath.row];
    BOOL find = NO;
    for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
        if ([city.cityId isEqualToString:cityPoi.cityId]) {
            NSInteger index = [_destinations.destinationsSelected indexOfObject:cityPoi];
            [self.destinationToolBar removeUnitAtIndex:index];
            find = YES;
            break;
        }
    }
    if (!find) {
        if (_destinations.destinationsSelected.count == 0) {
            [self showDestinationBar];
        }
        [_destinations.destinationsSelected addObject:city];
        [self.destinationToolBar addUnit:@"ic_cell_item_unchoose" withName:city.zhName andUnitHeight:26];
    }
    
    SearchDestinationTableViewCell *cell = (SearchDestinationTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.statusBtn.selected = !cell.statusBtn.selected;
    DomesticViewController *domesticCtl = [self.viewControllers firstObject];
    [domesticCtl reloadData];
    ForeignViewController *foreignCtl = [self.viewControllers lastObject];
    [foreignCtl reloadData];
    
    [self performSelector:@selector(dismissSVC) withObject:nil afterDelay:1.1];
}

- (void) dismissSVC {
    [_searchController setActive:NO animated:YES];
}

#pragma mark - searchBar

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchResultArray removeAllObjects];
    _searchBar.hidden = YES;
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    _searchBar.hidden = YES;
    [self.searchResultArray removeAllObjects];
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [_searchController.searchBar becomeFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self loadDataSourceWithKeyWord:searchBar.text];
}

@end






