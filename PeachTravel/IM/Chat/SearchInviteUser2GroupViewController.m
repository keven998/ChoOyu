//
//  SearchInviteUser2GroupViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 7/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "SearchInviteUser2GroupViewController.h"
#import "OtherProfileViewController.h"
#import "ContactListTableViewCell.h"

@interface SearchInviteUser2GroupViewController () <UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIViewController *nextViewController;
@end

@implementation SearchInviteUser2GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorColor = COLOR_LINE;
    [self.tableView registerNib:[UINib nibWithNibName:@"ContactListTableViewCell" bundle:nil] forCellReuseIdentifier:@"contactCell"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    _searchBar = [[UISearchBar alloc]init];
    _searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchBar.delegate = self;
    [_searchBar setPlaceholder:@"昵称/手机号"];
    _searchBar.tintColor = COLOR_TEXT_II;
    _searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    [_searchBar setSearchFieldBackgroundImage:[[UIImage imageNamed:@"icon_search_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    _searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.navigationItem.titleView = _searchBar;
    _searchBar.delegate = self;
    [_searchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchUsersWithSearchText:(NSString *)searchText
{
    if (searchText.length == 0) {
        [SVProgressHUD showHint:@"你想找谁呢～"];
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:(kWindowWidth-22)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:searchText forKey:@"query"];
    
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    __weak typeof(SearchInviteUser2GroupViewController *)weakSelf = self;
    [hud showHUDInViewController:weakSelf];
    //搜索好友
    [LXPNetworking GET:API_SEARCH_USER parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    _dataSource = [[NSMutableArray alloc] init];
    if ([searchResult count] > 0) {
        for (NSDictionary *dic in searchResult) {
            FrendModel *frend = [[FrendModel alloc] initWithJson:dic];
            [_dataSource addObject:frend];
        }
        [self.tableView reloadData];
        [_searchBar resignFirstResponder];
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
    return 55.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    FrendModel *contact = [_dataSource objectAtIndex:indexPath.row];
    
    if (![contact.avatarSmall isBlankString]) {
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatarSmall] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    } else {
        [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:contact.avatar] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
    }
    
    if (contact.memo.length > 0) {
        cell.nickNameLabel.text = contact.memo;
    } else {
        cell.nickNameLabel.text = contact.nickName;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FrendModel *contact = [_dataSource objectAtIndex:indexPath.row];
    [_rootViewController didSelectContact:contact];
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
