//
//  OtherProfileViewController.m
//  PeachTravel
//
//  Created by 王聪 on 9/8/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "OtherProfileViewController.h"
#import "MineProfileTitleView.h"
#import "BaseProfileHeaderView.h"
#import "UserInfoTableViewController.h"
#import "MineProfileTourViewCell.h"
#import "MineViewContoller.h"

@interface OtherProfileViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *albumArray;

@end

@implementation OtherProfileViewController

#pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _albumArray = [NSMutableArray array];
    
    [self loadUserProfile:_userId];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    [self setupTableView];
    
    [self setupNavBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (![[self.navigationController.viewControllers lastObject]isKindOfClass:[MineViewContoller class]]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}


#pragma mark - 设置视图
- (void)loadUserProfile:(NSInteger)userId
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [FrendManager loadUserInfoFromServer:userId completion:^(BOOL isSuccess, NSInteger errorCode, FrendModel * __nonnull frend) {
        if (isSuccess) {
            _userInfo = frend;
            [self loadUserAlbum];
            [self setupTableView];
            [self.tableView reloadData];
        } else {
            [SVProgressHUD showHint:@"请求失败"];
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}

- (void)loadUserAlbum
{
    AccountManager *account = [AccountManager shareAccountManager];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%ld", (long)account.account.userId] forHTTPHeaderField:@"UserId"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%ld/albums", API_USERS, (long)_userId];
    
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            [self paraseUserAlbum:[responseObject objectForKey:@"result"]];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

- (void)paraseUserAlbum:(NSArray *)albumArray
{
    for (id album in albumArray) {
        [_albumArray addObject:[[AlbumImage alloc] initWithJson:album]];
    }
    _userInfo.userAlbum = _albumArray;
    
    [self.tableView reloadData];
}


#pragma mark - 设置导航栏

- (void)setupNavBar
{
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth - 56, 33, 36, 19)];
    [editButton setTitle:@"设置" forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    editButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    [editButton addTarget:self action:@selector(editMineProfile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editButton];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake((kWindowWidth-108)*0.5, 33, 108, 19)];
    titleLab.text = @"我的·旅行派";
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont boldSystemFontOfSize:18.0];
    titleLab.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLab];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake( 10, 33, 36, 19)];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

#pragma mark - 设置tableView的一些属性
- (void)setupTableView
{
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    BaseProfileHeaderView *headerView = [[BaseProfileHeaderView alloc] init];
    headerView.frame = CGRectMake(0, 0, kWindowWidth, 310);
    headerView.userInfo = self.userInfo;
    headerView.image = [UIImage imageNamed:@"bg_master"];
    self.tableView.tableHeaderView = headerView;
}

