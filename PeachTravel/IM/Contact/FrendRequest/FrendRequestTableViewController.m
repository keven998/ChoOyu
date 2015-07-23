//
//  FrendRequestTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/11/1.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "FrendRequestTableViewController.h"
#import "FrendRequestTableViewCell.h"
#import "FrendRequest.h"
#import "AccountManager.h"
#import "OtherUserInfoViewController.h"
#import "PeachTravel-swift.h"

#define requestCell      @"requestCell"

@interface FrendRequestTableViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) AccountManager *accountManager;

@end

@implementation FrendRequestTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"新朋友";
    [self.tableView registerNib:[UINib nibWithNibName:@"FrendRequestTableViewCell" bundle:nil] forCellReuseIdentifier:requestCell];
    self.tableView.separatorColor = COLOR_LINE;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_ask_for_friend"];
}

/**
 *  页面消失的时候通知上一个界面将未读数清0
 *
 *  @param animated <#animated description#>
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_ask_for_friend"];
    
}

#pragma mark - setter & getter

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        NSComparator cmptr = ^(FrendRequest *obj1, FrendRequest *obj2) {
            if (obj1.requestDate < obj2.requestDate) {
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }
        };
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        for (id request in [IMClientManager shareInstance].frendRequestManager.frendRequestList) {
            [tempArray addObject:request];
        }
        _dataSource = [[tempArray sortedArrayUsingComparator:cmptr] mutableCopy];
    }
    return _dataSource;
}

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
}

#pragma mark - Private Methods

- (void)updateDataSource
{
    [self.dataSource removeAllObjects];
    NSComparator cmptr = ^(FrendRequest *obj1, FrendRequest *obj2) {
        if (obj1.requestDate < obj2.requestDate) {
            return NSOrderedDescending;
        } else {
            return NSOrderedAscending;
        }
    };
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (id request in self.accountManager.account.frendRequest) {
        [tempArray addObject:request];
    }
    _dataSource = [[tempArray sortedArrayUsingComparator:cmptr] mutableCopy];
}

- (void)addContactWithFrendRequest:(FrendRequest *)frendRequest
{
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUD];
    [[IMClientManager shareInstance].frendManager asyncAgreeAddContactWithRequestId:frendRequest.requestId completion:^(BOOL isSuccess, NSInteger errorCode) {
        [hud hideTZHUD];
        if (isSuccess) {
            [self.tableView reloadData];
            [SVProgressHUD showHint:@"已添加"];
            
            // 移除未读数
            NSString * friendRequest = [NSString stringWithFormat:@"%@",frendRequest];
            [[IMClientManager shareInstance].frendRequestManager removeFrendRequest:friendRequest];
            [[NSNotificationCenter defaultCenter] postNotificationName:NoticationClearUnreadCount object:nil];
            
        } else {
            [SVProgressHUD showHint:@"添加失败"];
        }
    }];
}

#pragma mark - IBAction Methods

- (IBAction)agreeFrendRequest:(UIButton *)sender
{
    NSLog(@"我同意好友请求，好友信息为：%@", [_dataSource objectAtIndex: sender.tag]);
    [self addContactWithFrendRequest:[_dataSource objectAtIndex: sender.tag]];
}

#pragma mark - Table view data source & delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FrendRequestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:requestCell forIndexPath:indexPath];
    FrendRequest *request = [_dataSource objectAtIndex:indexPath.row];
    cell.nickNameLabel.text = request.nickName;
    cell.attachMsgLabel.text = request.attachMsg;
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:request.avatar] placeholderImage:[UIImage imageNamed:@"person_disabled"]];
    cell.requestBtn.tag = indexPath.row;
    if (request.status == TZFrendAgree) {
        [cell.requestBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [cell.requestBtn setTitle:@"已添加" forState:UIControlStateNormal];
        cell.requestBtn.userInteractionEnabled = NO;
        
    } else if (request.status == TZFrendDefault) {
        [cell.requestBtn setTitleColor:APP_THEME_COLOR forState:UIControlStateNormal];
        [cell.requestBtn setTitleColor:APP_THEME_COLOR_HIGHLIGHT forState:UIControlStateHighlighted];
        [cell.requestBtn setTitle:@"通过" forState:UIControlStateNormal];
        cell.requestBtn.userInteractionEnabled = YES;
        [cell.requestBtn removeTarget:self action:@selector(agreeFrendRequest:) forControlEvents:UIControlEventTouchUpInside];
        [cell.requestBtn addTarget:self action:@selector(agreeFrendRequest:) forControlEvents:UIControlEventTouchUpInside];
    }
        
    return cell;
}

#pragma mark - 点击cell跳转页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%s",__func__);
    FrendRequest *request = [_dataSource objectAtIndex:indexPath.row];
    OtherUserInfoViewController *contactDetailCtl = [[OtherUserInfoViewController alloc]init];
    contactDetailCtl.userId = request.userId;
    [self.navigationController pushViewController:contactDetailCtl animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        FrendRequest *frendRequest = [self.dataSource objectAtIndex:indexPath.row];
        IMClientManager *clientManager = [IMClientManager shareInstance];
        [clientManager.frendRequestManager removeFrendRequest:frendRequest.requestId];
        [self.dataSource removeObject:frendRequest];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

@end
