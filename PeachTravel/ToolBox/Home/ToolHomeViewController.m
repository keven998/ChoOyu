//
//  ToolHomeViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 15/4/8.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

#import "ToolHomeViewController.h"
#import "HotDestinationCollectionViewController.h"
#import "MyGuideListTableViewController.h"
#import "LocalViewController.h"
#import "LoginViewController.h"
#import "TravelersTableViewController.h"
#import "SearchDestinationViewController.h"

@interface ToolHomeViewController ()<UISearchBarDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation ToolHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"旅行";
    
//    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.separatorColor = APP_BORDER_COLOR;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tool_cell"];
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 45)];
    _searchBar.delegate = self;
//    _searchBar.barTintColor = APP_PAGE_COLOR;
    [_searchBar setBackgroundImage:[UIImage imageNamed:@"app_background.png"]];
    _searchBar.placeholder = @"城市、景点、酒店、美食、游记";
    self.tableView.tableHeaderView = _searchBar;
}

- (IBAction)hideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - ScrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    SearchDestinationViewController *searchCtl = [[SearchDestinationViewController alloc] init];
    searchCtl.hidesBottomBarWhenPushed = YES;
    searchCtl.titleStr = @"旅行搜搜";
    [self.navigationController pushViewController:searchCtl animated:YES];
    return NO;
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *view = [[UIView alloc] init];
//    view.backgroundColor = APP_PAGE_COLOR;
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tool_cell" forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.textColor = TEXT_COLOR_TITLE;
    if (indexPath.section == 0) {
        cell.textLabel.text = @"达人指路";
        cell.imageView.image = [UIImage imageNamed:@"ic_gender_man.png"];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"旅程计划";
            cell.imageView.image = [UIImage imageNamed:@"ic_gender_man.png"];
        } else {
            cell.textLabel.text = @"身边哪好玩";
            cell.imageView.image = [UIImage imageNamed:@"ic_gender_man.png"];
        }
    } else {
        cell.textLabel.text = @"目的地";
        cell.imageView.image = [UIImage imageNamed:@"ic_gender_man.png"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TravelersTableViewController *ttvc = [[TravelersTableViewController alloc] init];
        ttvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:ttvc animated:YES];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self myTravelPlans];
        } else {
            [MobClick event:@"event_locality"];
            LocalViewController *lvc = [[LocalViewController alloc] init];
            lvc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:lvc animated:YES];
        }
    } else {
        HotDestinationCollectionViewController *hcvc = [[HotDestinationCollectionViewController alloc] init];
        hcvc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:hcvc animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/**
 *  我的攻略列表
 *
 *  @param sender
 */
- (IBAction)myTravelPlans {
    [MobClick event:@"event_my_trip_plans"];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if (!accountManager.isLogin) {
        [self performSelector:@selector(goLogin) withObject:nil afterDelay:0.3];
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
    } else {
        MyGuideListTableViewController *myGuidesCtl = [[MyGuideListTableViewController alloc] init];
        myGuidesCtl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:myGuidesCtl animated:YES];
    }
}

/**
 *  登录
 *
 *  @param sender
 */
- (IBAction)goLogin
{
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
    loginCtl.isPushed = NO;
    [self.navigationController presentViewController:nctl animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
