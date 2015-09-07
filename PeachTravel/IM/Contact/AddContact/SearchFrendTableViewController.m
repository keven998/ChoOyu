//
//  SearchFrendTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "SearchFrendTableViewController.h"
#import "OtherUserInfoViewController.h"

@interface SearchFrendTableViewController () <UISearchBarDelegate>

@property (nonatomic, strong) NSArray *dataSource;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIViewController *nextViewController;
@end

@implementation SearchFrendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _searchBar = [[UISearchBar alloc]init];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_searchBar setPlaceholder:@"昵称/用户ID/手机号"];
    _searchBar.tintColor = COLOR_TEXT_II;
       _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"icon_search_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    _searchBar.showsCancelButton = YES;
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.navigationItem.titleView = _searchBar;
    _searchBar.delegate = self;
    [_searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    [params setObject:searchText forKey:@"query"];
    
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(SearchFrendTableViewController *)weakSelf = self;
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
        [SVProgressHUD showHint:HTTP_FAILED_HINT];
    }];
}

- (void)parseSearchResult:(id)searchResult
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([searchResult count] > 0) {
        NSInteger userId = [[[searchResult firstObject] objectForKey:@"userId"] integerValue];
        if (userId == accountManager.account.userId) {
            [SVProgressHUD showHint:@"不能添加自己到通讯录"];
        } else {
            [_searchBar resignFirstResponder];
            
            //如果已经是好友了，进入好友详情界面
            if ([accountManager frendIsMyContact:userId]) {
                OtherUserInfoViewController *contactDetailCtl = [[OtherUserInfoViewController alloc]init];
                contactDetailCtl.userId = userId;
                _nextViewController = contactDetailCtl;
                [self performSelector:@selector(jumpToNextCtl) withObject:nil afterDelay:0.3];
                return;
            }
            OtherUserInfoViewController *otherCtl = [[OtherUserInfoViewController alloc]init];
            otherCtl.userId = userId;
            _nextViewController = otherCtl;
            [self performSelector:@selector(jumpToNextCtl) withObject:nil afterDelay:0.3];
        }
    } else {
        [SVProgressHUD showHint:@"没有找到他~"];
    }
}

- (void)jumpToNextCtl
{
    [self.navigationController pushViewController:_nextViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.textLabel.text = @"cell";
        return cell;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchUsersWithSearchText:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
