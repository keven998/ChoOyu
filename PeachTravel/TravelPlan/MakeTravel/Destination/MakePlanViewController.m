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
#import "TripDetailRootViewController.h"
#import "AccountManager.h"
#import "LoginViewController.h"
#import "SearchDestinationTableViewCell.h"
#import "PXAlertView+Customization.h"
#import "REFrostedViewController.h"
#import "TripPlanSettingViewController.h"
#import "DestinationCollectionViewCell.h"
#import "AreaDestination.h"
#import "MakePlanSearchController.h"
#import "CMPopTipView.h"

@interface MakePlanViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *searchResultArray;

@end

@implementation MakePlanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.shouldOnlyChangeDestinationWhenClickNextStep) {
        self.navigationItem.title = @"修改目的地";
    }
    
    UIBarButtonItem *lbi = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = lbi;
    
    NSString * title = nil;
    if (self.shouldOnlyChangeDestinationWhenClickNextStep) {
        title = @"完成";
    }else{
        title = @"下一步";
    }
    
    UIBarButtonItem *rbi = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(makePlan:)];
    NSMutableDictionary *textAttrs=[NSMutableDictionary dictionary];
    NSMutableDictionary *dTextAttrs = [NSMutableDictionary dictionaryWithDictionary:textAttrs];
    dTextAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
    [rbi setTitleTextAttributes:dTextAttrs forState:UIControlStateDisabled];
    self.navigationItem.rightBarButtonItem = rbi;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupSelectPanel];
    [self setupContentViewController];
    [self beginSearch:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [MobClick beginLogPageView:@"page_select_plan_city"];
    [super viewWillAppear:animated];
       //侧滑navigation bar 补丁
}

- (void)viewWillDisappear:(BOOL)animated
{
    [MobClick endLogPageView:@"page_select_plan_city"];
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    _selectPanel.dataSource = nil;
    _selectPanel.delegate = nil;
    _selectPanel = nil;
    _searchBar = nil;
    _searchController = nil;
}

- (NSMutableArray *)searchResultArray
{
    if (!_searchResultArray) {
        _searchResultArray = [[NSMutableArray alloc] init];
    }
    return _searchResultArray;
}

- (void) setupSelectPanel {
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-49, self.view.frame.size.width, 49)];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    toolBar.layer.shadowColor = COLOR_LINE.CGColor;
    toolBar.layer.shadowOffset = CGSizeMake(0, -1.0);
    toolBar.layer.shadowOpacity = 0.33;
    toolBar.layer.shadowRadius = 1.0;
    [self.view addSubview:toolBar];
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    aFlowLayout.minimumInteritemSpacing = 0;
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.selectPanel = [[UICollectionView alloc] initWithFrame:toolBar.bounds collectionViewLayout:aFlowLayout];
    [self.selectPanel setBackgroundColor:[UIColor whiteColor]];
    self.selectPanel.showsHorizontalScrollIndicator = NO;
    self.selectPanel.showsVerticalScrollIndicator = NO;
    self.selectPanel.delegate = self;
    self.selectPanel.dataSource = self;
    self.selectPanel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.selectPanel.contentInset = UIEdgeInsetsMake(0, 15, 0, 15);
    [self.selectPanel registerNib:[UINib nibWithNibName:@"DestinationCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    [toolBar addSubview:_selectPanel];
    
    UILabel *hintText = [[UILabel alloc] initWithFrame:toolBar.bounds];
    hintText.textColor = TEXT_COLOR_TITLE_HINT;
    hintText.text = @"选择想去的城市";
    hintText.textAlignment = NSTextAlignmentCenter;
    hintText.font = [UIFont systemFontOfSize:14];
    hintText.tag = 1;
    [toolBar addSubview:hintText];
    
    if (self.destinations.destinationsSelected.count == 0) {
        [self hideDestinationBar];
    }else{
        [self showDestinationBar];
    }
}

- (void)setupContentViewController
{
    for (UIViewController *ctl in self.viewControllers) {
        ctl.view.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-49-64);
    }
}

- (void)goBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)beginSearch:(id)sender
{
    [_searchController setActive:YES animated:YES];
    _searchBar.hidden = NO;
}

/**
 *  开始制作攻略
 *
 *  @param sender 
 */
