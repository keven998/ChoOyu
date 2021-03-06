//
//  AddContactTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/29.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "AddContactTableViewController.h"
#import "AddressBookTableViewController.h"
#import "UMSocialWechatHandler.h"
#import "UMSocial.h"
#import "AccountManager.h"
#import "SearchUserInfoViewController.h"
#import "ConvertMethods.h"
#import "SearchFrendTableViewController.h"

#define searchCell          @"searchContactCell"
#define normalCell          @"normalCell"

@interface AddContactTableViewController() <UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) NSArray *normalDataSource;

@end

@implementation AddContactTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加朋友";
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"common_icon_navigation_back_normal"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_icon_navigation_back_highlight"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 25, 30)];
    
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:normalCell];
    self.tableView.separatorColor = COLOR_LINE;
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 49)];
    searchBar.placeholder = @"昵称/手机号";
    [searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"icon_search_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    searchBar.backgroundImage = [ConvertMethods createImageWithColor:[UIColor whiteColor]];
    self.tableView.tableHeaderView = searchBar;
    
    //在searchbar上覆盖一层假的 button，点击进入下个搜索界面
    UIButton *searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 49)];
    [searchBtn addTarget:self action:@selector(searchFrend:)forControlEvents:UIControlEventTouchUpInside];
    [searchBar addSubview:searchBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_add_friend"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_add_friend"];
}

#pragma mark - setter & getter

- (NSArray *)normalDataSource
{
    if (!_normalDataSource) {
        _normalDataSource = @[@"通讯录朋友", @"邀请微信朋友"];
    }
    return _normalDataSource;
}

#pragma mark - Private Methods

- (void)searchFrend:(id)sender
{
    SearchFrendTableViewController *ctl = [[SearchFrendTableViewController alloc] init];
    ctl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:ctl] animated:YES completion:nil];
}

- (void)shareToWeChat
{
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:[NSString stringWithFormat:@"我正在用旅行派，搜索: %@ 加我", [AccountManager shareAccountManager].account.nickName] image:nil location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess) {
            NSLog(@"分享成功！");
        }
    }];
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.normalDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:normalCell forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.textColor = COLOR_TEXT_I;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.normalDataSource[indexPath.row];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        AddressBookTableViewController *addressBookCtl = [[AddressBookTableViewController alloc] init];
        [MobClick event:@"cell_item_add_lxp_friends_from_contacts"];
        [self.navigationController pushViewController:addressBookCtl animated:YES];
    }
    if (indexPath.row == 1) {
        [self shareToWeChat];
        [MobClick event:@"cell_item_add_lxp_friends_from_weichat"];

    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
