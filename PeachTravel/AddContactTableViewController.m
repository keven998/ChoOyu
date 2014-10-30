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

#define searchCell          @"searchContactCell"
#define normalCell          @"normalCell"

@interface AddContactTableViewController ()

@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchTableViewController;

@property (strong, nonatomic) NSArray *normalDataSource;
@property (strong, nonatomic) NSMutableArray *searchDataSource;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation AddContactTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"添加好友";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:normalCell];
    [self.searchTableViewController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:searchCell];

}

#pragma mark - setter & getter

- (NSArray *)normalDataSource
{
    if (!_normalDataSource) {
        _normalDataSource = @[@"手机通讯录", @"邀请微信好友"];
    }
    return _normalDataSource;
}

- (NSMutableArray *)searchDataSource
{
    if (!_searchDataSource) {
        _searchDataSource = [[NSMutableArray alloc] init];
    }
    return _searchDataSource;
}

#pragma mark - Private Methods

- (void)shareToWeChat
{
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:@"hei, 下载我们的桃子旅行吧，可以聊天泡妞哦" image:nil location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess) {
            NSLog(@"分享成功！");
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == _searchTableViewController.searchResultsTableView) {
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _searchTableViewController.searchResultsTableView) {
        return self.searchDataSource.count;
    } else {
        return  self.normalDataSource.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _searchTableViewController.searchResultsTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCell forIndexPath:indexPath];
        cell.textLabel.text = @"cell";
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:normalCell forIndexPath:indexPath];
        cell.textLabel.text = self.normalDataSource[indexPath.row];
        return cell;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _searchTableViewController.searchResultsTableView) {
        
    } else {
        if (indexPath.row == 0) {
            AddressBookTableViewController *addressBookCtl = [[AddressBookTableViewController alloc] init];
            [self.navigationController pushViewController:addressBookCtl animated:YES];
        }
        if (indexPath.row == 1) {
            [self shareToWeChat];
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
