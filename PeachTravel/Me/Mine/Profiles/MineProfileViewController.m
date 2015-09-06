//
//  MineProfileViewController.m
//  PeachTravel
//
//  Created by 王聪 on 8/31/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "MineProfileViewController.h"
#import "MineDetailInfoCell.h"
#import "MineProfileTitleView.h"
#import "BaseProfileHeaderView.h"

@interface MineProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *albumArray;

@end

@implementation MineProfileViewController

#pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _albumArray = [NSMutableArray array];
    self.view.backgroundColor = APP_PAGE_COLOR;
    self.userInfo = [AccountManager shareAccountManager].account;
    
    [self setupTableView];
}

#pragma mark - 设置tableView的一些属性
- (void)setupTableView
{
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.frame = CGRectMake(0, -50, kWindowWidth, kWindowHeight+50);
    self.tableView.contentOffset = CGPointMake(0, 50);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    BaseProfileHeaderView *headerView = [BaseProfileHeaderView profileHeaderView];
    headerView.frame = CGRectMake(0, 0, kWindowWidth, 200);
    self.tableView.tableHeaderView = headerView;
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
        GuiderProfileTourViewCell *profileTourCell = [GuiderProfileTourViewCell guiderProfileTourWithTableView:tableView];
        profileTourCell.tourTitle.text = @"我的旅行";
        profileTourCell.footprintCount.text = _userInfo.footprintsDesc;
        profileTourCell.planCount.text = [NSString stringWithFormat:@"%ld篇",_userInfo.guideCnt];
        profileTourCell.tourCount.text = [NSString stringWithFormat:@"%ld份",_userInfo.footprints.count];
        // 添加事件
        [profileTourCell.footprintBtn addTarget:self action:@selector(visitTracks) forControlEvents:UIControlEventTouchUpInside];
        [profileTourCell.planBtn addTarget:self action:@selector(seeOthersPlan) forControlEvents:UIControlEventTouchUpInside];
        [profileTourCell.tourBtn addTarget:self action:@selector(seeOtherTour) forControlEvents:UIControlEventTouchUpInside];
        profileTourCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return profileTourCell;
    } else {
        GuiderProfileAbout *cell = [[GuiderProfileAbout alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.titleLab.text = @"关于自己";
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
    [titleView.titleBtn setTitle:@"我的相册" forState:UIControlStateNormal];
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
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:chatController];
    chatController.chatterName = _userInfo.nickName;
    
    ChatSettingViewController *menuViewController = [[ChatSettingViewController alloc] init];
    menuViewController.currentConversation= conversation;
    menuViewController.chatterId = _userId;
    
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:navi menuViewController:menuViewController];
    menuViewController.containerCtl = frostedViewController;
    frostedViewController.direction = REFrostedViewControllerDirectionRight;
    frostedViewController.liveBlurBackgroundStyle = REFrostedViewControllerLiveBackgroundStyleLight;
    frostedViewController.liveBlur = YES;
    frostedViewController.limitMenuViewSize = YES;
    frostedViewController.resumeNavigationBar = NO;
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
