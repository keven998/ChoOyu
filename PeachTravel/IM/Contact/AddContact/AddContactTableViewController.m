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
#import "ContactDetailViewController.h"
#import "OtherUserInfoViewController.h"

#define searchCell          @"searchContactCell"
#define normalCell          @"normalCell"

@interface AddContactTableViewController() <UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchTableViewController;

@property (strong, nonatomic) NSArray *normalDataSource;
@property (strong, nonatomic) NSMutableArray *searchDataSource;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) UIViewController *nextViewController;

@end

@implementation AddContactTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"添加";
    [self.searchTableViewController.searchResultsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:searchCell];
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
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:[NSString stringWithFormat:@"我正在用旅行派，搜索: %@ 加我", [AccountManager shareAccountManager].account.nickName] image:nil location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
        if (response.responseCode == UMSResponseCodeSuccess) {
            NSLog(@"分享成功！");
        }
    }];
}

- (void)searchUsersWithSearchText:(NSString *)searchText
{
    if (searchText.length == 0) {
        [SVProgressHUD showHint:@"你想找谁呢～"];
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:(kWindowWidth-22)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:searchText forKey:@"keyword"];
    
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(AddContactTableViewController *)weakSelf = self;
    [hud showHUDInViewController:weakSelf];
    //搜索好友
    [manager GET:API_SEARCH_USER parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hideTZHUD];
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self parseSearchResult:[responseObject objectForKey:@"result"]];
        } else {
            [SVProgressHUD showHint:[[responseObject objectForKey:@"err"] objectForKey:@"message"]];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hideTZHUD];
        if (self.isShowing) {
            [SVProgressHUD showHint:@"呃～好像没找到网络"];
        }
    }];
}

- (void)parseSearchResult:(id)searchResult
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([searchResult count] > 0) {
        NSInteger userId = [[[searchResult firstObject] objectForKey:@"userId"] integerValue];
        if (userId == [accountManager.account.userId integerValue]) {
            [SVProgressHUD showHint:@"不能添加自己到通讯录"];
        } else {
            [_searchBar resignFirstResponder];
              
            //如果已经是好友了，进入好友详情界面
            for (Contact *contact in accountManager.account.contacts) {
                if ([contact.userId integerValue] == userId) {
//                    ContactDetailViewController *contactDetailCtl = [[ContactDetailViewController alloc] init];
                    OtherUserInfoViewController *contactDetailCtl = [[OtherUserInfoViewController alloc]init];
                    contactDetailCtl.userId = contact.userId;
                    _nextViewController = contactDetailCtl;
                    [self performSelector:@selector(jumpToNextCtl) withObject:nil afterDelay:0.3];
                    return;
                }
            }
            OtherUserInfoViewController *otherCtl = [[OtherUserInfoViewController alloc]init];
            otherCtl.userId = [NSNumber numberWithInteger:userId];
            _nextViewController = otherCtl;
            [self performSelector:@selector(jumpToNextCtl) withObject:nil afterDelay:0.3];
        }
    } else {
        [SVProgressHUD showHint:@"没有找到她~"];
    }
}

- (void)jumpToNextCtl
{
    [self.navigationController pushViewController:_nextViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([tableView isEqual: _searchTableViewController.searchResultsTableView ]) {
        return 1;
    }
    return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if ([tableView isEqual:_searchTableViewController.searchResultsTableView]) {
//        return 0;
//    }
//    return 12.0;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.0;
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
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:normalCell];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:normalCell];
            if (indexPath.row == 0) {
                UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0.0, 47.5, tableView.frame.size.width, 0.5)];
                divider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                divider.backgroundColor = UIColorFromRGB(0xdddddd);
                [cell.contentView addSubview:divider];
            }
            cell.textLabel.font = [UIFont systemFontOfSize:15.0];
            cell.textLabel.textColor = TEXT_COLOR_TITLE;
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = self.normalDataSource[indexPath.row];
        return cell;
    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if ([tableView isEqual:_searchTableViewController.searchResultsTableView]) {
//        return nil;
//    }
//    UIView *view = [[UIView alloc] init];
//    view.backgroundColor = APP_PAGE_COLOR;
//    return view;
//}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _searchTableViewController.searchResultsTableView) {
        
    } else {
        if (indexPath.row == 0) {
            [MobClick event:@"event_add_friend_from_contacts"];
            AddressBookTableViewController *addressBookCtl = [[AddressBookTableViewController alloc] init];
            [self.navigationController pushViewController:addressBookCtl animated:YES];
        }
        if (indexPath.row == 1) {
            [MobClick event:@"event_notify_weichat_friends"];
            [self shareToWeChat];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchUsersWithSearchText:searchBar.text];
    [MobClick event:@"event_search_friend"];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
      
}

@end
