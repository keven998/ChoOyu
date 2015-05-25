//
//  MineTableViewController.m
//  PeachTravel
//
//  Created by liangpengshuai on 14/10/7.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "MineTableViewController.h"
#import "AccountManagerViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "AccountManager.h"
#import "SettingHomeViewController.h"
#import "UserInfoTableViewController.h"
#import "OptionTableViewCell.h"
#import "PushMsgsViewController.h"
#import "UMSocial.h"
#import "FavoriteViewController.h"
#import "SuperWebViewController.h"

#define cellDataSource           @[@[@"收藏夹", @"推荐应用给好友"], @[@"设置", @"关于旅行派"]]
#define secondCell               @"secondCell"

@interface MineTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) AccountManager *accountManager;
@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *propLabel;
@property (nonatomic, strong) UILabel *signatureLabel;

@end

@implementation MineTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.separatorColor = APP_DIVIDER_COLOR;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerNib:[UINib nibWithNibName:@"OptionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:secondCell];
    
    [self setupTableHeaderView];
    [self updateAccountInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:userDidLoginNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:userDidLogoutNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:updateUserInfoNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegister:) name:userDidRegistedNoti object:nil];
    
    _navigationbarAnimated = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_home_me"];
    [self.navigationController setNavigationBarHidden:YES animated:_navigationbarAnimated];
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    _navigationbarAnimated = YES; //tab 切换navigationbar 动画补丁
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_home_me"];
    if (!_hideNavigationBar) {
        [self.navigationController setNavigationBarHidden:NO animated:_navigationbarAnimated];
    }
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
    _tableView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) setupTableHeaderView {
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = 366 * CGRectGetHeight(self.view.bounds) / 1334;
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.image = [UIImage imageNamed:@"picture_background"];
    backgroundImageView.userInteractionEnabled = YES;
    backgroundImageView.clipsToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [backgroundImageView addGestureRecognizer:tap];
    [self.view addSubview:backgroundImageView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, width, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"我";
    [backgroundImageView addSubview:titleLabel];
    
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(22, (height - 20.0)/2.0 - 10, 60, 60)];
    headerView.clipsToBounds = YES;
    headerView.layer.cornerRadius = 17.0;
    [backgroundImageView addSubview:headerView];
    _avatarImageView = headerView;
    
    CGFloat xOffset = headerView.frame.origin.x + headerView.frame.size.width + 12;
    CGFloat yOffset = headerView.frame.origin.y;
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(xOffset, yOffset, width - xOffset - 10, 22)];
    nameLabel.font = [UIFont boldSystemFontOfSize:15];
    nameLabel.textColor = [UIColor whiteColor];
    [backgroundImageView addSubview:nameLabel];
    _nameLabel = nameLabel;
    
    UILabel *propLabel = [[UILabel alloc]initWithFrame:CGRectMake(xOffset, yOffset + 22, width - xOffset - 10, 19)];
    propLabel.font = [UIFont systemFontOfSize:12];
    propLabel.textColor = [UIColor whiteColor];
    [backgroundImageView addSubview:propLabel];
    _propLabel = propLabel;
    
    UILabel *signLabel = [[UILabel alloc]initWithFrame:CGRectMake(xOffset, yOffset + 41, width - xOffset - 10, 19)];
    signLabel.font = [UIFont systemFontOfSize:12];
    signLabel.textColor = [UIColor whiteColor];
    [backgroundImageView addSubview:signLabel];
    _signatureLabel = signLabel;
    
    self.tableView.contentInset = UIEdgeInsetsMake(height+0.5, 0, 0, 0);
}

#pragma mark - setter & getter

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
}

- (void) updateAccountInfo {
    AccountManager *amgr = self.accountManager;
    if ([amgr isLogin]) {
        [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:amgr.account.avatarSmall] placeholderImage:[UIImage imageNamed:@"person_disabled"]];
        _nameLabel.text = amgr.account.nickName;
        _propLabel.text = [NSString stringWithFormat:@"ID %d", [amgr.account.userId intValue]];
        _signatureLabel.text = amgr.account.signature.length > 0 ? amgr.account.signature:@"";
//        if ([amgr.account.gender isEqualToString:@"M"]) {
//            cell.userGender.image = [UIImage imageNamed:@"ic_gender_man.png"];
//        } else if ([amgr.account.gender isEqualToString:@"F"]) {
//            cell.userGender.image = [UIImage imageNamed:@"ic_gender_lady.png"];
//        } else if ([amgr.account.gender isEqualToString:@"U"]) {
//            cell.userGender.image = nil;
//        }
    } else {
        [_avatarImageView setImage:[UIImage imageNamed:@"person_disabled"]];
        _propLabel.text = @"点击登录旅行派，享受更多旅行帮助";
        _nameLabel.text = @"未登录";
        _signatureLabel.text = nil;
//        cell.userGender.image = nil;
    }
}

#pragma mark - Private Methods

- (void)userAccountHasChage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateAccountInfo];
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
    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"推荐\"旅行派\"给你。";
    
    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://a.app.qq.com/o/simple.jsp?pkgname=com.aizou.peachtravel";

    UIImage *shareImage = [UIImage imageNamed:@"ic_taozi_share.png"];
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:@"能和达人交流、朋友互动的旅行工具" image:shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response) {
//        if (response.responseCode == UMSResponseCodeSuccess) {
//            NSLog(@"分享成功！");
//        }
    }];
}

#pragma mark - IBAction Methods

- (IBAction)userLogin:(id)sender
{
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
    loginCtl.isPushed = NO;
    _hideNavigationBar = YES;
    [self.navigationController presentViewController:nctl animated:YES completion:^ {
        _hideNavigationBar = NO;
    }];
}

- (IBAction)userRegister:(id)sender
{
    RegisterViewController *registerCtl = [[RegisterViewController alloc] init];
    registerCtl.hidesBottomBarWhenPushed = YES;
    TZNavigationViewController *navc = [[TZNavigationViewController alloc] initWithRootViewController:registerCtl];
    [self presentViewController:navc animated:YES completion:nil];
}

- (void)tap {
    if (self.accountManager.isLogin) {
        UserInfoTableViewController *userInfoCtl = [[UserInfoTableViewController alloc] init];
        userInfoCtl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:userInfoCtl animated:YES];
    } else {
        [self userLogin:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cellDataSource[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        OptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:secondCell];
        cell.titleView.text = [[cellDataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.section == 0) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
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
        
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            SettingHomeViewController *settingCtl = [[SettingHomeViewController alloc] init];
            settingCtl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:settingCtl animated:YES];
        } else if (indexPath.row == 1) {
            SuperWebViewController *svc = [[SuperWebViewController alloc] init];
            svc.hidesBottomBarWhenPushed = YES;
            svc.titleStr = @"关于旅行派";
            svc.urlStr = [NSString stringWithFormat:@"%@?version=%@", APP_ABOUT, [[AppUtils alloc] init].appVersion];
            svc.hideToolBar = YES;
            [self.navigationController pushViewController:svc animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ScrollViewDelegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_tableView != nil) {
        UIView *view = _avatarImageView.superview;
        CGRect frame = view.frame;
        CGFloat y = scrollView.contentOffset.y + CGRectGetHeight(frame);
        if (y <= 0) {
            if (frame.origin.y != 0) {
                frame.origin.y = 0;
                view.frame = frame;
            }
        } else {
            frame.origin.y = -y;
            view.frame = frame;
        }
    }
}

@end




