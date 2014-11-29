//
//  MineTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/7.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "MineTableViewController.h"
#import "LoginTableViewCell.h"
#import "UnLoginTableViewCell.h"
#import "AccountManagerViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "AccountManager.h"
#import "AboutViewController.h"
#import "SettingTableViewController.h"
#import "UserInfoTableViewController.h"
#import "OptionTableViewCell.h"

#define dataSource               @[@[@"分享设置", @"消息中心", @"推荐给微信好友"], @[@"设置", @"关于桃子旅行"]]
#define loginCell                @"loginCell"
#define unLoginCell              @"unLoginCell"
#define secondCell               @"secondCell"

@interface MineTableViewController ()

@property (strong, nonatomic) AccountManager *accountManager;

@end

@implementation MineTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self.tableView setContentInset:UIEdgeInsetsMake(-35, 0, 0, 0)];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoginTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:loginCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"UnLoginTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:unLoginCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"OptionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:secondCell];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:userDidLoginNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:userDidLogoutNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:updateUserInfoNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegister:) name:userDidRegistedNoti object:nil];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - setter & getter

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
}

#pragma mark - Private Methods

- (void)userAccountHasChage
{
    [self.tableView reloadData];
}

- (void)userDidRegister:(NSNotification *)noti
{
    UIViewController *controller = [noti.userInfo objectForKey:@"poster"];
    [controller.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - IBAction Methods

- (IBAction)userLogin:(id)sender
{
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    loginCtl.hidesBottomBarWhenPushed = YES;
    loginCtl.isPushed = YES;
    [self.navigationController pushViewController:loginCtl animated:YES];
}

- (IBAction)userRegister:(id)sender
{
    RegisterViewController *registerCtl = [[RegisterViewController alloc] init];
    registerCtl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:registerCtl animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.0;
    }
    return 20.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = APP_PAGE_COLOR;
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return [dataSource[section-1] count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 114.0;
    } else {
        return 47.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.accountManager.isLogin) {
            AccountManager *accountManager = [AccountManager shareAccountManager];
            LoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:loginCell forIndexPath:indexPath];
            [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:accountManager.account.avatar] placeholderImage:[UIImage imageNamed:@"avatar_placeholder.png"]];
            cell.userId.text = [NSString stringWithFormat:@"ID:%d", [accountManager.account.userId intValue]];
            cell.userName.text = accountManager.account.nickName;
            cell.userSign.text = accountManager.account.signature.length>0 ? accountManager.account.signature:@"编写签名";
            if ([accountManager.account.gender isEqualToString:@"M"]) {
                cell.userGender.image = [UIImage imageNamed:@"ic_gender_man.png"];

            }
            if ([accountManager.account.gender isEqualToString:@"F"]) {
                cell.userGender.image = [UIImage imageNamed:@"ic_gender_lady.png"];
            }
            if ([accountManager.account.gender isEqualToString:@"U"]) {
                cell.userGender.image = nil;
            }
            return cell;
        } else {
            UnLoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:unLoginCell forIndexPath:indexPath];
            [cell.loginBtn addTarget:self action:@selector(userLogin:) forControlEvents:UIControlEventTouchUpInside];
            [cell.registerBtn addTarget:self action:@selector(userRegister:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        
    } else {
        OptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:secondCell];
        cell.titleView.text = [[dataSource objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
        if (indexPath.section == 1) {
            switch (indexPath.row) {
                case 0:
                    [cell.flagView setImage:[UIImage imageNamed:@"ic_setting_share.png"]];
                    break;
                    
                case 1:
                    [cell.flagView setImage:[UIImage imageNamed:@"ic_app_message.png"]];
                    break;
                    
                case 2:
                    [cell.flagView setImage:[UIImage imageNamed:@"ic_share_to_friend.png"]];
                    break;
                    
                default:
                    break;
            }
        } else {
            switch (indexPath.row) {
                case 0:
                    [cell.flagView setImage:[UIImage imageNamed:@"ic_setting.png"]];
                    break;
                    
                case 1:
                    [cell.flagView setImage:[UIImage imageNamed:@"ic_about.png"]];
                    break;
                    
                default:
                    break;
            }
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.accountManager.isLogin) {
            UserInfoTableViewController *userInfoCtl = [[UserInfoTableViewController alloc] init];
            userInfoCtl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:userInfoCtl animated:YES];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            AccountManagerViewController *accountManagerCtl = [[AccountManagerViewController alloc] init];
            accountManagerCtl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:accountManagerCtl animated:YES];
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            SettingTableViewController *settingCtl = [[SettingTableViewController alloc] init];
            settingCtl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:settingCtl animated:YES];
        }
        if (indexPath.row == 1) {
            AboutController *aboutCtl = [[AboutController alloc] init];
            aboutCtl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:aboutCtl animated:YES];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end




