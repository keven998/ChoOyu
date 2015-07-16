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

@interface FrendRequestTableViewController ()

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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_ask_for_friend"];
}

- (void)dealloc
{
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
    [[IMClientManager shareInstance].frendManager asyncAgreeAddContactWithRequestId:frendRequest.requestId completion:^(BOOL isSuccess, NSInteger errorCode) {
        if (isSuccess) {
            [self.tableView reloadData];
            [SVProgressHUD showHint:@"已添加"];
        } else {
            [SVProgressHUD showHint:@"添加失败"];
        }
    }];
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    AppUtils *utils = [[AppUtils alloc] init];
//    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%@", self.accountManager.account.userId] forHTTPHeaderField:@"UserId"];
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//
//    [params setObject:frendRequest.userId forKey:@"userId"];
//    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
//    __weak FrendRequestTableViewController *weakSelf = self;
//    [hud showHUDInViewController:weakSelf.navigationController];
//    
//    //同意添加好友
//    [manager POST:API_ADD_CONTACT parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        [hud hideTZHUD];
//        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
//        if (code == 0) {
//            [self.accountManager agreeFrendRequest:frendRequest];
//            [self.accountManager addContact:frendRequest];
//            [self.tableView reloadData];
//            
////            [SVProgressHUD showHint:@"已添加"];
//            for (Contact *contact in self.accountManager.account.contacts) {
//                if ([((FrendRequest *)frendRequest).userId longValue] == [contact.userId longValue]) {
////                    ContactDetailViewController *contactDetailCtl = [[ContactDetailViewController alloc] init];
//                    OtherUserInfoViewController *contactDetailCtl = [[OtherUserInfoViewController alloc]init];
//                    
//                    contactDetailCtl.userId = contact.userId;
//                    [self.navigationController pushViewController:contactDetailCtl animated:YES];
//                    break;
//                }
//            }
//           
//            
//        } else {
//            [SVProgressHUD showHint:@"添加失败"];
//
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [hud hideTZHUD];
//        if (self.isShowing) {
//            [SVProgressHUD showHint:@"呃～好像没找到网络"];
//        }
//    }];
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
    return 55.0;
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
        [cell.requestBtn setTitleColor:[APP_THEME_COLOR colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [cell.requestBtn setTitle:@"通过" forState:UIControlStateNormal];
        cell.requestBtn.userInteractionEnabled = YES;
        [cell.requestBtn addTarget:self action:@selector(agreeFrendRequest:) forControlEvents:UIControlEventTouchUpInside];
    }
        
    return cell;
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
