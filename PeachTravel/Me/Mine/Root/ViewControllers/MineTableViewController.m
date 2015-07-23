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
#import "FootPrintViewController.h"
#import "PlansListTableViewController.h"
#import "ContactListViewController.h"
#import "MWPhotoBrowser.h"
#import "UserAlbumViewController.h"

#define cellDataSource           @[@[@"邀请朋友", @"意见反馈"], @[@"关于我们", @"应用设置"]]
#define secondCell               @"secondCell"

@interface MineTableViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UILabel *_trackNumber;
    UILabel *_pictureNumber;
    UILabel *_planNumber;
}
@property (strong, nonatomic) AccountManager *accountManager;
@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *idLabel;
@property (nonatomic, strong) UIImageView *avatarBg;
@property (nonatomic, strong) UIImageView *constellationView;
@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) UILabel *friendCount;
@property (nonatomic, strong) UILabel *planCount;
@property (nonatomic, strong) UILabel *trackCount;
@property (nonatomic, strong) UIImageView *levelBg;
@property (nonatomic, strong) UIImageView *flagHeaderIV;

@end

@implementation MineTableViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = APP_PAGE_COLOR;
    self.tableView.showsVerticalScrollIndicator = NO;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = COLOR_LINE;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerNib:[UINib nibWithNibName:@"OptionTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:secondCell];
    
    [self setupTableHeaderView];
    [self updateAccountInfo];
    [self loadUserInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:userDidLoginNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:userDidLogoutNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAccountHasChage) name:updateUserInfoNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegister:) name:userDidRegistedNoti object:nil];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"编辑 " style:UIBarButtonItemStylePlain target:self action:@selector(editUserInfo)];
    rightBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_accountManager.account.guideCnt) {
        [self loadUserInfo];
    }
    [self updateAccountInfo];
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

- (void)loadUserInfo
{
    [self.accountManager.account loadUserInfoFromServer:^(bool isSuccess) {
        if (isSuccess) {
            [self loadUserAlbum];
            [self updateAccountInfo];
        }
    }];
}

