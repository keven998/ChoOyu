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
#import "SuperWebViewController.h"
#import "FeedbackViewController.h"

#define cellDataSource           @[@[@"邀请好友", @"意见反馈", @"关于我们"], @[@"应用设置"]]
#define secondCell               @"secondCell"

@interface MineTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) AccountManager *accountManager;
@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *idLabel;
@property (nonatomic, strong) UIImageView *avatarBg;
@property (nonatomic, strong) UIImageView *genderView;
@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) UILabel *friendCount;
@property (nonatomic, strong) UILabel *planCount;
@property (nonatomic, strong) UILabel *trackCount;

@end

@implementation MineTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.separatorColor = COLOR_LINE;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerNib:[UINib nibWithNibName:@"OptionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:secondCell];
    
    [self setupTableHeaderView];
    [self updateAccountInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:userDidLoginNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:userDidLogoutNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:updateUserInfoNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegister:) name:userDidRegistedNoti object:nil];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"编辑 " style:UIBarButtonItemStylePlain target:self action:@selector(tap)];
    rightBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_home_me"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_home_me"];
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
    CGFloat height = 890 * CGRectGetHeight(self.view.bounds) / 2208;
    
    UIView *headerBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    headerBgView.backgroundColor = [UIColor whiteColor];
    headerBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerBgView.clipsToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userLogin)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [headerBgView addGestureRecognizer:tap];
    [self.view addSubview:headerBgView];
    
    UIImageView *avatarBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, height/2.0, height/2.0)];
    avatarBg.backgroundColor = COLOR_ALERT;
    avatarBg.center = CGPointMake(width/2.0, height/4.0 + 20);
    [headerBgView addSubview:avatarBg];
    _avatarBg = avatarBg;
    
    CGFloat avatarW = CGRectGetWidth(avatarBg.frame) - 10;
    UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, avatarW, avatarW)];
    avatar.clipsToBounds = YES;
    avatar.layer.cornerRadius = avatarW/2.0;
    avatar.center = avatarBg.center;
    avatar.contentMode = UIViewContentModeScaleAspectFill;
    [headerBgView addSubview:avatar];
    _avatarImageView = avatar;
    
    UIImageView *gender = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    gender.backgroundColor = COLOR_CHECKED;
    gender.center = CGPointMake(width/2.0 - 20, CGRectGetMaxY(avatarBg.frame));
    [headerBgView addSubview:gender];
    _genderView = gender;
    
    UIImageView *levelBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 24)];
    levelBg.backgroundColor = COLOR_ENTER;
    levelBg.center = CGPointMake(width/2.0 +24, CGRectGetMaxY(avatarBg.frame));
    [headerBgView addSubview:levelBg];
    UILabel *levelLabel = [[UILabel alloc] initWithFrame:levelBg.frame];
    levelLabel.textColor = [UIColor whiteColor];
    levelLabel.font = [UIFont systemFontOfSize:9];
    levelLabel.textAlignment = NSTextAlignmentCenter;
    [levelBg addSubview:levelLabel];
    _levelLabel = levelLabel;
    
    CGFloat unitWidth = width/3.0;
    CGFloat offsetY = CGRectGetMaxY(levelBg.frame);
    UIButton *friendEntry = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, unitWidth, height - offsetY)];
    UILabel *friendNumber = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, unitWidth - 20, 18)];
    friendNumber.textColor = COLOR_TEXT_I;
    friendNumber.textAlignment = NSTextAlignmentCenter;
    friendNumber.font = [UIFont systemFontOfSize:16];
    friendNumber.text = @"99";
    friendNumber.lineBreakMode = NSLineBreakByTruncatingTail;
    _friendCount = friendNumber;
    [friendEntry addSubview:friendNumber];
    UILabel *fl = [[UILabel alloc] initWithFrame:CGRectMake(10, 28, unitWidth - 20, 20)];
    fl.textColor = COLOR_TEXT_III;
    fl.text = @"好友";
    fl.textAlignment = NSTextAlignmentCenter;
    fl.font = [UIFont systemFontOfSize:12];
    [friendEntry addSubview:fl];
    [headerBgView addSubview:friendEntry];
    
    UIButton *planEntry = [[UIButton alloc] initWithFrame:CGRectMake(unitWidth, offsetY, unitWidth, height - offsetY)];
    UILabel *planNumber = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, unitWidth - 20, 18)];
    planNumber.textColor = COLOR_TEXT_I;
    planNumber.textAlignment = NSTextAlignmentCenter;
    planNumber.font = [UIFont systemFontOfSize:16];
    planNumber.text = @"99";
    _planCount = planNumber;
    planNumber.lineBreakMode = NSLineBreakByTruncatingTail;
    [planEntry addSubview:planNumber];
    UILabel *pl = [[UILabel alloc] initWithFrame:CGRectMake(10, 28, unitWidth - 20, 20)];
    pl.textColor = COLOR_TEXT_III;
    pl.text = @"计划";
    pl.textAlignment = NSTextAlignmentCenter;
    pl.font = [UIFont systemFontOfSize:12];
    [planEntry addSubview:pl];
    [headerBgView addSubview:planEntry];
    
    UIButton *trackEntry = [[UIButton alloc] initWithFrame:CGRectMake(2*unitWidth, offsetY, unitWidth, height - offsetY)];
    UILabel *trackNumber = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, unitWidth - 20, 18)];
    trackNumber.textColor = COLOR_TEXT_I;
    trackNumber.textAlignment = NSTextAlignmentCenter;
    trackNumber.font = [UIFont systemFontOfSize:16];
    trackNumber.lineBreakMode = NSLineBreakByTruncatingTail;
    trackNumber.text = @"5国17城";
    _trackCount = trackNumber;
    [trackEntry addSubview:trackNumber];
    UILabel *tl = [[UILabel alloc] initWithFrame:CGRectMake(10, 28, unitWidth - 20, 20)];
    tl.textColor = COLOR_TEXT_III;
    tl.text = @"足迹";
    tl.textAlignment = NSTextAlignmentCenter;
    tl.font = [UIFont systemFontOfSize:12];
    [trackEntry addSubview:tl];
    [headerBgView addSubview:trackEntry];

    self.tableView.contentInset = UIEdgeInsetsMake(height, 0, 0, 0);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width/2, 44)];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, width/2, 18)];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = @"旅行派";
    [view addSubview:nameLabel];
    _nameLabel = nameLabel;
    
    UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, width/2, 12)];
    idLabel.textColor = [UIColor whiteColor];
    idLabel.font = [UIFont systemFontOfSize:9];
    idLabel.textAlignment = NSTextAlignmentCenter;
    idLabel.text = @"未登录";
    [view addSubview:idLabel];
    _idLabel = idLabel;
    
    self.navigationItem.titleView = view;
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
        _idLabel.text = [NSString stringWithFormat:@"ID %@", amgr.account.userId];
