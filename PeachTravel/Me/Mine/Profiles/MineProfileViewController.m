//
//  MineProfileViewController.m
//  PeachTravel
//
//  Created by 王聪 on 8/31/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "MineProfileViewController.h"
#import "MineProfileTitleView.h"
#import "BaseProfileHeaderView.h"
#import "EditUserInfoTableViewController.h"
#import "MineProfileTourViewCell.h"
#import "MineViewContoller.h"

@interface MineProfileViewController () <UITableViewDataSource, UITableViewDataSource,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *albumArray;

@property (nonatomic, strong) AccountManager *accountManager;

@property (nonatomic, weak) UIView *navBgView;
@property (nonatomic, weak) UIButton *settingBtn;

@end

@implementation MineProfileViewController

#pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.accountManager = [AccountManager shareAccountManager];
    _albumArray = [NSMutableArray array];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.userInfo = [AccountManager shareAccountManager].account;
    [self loadUserAlbum];
    
    [self setupTableView];
    
    [self setupNavBar];
    
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
    
//    _pictureNumber.text = [NSString stringWithFormat:@"%zd张",array.count];
    
    NSLog(@"%@",array);
    self.albumArray = [albumArray mutableCopy];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    self.userInfo = [AccountManager shareAccountManager].account;
    [self.tableView reloadData];
    [self showUserShouldEditUserInfoNoti];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (![[self.navigationController.viewControllers lastObject]isKindOfClass:[MineViewContoller class]]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

#pragma mark - 设置导航栏

- (void)setupNavBar
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth,64)];
    bgView.alpha = 0;
    self.navBgView = bgView;
    bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_master"]];
    [self.view addSubview:bgView];
    
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth - 56, 33, 36, 19)];
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    editButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    [editButton addTarget:self action:@selector(editMineProfile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editButton];
    _settingBtn = editButton;
    
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

/**
 *  新注册的用户应该显示提醒用户编辑用户信息的提醒
 */
- (void)showUserShouldEditUserInfoNoti
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%ld", kShouldShowFinishUserInfoNoti, [AccountManager shareAccountManager].account.userId];
    BOOL shouldShowNoti = [[defaults objectForKey:key] boolValue] && [[AccountManager shareAccountManager] isLogin];
    if (shouldShowNoti) {
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(40, 2, 6, 6)];
        dotView.backgroundColor = [UIColor redColor];
        dotView.layer.cornerRadius = 3.0;
        dotView.clipsToBounds = YES;
        dotView.tag = 101;
        [_settingBtn addSubview:dotView];
    } else {
        for (UIView *view in _settingBtn.subviews) {
            if (view.tag == 101) {
                [view removeFromSuperview];
            }
        }
    }
}


#pragma mark - 设置tableView的一些属性
- (void)setupTableView
{
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    BaseProfileHeaderView *headerView = [[BaseProfileHeaderView alloc] init];
    headerView.frame = CGRectMake(0, 0, kWindowWidth, 310);
    headerView.accountModel = self.userInfo;
    headerView.image = [UIImage imageNamed:@"bg_master"];
    self.tableView.tableHeaderView = headerView;
}

- (void)editMineProfile
{
    EditUserInfoTableViewController *userInfo = [[EditUserInfoTableViewController alloc]init];
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
        profileTourCell.userInfo = self.userInfo;
        // 添加事件
        [profileTourCell.footprintBtn addTarget:self action:@selector(myTrack:) forControlEvents:UIControlEventTouchUpInside];
        [profileTourCell.planBtn addTarget:self action:@selector(myPlan:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewY:%f",scrollView.contentOffset.y);
    if (scrollView.contentOffset.y>140) return;
    self.navBgView.alpha = (scrollView.contentOffset.y+20)/160;
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


#pragma mark - IBAction Methods

- (IBAction)myTrack:(id)sender
{
    if (self.accountManager.isLogin) {
        FootPrintViewController *footCtl = [[FootPrintViewController alloc] init];
        AccountManager *amgr = self.accountManager;
        footCtl.hidesBottomBarWhenPushed = YES;
        footCtl.userId = amgr.account.userId;
        [self.navigationController pushViewController:footCtl animated:YES];
    } else  {
        [self userLogin];
    }
}

- (IBAction)myPlan:(id)sender
{
    if (self.accountManager.isLogin) {
        PlansListTableViewController *myGuidesCtl = [[PlansListTableViewController alloc] initWithUserId:_accountManager.account.userId];
        myGuidesCtl.hidesBottomBarWhenPushed = YES;
        myGuidesCtl.userName = _accountManager.account.nickName;
        [self.navigationController pushViewController:myGuidesCtl animated:YES];
    } else {
        [self userLogin];
    }
}


@end