- (void) setupTableHeaderView {
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    UIView *headerBgView = [[UIView alloc] init];
    headerBgView.backgroundColor = [UIColor whiteColor];
    headerBgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    headerBgView.clipsToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userLogin)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [headerBgView addGestureRecognizer:tap];
    [self.view addSubview:headerBgView];
    
    CGFloat hh = 177*height/736;
    
    UIImageView *flagHeaderIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, hh)];
    flagHeaderIV.contentMode = UIViewContentModeScaleAspectFill;
    flagHeaderIV.clipsToBounds = YES;
    flagHeaderIV.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [headerBgView addSubview:flagHeaderIV];
    _flagHeaderIV = flagHeaderIV;
    
    CGFloat ah = 200*height/736;
    
    CGFloat avatarW = ah - 19 * height/736;
    UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, avatarW, avatarW)];
    avatar.clipsToBounds = YES;
    avatar.layer.cornerRadius = avatarW/2.0;
    avatar.center = CGPointMake(width/2.0, 15 + ah/2.0);
    avatar.contentMode = UIViewContentModeScaleAspectFill;
    [headerBgView addSubview:avatar];
    _avatarImageView = avatar;
    
    UIImageView *avatarBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ah, ah)];
    avatarBg.center = avatar.center;
    avatarBg.contentMode = UIViewContentModeScaleToFill;
    avatarBg.clipsToBounds = YES;
    [headerBgView addSubview:avatarBg];
    _avatarBg = avatarBg;
    
    UIImageView *levelBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, 20)];
    levelBg.center = CGPointMake(width/2.0 + 10, CGRectGetMaxY(avatarBg.frame) - 5);
    levelBg.contentMode = UIViewContentModeScaleAspectFit;
    [headerBgView addSubview:levelBg];
    _levelBg = levelBg;
    UILabel *levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64, 18)];
    levelLabel.textColor = [UIColor whiteColor];
    levelLabel.font = [UIFont systemFontOfSize:9];
    levelLabel.textAlignment = NSTextAlignmentCenter;
    [levelBg addSubview:levelLabel];
    _levelLabel = levelLabel;
    
    UIImageView *constellationView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    constellationView.center = CGPointMake(width/2.0 - 18, CGRectGetMaxY(avatarBg.frame) - 5);
    constellationView.contentMode = UIViewContentModeScaleAspectFit;
    [headerBgView addSubview:constellationView];
    _constellationView = constellationView;
    
    CGFloat unitWidth = width/3.0;
    CGFloat offsetY = CGRectGetMaxY(levelBg.frame);
    
    CGFloat bh = 84*height/736;
    
    UIButton *friendEntry = [[UIButton alloc] initWithFrame:CGRectMake(unitWidth, offsetY, unitWidth, bh)];
    _pictureNumber = [[UILabel alloc] initWithFrame:CGRectMake(10, bh/2 - 20, unitWidth - 20, 20)];
    _pictureNumber.textColor = COLOR_TEXT_I;
    _pictureNumber.textAlignment = NSTextAlignmentCenter;
    _pictureNumber.font = [UIFont systemFontOfSize:16];
    _pictureNumber.text = @"0图";
    _pictureNumber.lineBreakMode = NSLineBreakByTruncatingTail;
    _friendCount = _pictureNumber;
    [friendEntry addSubview:_pictureNumber];
    UILabel *fl = [[UILabel alloc] initWithFrame:CGRectMake(10, bh/2, unitWidth - 20, 20)];
    fl.textColor = COLOR_TEXT_III;
    fl.text = @"相册";
    fl.textAlignment = NSTextAlignmentCenter;
    fl.font = [UIFont systemFontOfSize:13];
    [friendEntry addSubview:fl];
    [friendEntry addTarget:self action:@selector(showPictureGrid:) forControlEvents:UIControlEventTouchUpInside];
    [headerBgView addSubview:friendEntry];
    
    UIButton *planEntry = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, unitWidth, bh)];
    _planNumber = [[UILabel alloc] initWithFrame:CGRectMake(10, bh/2 - 20, unitWidth - 20, 20)];
    _planNumber.textColor = COLOR_TEXT_I;
    _planNumber.textAlignment = NSTextAlignmentCenter;
    _planNumber.font = [UIFont systemFontOfSize:16];
    _planNumber.text = @"0条";
    _planCount = _planNumber;
    _planNumber.lineBreakMode = NSLineBreakByTruncatingTail;
    [planEntry addSubview:_planNumber];
    UILabel *pl = [[UILabel alloc] initWithFrame:CGRectMake(10, bh/2, unitWidth - 20, 20)];
    pl.textColor = COLOR_TEXT_III;
    pl.text = @"计划";
    pl.textAlignment = NSTextAlignmentCenter;
    pl.font = [UIFont systemFontOfSize:13];
    [planEntry addSubview:pl];
    [planEntry addTarget:self action:@selector(myPlan:) forControlEvents:UIControlEventTouchUpInside];
    [headerBgView addSubview:planEntry];
    
    UIButton *trackEntry = [[UIButton alloc] initWithFrame:CGRectMake(2*unitWidth, offsetY, unitWidth, bh)];
    _trackNumber = [[UILabel alloc] initWithFrame:CGRectMake(10, bh/2 - 20, unitWidth - 20, 20)];
    _trackNumber.textColor = COLOR_TEXT_I;
    _trackNumber.adjustsFontSizeToFitWidth = YES;
    _trackNumber.textAlignment = NSTextAlignmentCenter;
    _trackNumber.font = [UIFont systemFontOfSize:16];
    _trackNumber.lineBreakMode = NSLineBreakByTruncatingTail;
  
    _trackNumber.text = [NSString stringWithFormat:@"0国0城"];
    
    _trackCount = _trackNumber;
    [trackEntry addSubview:_trackNumber];
    UILabel *tl = [[UILabel alloc] initWithFrame:CGRectMake(10, bh/2, unitWidth - 20, 20)];
    tl.textColor = COLOR_TEXT_III;
    tl.text = @"足迹";
    tl.textAlignment = NSTextAlignmentCenter;
    tl.font = [UIFont systemFontOfSize:13];
    [trackEntry addSubview:tl];
    [trackEntry addTarget:self action:@selector(myTrack:) forControlEvents:UIControlEventTouchUpInside];
    [headerBgView addSubview:trackEntry];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(unitWidth, offsetY + 14, 0.6, 32)];
    lineView.backgroundColor = COLOR_LINE;
    [headerBgView addSubview:lineView];
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(2*unitWidth, offsetY + 14, 0.6, 32)];
    lineView2.backgroundColor = COLOR_LINE;
    [headerBgView addSubview:lineView2];
    
    headerBgView.frame = CGRectMake(0, 0, width, offsetY + bh);
    
    self.tableView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(headerBgView.frame), 0, 0, 0);
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width/2, 44)];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, width/2, 18)];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:16];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = @"旅行派";
    [view addSubview:nameLabel];
    _nameLabel = nameLabel;
    
    UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, width/2, 12)];
    idLabel.textColor = [UIColor whiteColor];
    idLabel.font = [UIFont boldSystemFontOfSize:10];
    idLabel.textAlignment = NSTextAlignmentCenter;
    idLabel.text = @"未登录";
    [view addSubview:idLabel];
    _idLabel = idLabel;
    
    self.navigationItem.titleView = view;
    [_avatarImageView setImage:[UIImage imageNamed:@"ic_home_userentry_unlogin.png"]];
    _constellationView.image = [UIImage imageNamed:@"ic_home_gender_unknown.png"];
    _levelBg.image = [UIImage imageNamed:@"ic_home_level_bg_unknown.png"];
    _flagHeaderIV.image = [UIImage imageNamed:@"ic_home_header_unlogin.png"];
    _levelLabel.text = @"LV0";
    _nameLabel.text = @"旅行派";
    _idLabel.text = @"未登录";
}

