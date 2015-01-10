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
#import "PushMsgsViewController.h"
#import "UMSocial.h"

#define cellDataSource               @[@[@"分享账户管理", @"我收到的消息", @"推荐给微信好友"], @[@"设置", @"关于桃子旅行"]]
#define loginCell                @"loginCell"
#define unLoginCell              @"unLoginCell"
#define secondCell               @"secondCell"

@interface MineTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) AccountManager *accountManager;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation MineTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64-50)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    [self.tableView registerNib:[UINib nibWithNibName:@"LoginTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:loginCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"UnLoginTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:unLoginCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"OptionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:secondCell];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:userDidLoginNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:userDidLogoutNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:updateUserInfoNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegister:) name:userDidRegistedNoti object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self rdv_tabBarController].tabBarHidden) {
        [[self rdv_tabBarController] setTabBarHidden:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.navigationController.viewControllers.count == 2) {
        [[self rdv_tabBarController] setTabBarHidden:YES];
    }
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)userDidRegister:(NSNotification *)noti
{
    UIViewController *controller = [noti.userInfo objectForKey:@"poster"];
    [controller.navigationController popToRootViewControllerAnimated:YES];
}

- (void)shareToWeChat
{
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:@"我是桃子旅行，专为各位爱旅行的美眉们提供服务的贴心小App，官方下载: http://****" image:nil location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response) {
        if (response.responseCode == UMSResponseCodeSuccess) {
            NSLog(@"分享成功！");
        }
    }];
}

#pragma mark - IBAction Methods

- (IBAction)userLogin:(id)sender
{
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    loginCtl.isPushed = YES;
    [self.navigationController pushViewController:loginCtl animated:YES];
}

- (IBAction)userRegister:(id)sender
{
    RegisterViewController *registerCtl = [[RegisterViewController alloc] init];
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
        return [cellDataSource[section-1] count];
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
            cell.userSign.text = accountManager.account.signature.length > 0 ? accountManager.account.signature:@"编写签名";
            if ([accountManager.account.gender isEqualToString:@"M"]) {
                cell.userGender.image = [UIImage imageNamed:@"ic_gender_man.png"];

            }
            if ([accountManager.account.gender isEqualToString:@"F"]) {
                cell.userGender.image = [UIImage imageNamed:@"ic_gender_lady.png"];
            } else if ([accountManager.account.gender isEqualToString:@"U"]) {
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
        cell.titleView.text = [[cellDataSource objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
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
            [self.navigationController pushViewController:userInfoCtl animated:YES];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            AccountManagerViewController *accountManagerCtl = [[AccountManagerViewController alloc] init];
            [self.navigationController pushViewController:accountManagerCtl animated:YES];
        } else if (indexPath.row == 1) {
            PushMsgsViewController *ctl = [[PushMsgsViewController alloc] init];
            [self.navigationController pushViewController:ctl animated:YES];
        } else if (indexPath.row == 2) {
            [self shareToWeChat];
        }
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            SettingTableViewController *settingCtl = [[SettingTableViewController alloc] init];

            [self.navigationController pushViewController:settingCtl animated:YES];

        } else if (indexPath.row == 1) {
            AboutController *aboutCtl = [[AboutController alloc] init];
            [self.navigationController pushViewController:aboutCtl animated:YES];
        }
    }
//    if ([_rootCtl.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
//        _rootCtl.navigationController.interactivePopGestureRecognizer.delegate = nil;
//    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end




