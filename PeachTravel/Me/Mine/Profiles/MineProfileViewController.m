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
#import "UserAlbumManager.h"
#import "StoreManager.h"
#import "UserAlbumReviewViewController.h"
#import "StoreDetailViewController.h"

@interface MineProfileViewController () <UITableViewDataSource, UITableViewDataSource,UIScrollViewDelegate, GuiderProfileAlbumCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) BaseProfileHeaderView *headerView;
@property (nonatomic, weak) UIView *navBgView;
@property (nonatomic, weak) UIButton *settingBtn;

@property (nonatomic, strong) AccountManager *accountManager;
@property (nonatomic) BOOL isSeller;

@end

@implementation MineProfileViewController

#pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.accountManager = [AccountManager shareAccountManager];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.userInfo = [AccountManager shareAccountManager].account;
    [self loadUserAlbum];
    [[AccountManager shareAccountManager].account loadUserInfoFromServer:^(bool isSuccess) {
        self.userInfo = [AccountManager shareAccountManager].account;
    }];
    [self setupTableView];
    
    [self setupNavBar];
}

//下载用户头像列表
- (void)loadUserAlbum
{
    [UserAlbumManager asyncLoadUserAlbum:[AccountManager shareAccountManager].account.userId  completion:^(BOOL isSuccess, NSArray *albumList) {
        if (isSuccess) {
            _userInfo.userAlbum = [albumList mutableCopy];
            [self.tableView reloadData];
        } else {
            [SVProgressHUD showHint:@"相册获取失败"];
            [self.tableView reloadData];
        }
    }];
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

- (void)dealloc
{
    self.tableView.delegate = nil;
}

- (void)setUserInfo:(AccountModel *)userInfo
{
    _userInfo = userInfo;
    _headerView.accountModel = _userInfo;
    [self.tableView reloadData];
}

#pragma mark - 设置导航栏

- (void)setupNavBar
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth,64)];
    bgView.alpha = 0;
    self.navBgView = bgView;
    bgView.backgroundColor = APP_NAVIGATIONBAR_NOALPHA;
    [self.view addSubview:bgView];
    
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth - 56, 20, 40, 40)];
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    editButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    
    [editButton addTarget:self action:@selector(editMineProfile) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editButton];
    _settingBtn = editButton;
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake((kWindowWidth-108)*0.5, 20, 108, 40)];
    titleLab.text = @"我的·旅行派";
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = [UIFont boldSystemFontOfSize:16.0];
    titleLab.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLab];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 40, 40)];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
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

    _headerView = [[BaseProfileHeaderView alloc] init];
    _headerView.frame = CGRectMake(0, 0, kWindowWidth, 310);
    _headerView.contentMode = UIViewContentModeScaleAspectFill;
    _headerView.clipsToBounds = YES;
    _headerView.accountModel = self.userInfo;
    _headerView.image = [UIImage imageNamed:@"icon_profile_bg"];
    self.tableView.tableHeaderView = _headerView;
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
    if (_isSeller) {
        return 4;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isSeller) {
        if (indexPath.section == 0) {
            GuiderProfileAlbumCell *albumCell = [[GuiderProfileAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            albumCell.delegate = self;
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
        
    } else {
        if (indexPath.section == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.text = @"我的店铺";
            return cell;
            
        } else if (indexPath.section == 1) {
            GuiderProfileAlbumCell *albumCell = [[GuiderProfileAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            albumCell.delegate = self;
            albumCell.albumArray = self.userInfo.userAlbum;
            albumCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return albumCell;
            
        } else if (indexPath.section == 2) {
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (_isSeller && indexPath.section == 0) {
        StoreDetailViewController *ctl = [[StoreDetailViewController alloc] init];
        ctl.storeId = [AccountManager shareAccountManager].account.userId;
        [self.navigationController pushViewController:ctl animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isSeller) {
        if (indexPath.section == 0) {
            return 50;
            
        } else if (indexPath.section == 1) {
            return 140;
            
        } else if (indexPath.section == 2) {
            return 130;
            
        } else {
            if (self.userInfo.signature.length == 0) return 50 + 40;
            CGSize size = CGSizeMake(kWindowWidth - 40,CGFLOAT_MAX);//LableWight标签宽度，固定的
            
            //计算实际frame大小，并将label的frame变成实际大小
            NSDictionary *dict = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0]};
            CGSize contentSize = [self.userInfo.signature boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
            return 50 + contentSize.height + 20;
        }
        
    } else {
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
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (_isSeller && section == 0) {
        return 0;
    }
    return 50;
}

// 头部和尾部
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_isSeller) {
        if (section == 0) {
            return nil;
        }
        MineProfileTitleView *titleView = [[MineProfileTitleView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 50)];
        if (section == 1) {
            [titleView.titleBtn setTitle:@"我的相册" forState:UIControlStateNormal];
            NSString *albumCount = [NSString stringWithFormat:@"%ld图",self.userInfo.userAlbum.count];
            titleView.countLab.text = albumCount;
            titleView.iconImage.image = [UIImage imageNamed:@"picture_biaoti"];
        } else if (section == 2) {
            [titleView.titleBtn setTitle:@"我的旅历" forState:UIControlStateNormal];
            titleView.iconImage.image = [UIImage imageNamed:@"travel_biaoti"];
        } else {
            [titleView.titleBtn setTitle:@"关于自己" forState:UIControlStateNormal];
            titleView.iconImage.image = [UIImage imageNamed:@"about"];
        }
        return titleView;

    } else {
        MineProfileTitleView *titleView = [[MineProfileTitleView alloc] initWithFrame:CGRectMake(0, 0, kWindowWidth, 50)];
        if (section == 0) {
            [titleView.titleBtn setTitle:@"我的相册" forState:UIControlStateNormal];
            NSString *albumCount = [NSString stringWithFormat:@"%ld图",self.userInfo.userAlbum.count];
            titleView.countLab.text = albumCount;
            titleView.iconImage.image = [UIImage imageNamed:@"picture_biaoti"];
        } else if (section == 1) {
            [titleView.titleBtn setTitle:@"我的旅历" forState:UIControlStateNormal];
            titleView.iconImage.image = [UIImage imageNamed:@"travel_biaoti"];
        } else {
            [titleView.titleBtn setTitle:@"关于自己" forState:UIControlStateNormal];
            titleView.iconImage.image = [UIImage imageNamed:@"about"];
        }
        return titleView;

    }
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
    if (scrollView.contentOffset.y < 0) {
        scrollView.contentOffset = CGPointZero;
    }
    CGFloat alpha = scrollView.contentOffset.y/150;
    if (alpha > 0.8) {
        alpha = 1;
    }
    if (alpha < 0.2) {
        alpha = 0;
    }
    _navBgView.alpha = alpha;
}


#pragma mark - GuiderProfileAlbumCellDelegate

- (void)didSelectItemWitnIndexPath:(NSIndexPath *)indexPath
{
    UserAlbumReviewViewController *ctl = [[UserAlbumReviewViewController alloc] init];
    ctl.dataSource = self.userInfo.userAlbum;
    ctl.currentIndex = indexPath.row;
    ctl.canEidt = YES;
    [self.navigationController pushViewController:ctl animated:YES];
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