#pragma mark - setter & getter

- (AccountManager *)accountManager
{
    if (!_accountManager) {
        _accountManager = [AccountManager shareAccountManager];
    }
    return _accountManager;
}

- (void)updateAccountInfo {
    AccountManager *amgr = self.accountManager;
    if ([amgr isLogin]) {
        [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:amgr.account.avatarSmall] placeholderImage:[UIImage imageNamed:@"ic_home_avatar_unknown.png"]];

        if (_accountManager.account.footprintsDesc) {
            _trackNumber.text = _accountManager.account.footprintsDesc;
        }
        
        _pictureNumber.text = [NSString stringWithFormat:@"%zd图",_accountManager.account.userAlbum.count];
        
        _planNumber.text = [NSString stringWithFormat:@"%lu条",_accountManager.account.guideCnt];
        _nameLabel.text = amgr.account.nickName;
        _idLabel.text = [NSString stringWithFormat:@"ID：%ld", (long)amgr.account.userId];
        _constellationView.image = [UIImage imageNamed:[FrendModel costellationImageNameWithBirthday:_accountManager.account.birthday]];
        _levelLabel.text = @"Lv12";
        if (amgr.account.gender == Male) {
            _avatarBg.image = [UIImage imageNamed:@"ic_home_avatar_border_boy.png"];
            _levelBg.image = [UIImage imageNamed:@"ic_home_level_bg_boy.png"];
            _flagHeaderIV.image = [UIImage imageNamed:@"ic_home_header_boy.png"];
        } else if (amgr.account.gender == Female) {
            _avatarBg.image = [UIImage imageNamed:@"ic_home_avatar_border_girl.png"];
            _levelBg.image = [UIImage imageNamed:@"ic_home_level_bg_girl.png"];
            _flagHeaderIV.image = [UIImage imageNamed:@"ic_home_header_girl.png"];
        } else {
            _avatarBg.image = [UIImage imageNamed:@"ic_home_avatar_border_unknown.png"];
            _flagHeaderIV.image = [UIImage imageNamed:@"ic_home_header_unlogin.png"];
            _levelBg.image = [UIImage imageNamed:@"ic_home_level_bg_unknown.png"];
        }
    } else {
        [_avatarImageView setImage:[UIImage imageNamed:@"ic_home_userentry_unlogin.png"]];
        _avatarBg.image = [UIImage imageNamed:@"ic_home_userentry_unlogin.png"];
        _constellationView.image = [UIImage imageNamed:@"ic_home_gender_unknown.png"];
        _levelBg.image = [UIImage imageNamed:@"ic_home_level_bg_unknown.png"];
        _flagHeaderIV.image = [UIImage imageNamed:@"ic_home_header_unlogin.png"];
        _levelLabel.text = @"LV0";
        _nameLabel.text = @"旅行派";
        _idLabel.text = @"未登录";
        _trackNumber.text = @"";
        _planNumber.text = @"";
        _pictureNumber.text = @"";


    }
}

