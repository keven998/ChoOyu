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
    
    self.navigationItem.title = @"选择目的地";
    
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
    
}

- (DestinationToolBar *)destinationToolBar
{
    if (!_destinationToolBar) {
        _destinationToolBar = [[DestinationToolBar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50) andNextBtnTitle:@"下一步"];
        [_destinationToolBar.nextBtn addTarget:self action:@selector(makePlan:) forControlEvents:UIControlEventTouchUpInside];
        _destinationToolBar.delegate = self;
    }
    return _destinationToolBar;
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
        poi.cityId = @"54756008d17491193832582d";
        poi.zhName = @"北京";
        CityDestinationPoi *poi1 = [[CityDestinationPoi alloc] init];
        poi1.cityId = @"5475b938d174911938325835";
        poi1.zhName = @"上海大不列颠";
        tripDetailCtl.destinations = @[poi, poi1];
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

#pragma mark - DestinationToolBarDelegate

- (void)removeUintCell:(NSInteger)index
{
    CityDestinationPoi *city = [_destinations.destinationsSelected objectAtIndex:index];
    [_destinations.destinationsSelected removeObjectAtIndex:index];
    [[NSNotificationCenter defaultCenter] postNotificationName:updateDestinationsSelectedNoti object:nil userInfo:@{@"city":city}];
    if (_destinations.destinationsSelected.count == 0) {
        [_destinationToolBar setHidden:YES withAnimation:YES];
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






