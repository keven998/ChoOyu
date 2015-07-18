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
#import "OtherUserInfoViewController.h"
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
    self.title = @"添加好友";
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"common_icon_navigaiton_back_highlight"] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(goBack)forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 25, 30)];
    
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    UIButton *searchBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setImage:[UIImage imageNamed:@"search.png"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchFrend:)forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setFrame:CGRectMake(0, 0, 25, 30)];
    
    searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:normalCell];
    self.tableView.separatorColor = COLOR_LINE;
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
        _normalDataSource = @[@"通讯录好友", @"邀请微信好友"];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.0;
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
        [MobClick event:@"event_add_friend_from_contacts"];
        AddressBookTableViewController *addressBookCtl = [[AddressBookTableViewController alloc] init];
        [self.navigationController pushViewController:addressBookCtl animated:YES];
    }
    if (indexPath.row == 1) {
        [MobClick event:@"event_notify_weichat_friends"];
        [self shareToWeChat];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