#pragma mark - Private Methods

- (void)userAccountHasChage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateAccountInfo];
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
    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"推荐\"旅行派\"给你。";
    
    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://a.app.qq.com/o/simple.jsp?pkgname=com.aizou.peachtravel";
    
    UIImage *shareImage = [UIImage imageNamed:@"icon.png"];
    
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:@"能向达人咨询、朋友协作的旅行工具" image:shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response) {
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

- (void)editUserInfo {
    if (self.accountManager.isLogin) {
        UserInfoTableViewController *userInfoCtl = [[UserInfoTableViewController alloc] init];
        userInfoCtl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:userInfoCtl animated:YES];
    } else {
        [self userLogin];
    }
}

- (IBAction)showPictureGrid:(id)sender
{
    UserAlbumViewController *ctl = [[UserAlbumViewController alloc] initWithNibName:@"UserAlbumViewController" bundle:nil];
    ctl.albumArray = self.accountManager.account.userAlbum;
    ctl.isMyself = YES;
    ctl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ctl animated:YES];
}

- (IBAction)myPlan:(id)sender
{
    PlansListTableViewController *myGuidesCtl = [[PlansListTableViewController alloc] initWithUserId:_accountManager.account.userId];
    myGuidesCtl.hidesBottomBarWhenPushed = YES;
    myGuidesCtl.userName = _accountManager.account.nickName;
    [self.navigationController pushViewController:myGuidesCtl animated:YES];
}

- (IBAction)myTrack:(id)sender
{
    FootPrintViewController *footCtl = [[FootPrintViewController alloc] init];
    AccountManager *amgr = self.accountManager;
    footCtl.hidesBottomBarWhenPushed = YES;
    footCtl.userId = amgr.account.userId;
    [self.navigationController pushViewController:footCtl animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 16;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [cellDataSource[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70*kWindowHeight/736;
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
                [cell.flagView setImage:[UIImage imageNamed:@"ic_home_shareapp2friend.png"]];
                break;
                
            case 1:
                [cell.flagView setImage:[UIImage imageNamed:@"ic_home_feedback.png"]];
                break;
                
            default:
                break;
        }
        
    } else {
        switch (indexPath.row) {
            case 0:
                [cell.flagView setImage:[UIImage imageNamed:@"ic_home_aboutus.png"]];
                break;
                
            case 1:
                [cell.flagView setImage:[UIImage imageNamed:@"ic_home_app_setting.png"]];
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
            feedbackCtl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:feedbackCtl animated:YES];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            SuperWebViewController *svc = [[SuperWebViewController alloc] init];
            svc.hidesBottomBarWhenPushed = YES;
            svc.titleStr = @"关于旅行派";
            svc.urlStr = [NSString stringWithFormat:@"%@?version=%@", APP_ABOUT, [[AppUtils alloc] init].appVersion];
            svc.hideToolBar = YES;
            [self.navigationController pushViewController:svc animated:YES];
        } else {
            SettingHomeViewController *settingCtl = [[SettingHomeViewController alloc] init];
            settingCtl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:settingCtl animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/**
 *  下载用户头像列表
 */
- (void)loadUserAlbum
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", accountManager.account.userId] forHTTPHeaderField:@"UserId"];
    NSString *url = [NSString stringWithFormat:@"%@%ld/albums", API_USERS, accountManager.account.userId];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@", responseObject);
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self paraseUserAlbum:[responseObject objectForKey:@"result"]];
            [self.tableView reloadData];
            
        } else {
            [self.tableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.tableView reloadData];
    }];
}
/*
 *  解析用户头像列表
 *
 *  @param albumArray
 */
- (void)paraseUserAlbum:(NSArray *)albumArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (id album in albumArray) {
        [array addObject:[[AlbumImage alloc] initWithJson:album]];
    }
    AccountManager *accountManager = [AccountManager shareAccountManager];
    accountManager.account.userAlbum = array;
    _pictureNumber.text = [NSString stringWithFormat:@"%zd图",array.count];
    NSLog(@"%@",array);
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




