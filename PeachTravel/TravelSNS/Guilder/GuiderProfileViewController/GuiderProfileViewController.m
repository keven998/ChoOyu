//
//  GuiderProfileViewController.m
//  PeachTravel
//
//  Created by 王聪 on 8/27/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderProfileViewController.h"
#import "GuiderProfileHeaderView.h"
#import "GuiderDetailInfoCell.h"
#import "GuiderProfileAlbumCell.h"
#import "GuiderProfileTourViewCell.h"
#import "GuiderProfileAbout.h"

#import "PlansListTableViewController.h"
#import "HeaderCell.h"
#import "OtherUserBasicInfoCell.h"
#import "OthersAlbumCell.h"
#import "ChatViewController.h"
#import "ChatSettingViewController.h"
#import "AccountModel.h"
#import "UIBarButtonItem+MJ.h"
#import "REFrostedViewController.h"
#import "ChatGroupSettingViewController.h"
#import "UIImage+resized.h"
#import "ChatListViewController.h"
#import "MWPhotoBrowser.h"
#import "UserAlbumViewController.h"
#import "BaseTextSettingViewController.h"
#import "FootPrintViewController.h"
#import "CMPopTipView.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "LoginViewController.h"
#import "TZNavigationViewController.h"

@interface GuiderProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) FrendModel *userInfo;
@property (nonatomic, strong) NSMutableArray *albumArray;
@property (nonatomic, assign) BOOL isMyFriend;

@end

@implementation GuiderProfileViewController

#pragma mark - lifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];

    _albumArray = [NSMutableArray array];
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    _isMyFriend = [accountManager frendIsMyContact:_userId];
    
    [self loadUserProfile:_userId];
    self.view.backgroundColor = APP_PAGE_COLOR;
    
    self.tableView.showsVerticalScrollIndicator = NO;
}

#pragma mark - 设置视图
- (void)loadUserProfile:(NSInteger)userId
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [FrendManager loadUserInfoFromServer:userId completion:^(BOOL isSuccess, NSInteger errorCode, FrendModel * __nonnull frend) {
        if (isSuccess) {
            _userInfo = frend;
            [self loadUserAlbum];
//            [self updateUserInfo];
            
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
//    _albumLabel.text = [NSString stringWithFormat:@"%lu张", (long)_albumArray.count];
}

#pragma mark - DataSource or Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == 0) {
        GuiderDetailInfoCell *cell = [GuiderDetailInfoCell guiderDetailInfo];
        [cell.profileView.friendBtn addTarget:self action:@selector(talkToFriend) forControlEvents:UIControlEventTouchUpInside];
        [cell.profileView.sendBtn addTarget:self action:@selector(remarkFriend) forControlEvents:UIControlEventTouchUpInside];
        cell.userInfo = self.userInfo;
        cell.collectionArray = @[@"哈哈",@"嘿嘿和",@"呵呵呵呵",@"额额",@"哈哈",@"嘿嘿和",@"呵呵呵呵"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.section == 1) {
        GuiderProfileAlbumCell *albumCell = [[GuiderProfileAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        albumCell.albumArray = self.albumArray;
        albumCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return albumCell;
    } else if (indexPath.section == 2) {
        GuiderProfileTourViewCell *profileTourCell = [GuiderProfileTourViewCell guiderProfileTourWithTableView:tableView];
        profileTourCell.footprintCount.text = _userInfo.footprintDescription;
        profileTourCell.planCount.text = [NSString stringWithFormat:@"%ld篇",_userInfo.guideCount];
        [profileTourCell.footprintBtn addTarget:self action:@selector(visitTracks) forControlEvents:UIControlEventTouchUpInside];
        [profileTourCell.planBtn addTarget:self action:@selector(seeOthersPlan) forControlEvents:UIControlEventTouchUpInside];
        profileTourCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return profileTourCell;
    } else if (indexPath.section == 3) {
        GuiderProfileAbout *cell = [[GuiderProfileAbout alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.titleLab.text = @"关于达人";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
        GuiderProfileAbout *cell = [[GuiderProfileAbout alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.titleLab.text = @"派派点评";
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
        return kWindowWidth + 240;
    } else if (indexPath.section == 1) {
        return 140;
    } else if (indexPath.section == 2) {
        return 130;
    }
    return 150;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = APP_PAGE_COLOR;
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 4) {
        return 0;
    }
    return 10;
}

#pragma ActionEvent
/**
 *  修改好友备注
 */
- (void)remarkFriend
{
    BaseTextSettingViewController *bsvc = [[BaseTextSettingViewController alloc] init];
    bsvc.navTitle = @"修改备注";
    if (_userInfo.memo.length > 0) {
        bsvc.content = _userInfo.memo;
    } else {
        bsvc.content = _userInfo.nickName;
    }
    bsvc.acceptEmptyContent = NO;
    bsvc.saveEdition = ^(NSString *editText, saveComplteBlock(completed)) {
        [self confirmChange:editText withContacts:_userInfo success:completed];
    };
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:bsvc] animated:YES completion:nil];
}

- (void)confirmChange:(NSString *)text withContacts:(FrendModel *)contact success:(saveComplteBlock)completed
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    contact.memo = text;
    completed(YES);
    [accountManager asyncChangeRemark:text withUserId:contact.userId completion:^(BOOL isSuccess) {
        if (isSuccess) {
        } else {
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
}


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

- (void)visitTracks
{
    [MobClick event:@"button_item_tracks"];
    FootPrintViewController *footPrintCtl = [[FootPrintViewController alloc] init];
    footPrintCtl.userId = _userId;
    [self.navigationController pushViewController:footPrintCtl animated:YES];
    
}
- (void)seeOthersPlan
{
    [MobClick event:@"button_item_plan"];
    PlansListTableViewController *listCtl = [[PlansListTableViewController alloc]initWithUserId:_userInfo.userId];
    listCtl.userName = _userInfo.nickName;
    [self.navigationController pushViewController:listCtl animated:YES];
}

@end