//        _propLabel.text = [NSString stringWithFormat:@"ID %d", [amgr.account.userId intValue]];
//        _signatureLabel.text = amgr.account.signature.length > 0 ? amgr.account.signature:@"";
//        if ([amgr.account.gender isEqualToString:@"M"]) {
//            cell.userGender.image = [UIImage imageNamed:@"ic_gender_man.png"];
//        } else if ([amgr.account.gender isEqualToString:@"F"]) {
//            cell.userGender.image = [UIImage imageNamed:@"ic_gender_lady.png"];
//        } else if ([amgr.account.gender isEqualToString:@"U"]) {
//            cell.userGender.image = nil;
//        }
    } else {
        [_avatarImageView setImage:[UIImage imageNamed:@"person_disabled"]];
//        _propLabel.text = @"点击登录旅行派，享受更多旅行帮助";
        _nameLabel.text = @"旅行派";
        _idLabel.text = @"未登录";
//        _signatureLabel.text = nil;
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

- (void)userLogin
{
    if (self.accountManager.isLogin) {
        return;
    }
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
    loginCtl.isPushed = NO;
    [self.navigationController presentViewController:nctl animated:YES completion:nil];
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
        [self userLogin];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cellDataSource[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *hv = [[UIView alloc] init];
    hv.backgroundColor = [UIColor clearColor];
    return hv;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:secondCell];
    cell.titleView.text = [[cellDataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                [cell.flagView setImage:[UIImage imageNamed:@"ic_share_to_friend.png"]];
                break;
                
            case 1:
                [cell.flagView setImage:[UIImage imageNamed:@"ic_feedback.png"]];
                break;
                
            case 2:
                [cell.flagView setImage:[UIImage imageNamed:@"ic_about.png"]];
                break;
                
            default:
                break;
        }
        
    } else {
        switch (indexPath.row) {
            case 0:
                [cell.flagView setImage:[UIImage imageNamed:@"ic_setting.png"]];
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
            [self shareToWeChat];
        } else if (indexPath.row == 1) {
            [MobClick event:@"event_feedback"];
            FeedbackController *feedbackCtl = [[FeedbackController alloc] init];
            [self.navigationController pushViewController:feedbackCtl animated:YES];
        } else {
            SuperWebViewController *svc = [[SuperWebViewController alloc] init];
            svc.hidesBottomBarWhenPushed = YES;
            svc.titleStr = @"关于旅行派";
            svc.urlStr = [NSString stringWithFormat:@"%@?version=%@", APP_ABOUT, [[AppUtils alloc] init].appVersion];
            svc.hideToolBar = YES;
            [self.navigationController pushViewController:svc animated:YES];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            SettingHomeViewController *settingCtl = [[SettingHomeViewController alloc] init];
            settingCtl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:settingCtl animated:YES];
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