- (IBAction)makePlan:(id)sender
{
    if (!_shouldOnlyChangeDestinationWhenClickNextStep) {
        AccountManager *accountManager = [AccountManager shareAccountManager];
        if ([accountManager isLogin]) {
            [self doMakePlan];
        } else {
            [SVProgressHUD showHint:@"请先登录"];
            [self performSelector:@selector(login) withObject:nil afterDelay:0.25];
        }
    } else {
        [_myDelegate updateDestinations:_destinations.destinationsSelected];
        [self goBack];
    }
}

- (void)doMakePlan
{
    TripDetailRootViewController *tripDetailCtl = [[TripDetailRootViewController alloc] init];
    tripDetailCtl.canEdit = YES;
    tripDetailCtl.destinations = self.destinations.destinationsSelected;
    tripDetailCtl.isMakeNewTrip = YES;
    
    TripPlanSettingViewController *tpvc = [[TripPlanSettingViewController alloc] init];
    
    
     REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:tripDetailCtl menuViewController:tpvc];
     tpvc.rootViewController = tripDetailCtl;
     frostedViewController.direction = REFrostedViewControllerDirectionRight;
     frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
     frostedViewController.liveBlur = YES;
     frostedViewController.limitMenuViewSize = YES;
    
    NSMutableArray *ctls = [NSMutableArray arrayWithArray:self.navigationController.childViewControllers];
    [ctls replaceObjectAtIndex:(ctls.count - 1) withObject:frostedViewController];
    [self.navigationController setViewControllers:ctls animated:YES];
}

- (void)login
{
    LoginViewController *loginViewController = [[LoginViewController alloc] initWithCompletion:^(BOOL islogin){
        [self performSelector:@selector(doMakePlan) withObject:nil afterDelay:0.25];
    }];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginViewController];
    loginViewController.isPushed = NO;
    [self presentViewController:nctl animated:YES completion:nil];
}

- (void)hideDestinationBar
{
    if (!self.shouldOnlyChangeDestinationWhenClickNextStep) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    UIView *view = [self.selectPanel.superview viewWithTag:1];
    view.hidden = NO;
}

- (void)showDestinationBar
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    UIView *view = [self.selectPanel.superview viewWithTag:1];
    view.hidden = YES;
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
    [params setObject:keyWord forKey:@"keyword"];
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
            [SVProgressHUD showHint:@"请求失败"];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        [SVProgressHUD showHint:HTTP_FAILED_HINT];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CityDestinationPoi *city = [self.searchResultArray objectAtIndex:indexPath.row];
    BOOL find = NO;
    for (CityDestinationPoi *cityPoi in _destinations.destinationsSelected) {
        if ([city.cityId isEqualToString:cityPoi.cityId]) {
            find = YES;
            break;
        }
    }
    if (!find) {
        if (_destinations.destinationsSelected.count == 0) {
            [self showDestinationBar];
        }
        [_destinations.destinationsSelected addObject:city];
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

#pragma mark - 实现searchBar的代理方法
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    MakePlanSearchController *searchCtl = [[MakePlanSearchController alloc] init];
    searchCtl.destinations = self.destinations;
    searchCtl.hidesBottomBarWhenPushed = YES;
    [searchCtl setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    TZNavigationViewController *tznavc = [[TZNavigationViewController alloc] initWithRootViewController:searchCtl];
    [self presentViewController:tznavc animated:YES completion:nil];
}



#pragma mark - Collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.destinations.destinationsSelected.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DestinationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    CityDestinationPoi *city = [self.destinations.destinationsSelected objectAtIndex:indexPath.row];
    cell.titleLabel.text = [NSString stringWithFormat:@"%ld.%@", (long)(indexPath.row + 1), city.zhName];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    CityDestinationPoi *city = [_destinations.destinationsSelected objectAtIndex:indexPath.row];
    [_destinations.destinationsSelected removeObjectAtIndex:indexPath.row];
    NSIndexPath *lnp = [NSIndexPath indexPathForItem:indexPath.row inSection:0];
    [_selectPanel performBatchUpdates:^{
        [_selectPanel deleteItemsAtIndexPaths:[NSArray arrayWithObject:lnp]];
    } completion:^(BOOL finished) {
        if (_destinations.destinationsSelected.count == 0) {
            [self hideDestinationBar];
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:updateDestinationsSelectedNoti object:nil userInfo:@{@"city":city}];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CityDestinationPoi *city = [self.destinations.destinationsSelected objectAtIndex:indexPath.row];
    NSString *txt = [NSString stringWithFormat:@"%ld.%@", (long)(indexPath.row + 1), city.zhName];
    CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]}];
    NSLog(@"%@", NSStringFromCGSize(size));
    return CGSizeMake(size.width, 28);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 14;
}

@end