- (void)editMineProfile
{
    UserInfoTableViewController *userInfo = [[UserInfoTableViewController alloc]init];
    [self.navigationController pushViewController:userInfo animated:YES];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - DataSource or Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        GuiderProfileAlbumCell *albumCell = [[GuiderProfileAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        albumCell.albumArray = self.userInfo.userAlbum;
        albumCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return albumCell;
    } else if (indexPath.section == 1) {
        MineProfileTourViewCell *profileTourCell = [[MineProfileTourViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        profileTourCell.otherUserinfo = self.userInfo;
        // 添加事件
        [profileTourCell.footprintBtn addTarget:self action:@selector(visitTracks) forControlEvents:UIControlEventTouchUpInside];
        [profileTourCell.planBtn addTarget:self action:@selector(seeOthersPlan) forControlEvents:UIControlEventTouchUpInside];
        [profileTourCell.tourBtn addTarget:self action:@selector(seeOtherTour) forControlEvents:UIControlEventTouchUpInside];
        profileTourCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return profileTourCell;
    } else {
        GuiderProfileAbout *cell = [[GuiderProfileAbout alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.content = self.userInfo.signature;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 140;
    } else if (indexPath.section == 1) {
        return 130;
    } else {
        if (self.userInfo.signature.length == 0) return 50 + 40;
        CGSize size = CGSizeMake(kWindowWidth - 40,CGFLOAT_MAX);//LableWight标签宽度，固定的
        
        //计算实际frame大小，并将label的frame变成实际大小
        NSDictionary *dict = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0]};
        CGSize contentSize = [self.userInfo.signature boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
        return 50 + contentSize.height + 20;
    }
    return 150;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}


// 头部和尾部
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MineProfileTitleView *titleView = [[MineProfileTitleView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 50)];
    if (section == 0) {
        [titleView.titleBtn setTitle:@"我的相册" forState:UIControlStateNormal];
    } else if (section == 1) {
        [titleView.titleBtn setTitle:@"我的旅历" forState:UIControlStateNormal];
    } else {
        [titleView.titleBtn setTitle:@"关于自己" forState:UIControlStateNormal];
    }
    return titleView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = nil;
    if (section != 3) {
        footer = [[UIView alloc] init];
        footer.backgroundColor = APP_PAGE_COLOR;
        UIButton *topLine = [UIButton buttonWithType:UIButtonTypeCustom];
        topLine.backgroundColor = UIColorFromRGB(0x000000);
        topLine.alpha = 0.1;
        topLine.frame = CGRectMake(0, 0, kWindowWidth, 1);
        [footer addSubview:topLine];
    }
    
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        return 0;
    }
    return 10;
}

#pragma ActionEvent


- (void)talkToFriend
{
    
    if ([AccountManager shareAccountManager].isLogin) {
        [self pushChatViewController];
    } else {
        [self userLogin];
    }
}

#pragma mark - IBAction Methods

- (void)userLogin
{
    if ([AccountManager shareAccountManager].isLogin) {
        return;
    }
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
    loginCtl.isPushed = NO;
    [self.navigationController presentViewController:nctl animated:YES completion:nil];
}

- (void)pushChatViewController
{
    IMClientManager *manager = [IMClientManager shareInstance];
    ChatConversation *conversation = [manager.conversationManager getConversationWithChatterId:_userId chatType:IMChatTypeIMChatSingleType];
    [manager.conversationManager addConversation: conversation];
    
    ChatViewController *chatController = [[ChatViewController alloc] initWithChatter:_userId chatType:IMChatTypeIMChatSingleType];
    chatController.chatterName = _userInfo.nickName;
    
    ChatSettingViewController *menuViewController = [[ChatSettingViewController alloc] init];
    menuViewController.currentConversation= conversation;
    menuViewController.chatterId = _userId;
    
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:chatController menuViewController:menuViewController];
    menuViewController.containerCtl = frostedViewController;
    frostedViewController.direction = REFrostedViewControllerDirectionRight;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.limitMenuViewSize = YES;
    self.navigationController.interactivePopGestureRecognizer.delaysTouchesBegan = NO;
    [self.navigationController pushViewController:frostedViewController animated:YES];
    
    __weak ChatViewController *viewController = chatController;
    if (![self.navigationController.viewControllers.firstObject isKindOfClass:[ChatListViewController class]]) {
        chatController.backBlock = ^(){
            [viewController.frostedViewController.navigationController popViewControllerAnimated:YES];
        };
    }
}

#pragma mark - buttonMethod
// 浏览足迹
- (void)visitTracks
{
    [MobClick event:@"button_item_tracks"];
    FootPrintViewController *footPrintCtl = [[FootPrintViewController alloc] init];
    footPrintCtl.userId = _userId;
    [self.navigationController pushViewController:footPrintCtl animated:YES];
    
}
// 查看他人计划
- (void)seeOthersPlan
{
    [MobClick event:@"button_item_plan"];
    PlansListTableViewController *listCtl = [[PlansListTableViewController alloc]initWithUserId:_userInfo.userId];
    listCtl.userName = _userInfo.nickName;
    [self.navigationController pushViewController:listCtl animated:YES];
}
// 查看他人游记
- (void)seeOtherTour
{
    
}

@end
