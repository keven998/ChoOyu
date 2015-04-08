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
#import "FavoriteViewController.h"
#import "SuperWebViewController.h"

#define cellDataSource           @[@[@"我的收藏", @"推荐给微信好友"], @[@"设置", @"关于桃子旅行"]]
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
//    self.navigationItem.title = @"我";
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0 , 100, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"我";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    [self.tableView registerNib:[UINib nibWithNibName:@"LoginTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:loginCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"UnLoginTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:unLoginCell];
    [self.tableView registerNib:[UINib nibWithNibName:@"OptionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:secondCell];
//    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 40)];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:userDidLoginNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:userDidLogoutNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:updateUserInfoNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegister:) name:userDidRegistedNoti object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_home_me"];
    
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_home_me"];
    
    [self.navigationController setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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
    [MobClick event:@"event_share_app_by_weichat"];
    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"推荐\"桃子旅行\"给你。";
    
    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://a.app.qq.com/o/simple.jsp?pkgname=com.aizou.peachtravel";

    UIImage *shareImage = [UIImage imageNamed:@"ic_taozi_share.png"];
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:@"能和旅伴一起讨论旅行，还有便利的自由行规划工具，陪你一起去旅行" image:shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response) {
        if (response.responseCode == UMSResponseCodeSuccess) {
            NSLog(@"分享成功！");
        }
    }];
}

#pragma mark - IBAction Methods

- (IBAction)userLogin:(id)sender
{
//    LoginViewController *loginCtl = [[LoginViewController alloc] init];
//    loginCtl.isPushed = NO;
//    loginCtl.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:loginCtl animated:YES];
    
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    UINavigationController *nctl = [[UINavigationController alloc] initWithRootViewController:loginCtl];
    loginCtl.isPushed = NO;
    [nctl.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bkg.png"] forBarMetrics:UIBarMetricsDefault];
    nctl.navigationBar.translucent = YES;
    
    [self.navigationController presentViewController:nctl animated:YES completion:nil];
}

- (IBAction)userRegister:(id)sender
{
    RegisterViewController *registerCtl = [[RegisterViewController alloc] init];
    registerCtl.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:registerCtl animated:YES];
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:registerCtl];
    [self presentViewController:navc animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
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
        return 184.0;
    } else {
        return 44.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (self.accountManager.isLogin) {
            AccountManager *accountManager = [AccountManager shareAccountManager];
            LoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:loginCell forIndexPath:indexPath];
            [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:accountManager.account.avatarSmall] placeholderImage:[UIImage imageNamed:@"avatar_placeholder.png"]];
            cell.userId.text = [NSString stringWithFormat:@"桃子号 %d", [accountManager.account.userId intValue]];
            cell.userName.text = accountManager.account.nickName;
            cell.userSign.text = accountManager.account.signature.length > 0 ? accountManager.account.signature:@"no签名";
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell_accessory_white.png"]];
            if ([accountManager.account.gender isEqualToString:@"M"]) {
                cell.userGender.image = [UIImage imageNamed:@"ic_gender_man.png"];
            } else if ([accountManager.account.gender isEqualToString:@"F"]) {
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
                    [cell.flagView setImage:[UIImage imageNamed:@"ic_my_favorite.png"]];
                    break;
                    
                case 1:
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
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            AccountManager *accountManager = [AccountManager shareAccountManager];
            if (!accountManager.isLogin) {
                [self performSelector:@selector(userLogin:) withObject:nil afterDelay:0.3];
                [SVProgressHUD showHint:@"请先登录"];
            } else {
                FavoriteViewController *fvc = [[FavoriteViewController alloc] init];
                fvc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:fvc animated:YES];
            }
        } else if (indexPath.row == 1) {
            [self shareToWeChat];
        }
        
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            SettingTableViewController *settingCtl = [[SettingTableViewController alloc] init];
            settingCtl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:settingCtl animated:YES];
        } else if (indexPath.row == 1) {
            SuperWebViewController *svc = [[SuperWebViewController alloc] init];
            svc.hidesBottomBarWhenPushed = YES;
            svc.titleStr = @"关于桃子旅行";
            svc.urlStr = [NSString stringWithFormat:@"%@?version=%@", APP_ABOUT, [[AppUtils alloc] init].appVersion];
            [self.navigationController pushViewController:svc animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end




