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

@interface MakePlanViewController () <UISearchBarDelegate, UISearchControllerDelegate, UITableViewDataSource, UITableViewDelegate, DestinationToolBarDelegate>

@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIButton *searchBtn;

@end

@implementation MakePlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"想去的城市";
    
    self.view.backgroundColor = [UIColor whiteColor];
    _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(20, 20, self.view.bounds.size.width-40, 38)];
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.delegate = self;
    [_searchBar setPlaceholder:@"请输入城市名或拼音"];
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _searchBar.translucent = YES;
    _searchBar.showsCancelButton = YES;
    _searchController = [[UISearchDisplayController alloc]initWithSearchBar:_searchBar contentsController:self];
    _searchController.active = NO;
    _searchController.searchResultsDataSource = self;
    _searchController.searchResultsDelegate = self;
    
    [self.view addSubview:_searchBar];

    _searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [_searchBtn setTitleColor:UIColorFromRGB(0xee528c) forState:UIControlStateNormal];
    [_searchBtn addTarget:self action:@selector(beginSearch:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_searchBtn];
    
    [self.view addSubview:self.destinationToolBar];
    [self.view addSubview:self.nextView];
    
}

- (DestinationToolBar *)destinationToolBar
{
    if (!_destinationToolBar) {
        _destinationToolBar = [[DestinationToolBar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-49, self.view.bounds.size.width-62.5, 49) andNextBtnTitle:nil];

        _destinationToolBar.backgroundColor = [APP_THEME_COLOR colorWithAlphaComponent:0.9];
        _destinationToolBar.delegate = self;
    }
    return _destinationToolBar;
}

- (UIView *)nextView
{
    if (!_nextView) {
        _nextView = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-62.5, self.view.bounds.size.height-76, 62.5, 76)];

        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 27, 62.5, 49)];
        imageView.image = [UIImage imageNamed:@"ic_next_step.png"];
        UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(4.5, 13, 54, 54)];
        nextBtn.layer.cornerRadius = 27.0;
        nextBtn.backgroundColor = [APP_THEME_COLOR colorWithAlphaComponent:0.9];
        [nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        nextBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
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
}

/**
 *  开始制作攻略
 *
 *  @param sender 
 */
- (IBAction)makePlan:(id)sender
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        TripDetailRootViewController *tripDetailCtl = [[TripDetailRootViewController alloc] init];
        CityDestinationPoi *poi = [[CityDestinationPoi alloc] init];
        poi.cityId = @"5473ccd7b8ce043a64108c46";
        poi.zhName = @"北京";
        CityDestinationPoi *poi1 = [[CityDestinationPoi alloc] init];
        poi1.cityId = @"546f2daab8ce0440eddb2aff";
        poi1.zhName = @"上海大不列颠";
        tripDetailCtl.destinations = @[poi, poi1];
        tripDetailCtl.isMakeNewTrip = YES;
        [self.navigationController pushViewController:tripDetailCtl animated:YES];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
        [self performSelector:@selector(login) withObject:nil afterDelay:0.3];
    }
}

- (void)login
{
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    UINavigationController *nctl = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    loginViewController.isPushed = NO;
    [self presentViewController:nctl animated:YES completion:nil];
}

- (void)hideDestinationBar
{
    [UIView animateWithDuration:0.3 animations:^{
        self.nextView.alpha = 0.2;
        self.destinationToolBar.alpha = 0.2;
    } completion:^(BOOL finished) {
        self.nextView.alpha = 0;
        self.destinationToolBar.alpha = 0;
    }];
}

- (void)showDestinationBar
{
    [UIView animateWithDuration:0.3 animations:^{
        self.nextView.alpha = 0.8;
        self.destinationToolBar.alpha = 0.8;
    } completion:^(BOOL finished) {
        self.nextView.alpha = 1;
        self.destinationToolBar.alpha = 1;
    }];
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

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


@end






