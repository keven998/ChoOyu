//
//  GuiderProfileViewController.m
//  PeachTravel
//
//  Created by 王聪 on 8/27/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

#import "GuiderProfileViewController.h"
#import "MineProfileTitleView.h"
#import "ExpertProfileTagViewCell.h"
#import "BaseProfileHeaderView.h"
@interface GuiderProfileViewController () <UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) FrendModel *userInfo;
@property (nonatomic, strong) NSMutableArray *albumArray;
@property (nonatomic, assign) BOOL isMyFriend;

@property (nonatomic, strong) UIButton *addFriendBtn;
@property (nonatomic, strong) UIButton *beginTalk;

@property (nonatomic, strong) NSArray *tags;

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

    UIButton *moreBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
    [moreBtn setImage:[UIImage imageNamed:@"account_icon_any_default"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    [moreBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    
//    [self setupTableView];
    [self setupHeaderView];
    [self createFooterBar];
    [self setupNavBar];
    
    self.tags = @[@"哈哈",@"嘿嘿和",@"呵呵呵呵",@"额额",@"哈哈",@"嘿嘿和",@"呵呵呵呵",@"哈哈",@"嘿嘿和",@"呵呵呵呵",@"额额",@"哈哈",@"嘿嘿和",@"呵呵呵呵",@"哈哈",@"嘿嘿和",@"呵呵呵呵",@"额额",@"哈哈",@"嘿嘿和"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"page_user_profile"];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"page_user_profile"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark - 设置导航栏

- (void)setupNavBar
{
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(kWindowWidth - 56, 33, 36, 19)];
    [editButton setTitle:@"设置" forState:UIControlStateNormal];
    [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    editButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
//    [editButton addTarget:self action:@selector(editMineProfile) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:editButton];
    
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


- (void)setupHeaderView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 200, 18)];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:16];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    nameLabel.text = @"旅行达人";
    [view addSubview:nameLabel];
    UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 26, 200, 12)];
    idLabel.textColor = [UIColor whiteColor];
    idLabel.font = [UIFont boldSystemFontOfSize:10];
    idLabel.textAlignment = NSTextAlignmentCenter;
    idLabel.text = [NSString stringWithFormat:@"ID:%ld",_userId];
    [view addSubview:idLabel];
    self.navigationItem.titleView = view;

}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 设置tableView的一些属性
- (void)setupTableView
{
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    BaseProfileHeaderView *headerView = [[BaseProfileHeaderView alloc] init];
    headerView.image = [UIImage imageNamed:@"bg_master"];
    headerView.frame = CGRectMake(0, 0, kWindowWidth, 310);
    headerView.userInfo = self.userInfo;
    self.tableView.tableHeaderView = headerView;
}

- (void)createFooterBar
{
    UIImageView *barView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-49, CGRectGetWidth(self.view.bounds), 49)];
    barView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [barView setImage:[UIImage imageNamed:@"account_button_default.png"]];
    barView.contentMode = UIViewContentModeScaleToFill;
    barView.userInteractionEnabled = YES;
    [self.view addSubview:barView];
    
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    _beginTalk = [[UIButton alloc]initWithFrame:CGRectMake(kWindowWidth*0.5, 0, kWindowWidth*0.5, 48)];
    [_beginTalk setTitle:@"发送消息" forState:UIControlStateNormal];
    [_beginTalk setBackgroundImage:[UIImage new] forState:UIControlStateNormal];
    [_beginTalk setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    [_beginTalk setImage:[UIImage imageNamed:@"chat_friend"] forState:UIControlStateNormal];
//    [_beginTalk setBackgroundImage:[UIImage imageNamed:@"account_button_selected.png"] forState:UIControlStateHighlighted];
    _beginTalk.titleLabel.font = [UIFont systemFontOfSize:13];
    [_beginTalk setImageEdgeInsets:UIEdgeInsetsMake(3, -5, 0, 0)];
    [_beginTalk setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, -5)];
    [_beginTalk addTarget:self action:@selector(talkToFriend) forControlEvents:UIControlEventTouchUpInside];
    [barView addSubview:_beginTalk];
    
    _addFriendBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, kWindowWidth*0.5, 48)];
    
    _addFriendBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_addFriendBtn setTitleColor:COLOR_TEXT_II forState:UIControlStateNormal];
    [_addFriendBtn setImage:[UIImage imageNamed:@"add_friend"] forState:UIControlStateNormal];
    [_addFriendBtn setBackgroundImage:[UIImage new] forState:UIControlStateHighlighted];
//    [_addFriendBtn setBackgroundImage:[UIImage imageNamed:@"account_button_selected.png"] forState:UIControlStateHighlighted];
    [_addFriendBtn setImageEdgeInsets:UIEdgeInsetsMake(3, -5, 0, 0)];
    [_addFriendBtn setTitleEdgeInsets:UIEdgeInsetsMake(4, 0, 0, -5)];
    [barView addSubview:_addFriendBtn];
    
    if ([accountManager frendIsMyContact:_userId]) {
        [_addFriendBtn setTitle:@"修改备注" forState:UIControlStateNormal];
        [_addFriendBtn addTarget:self action:@selector(remarkFriend) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [_addFriendBtn setTitle:@"加为朋友" forState:UIControlStateNormal];
        [_addFriendBtn addTarget:self action:@selector(addToFriend) forControlEvents:UIControlEventTouchUpInside];
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    BOOL isNotShouldShowTipsView = [[[NSUserDefaults standardUserDefaults] objectForKey:@"kShowExpertTipsView"] boolValue];
    if (!isNotShouldShowTipsView && _shouldShowExpertTipsView) {
//        [self showExpertTipsViewWithView:_beginTalk];
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
        ExpertProfileTagViewCell *cell = [ExpertProfileTagViewCell expertDetailInfo];
        cell.userInfo = self.userInfo;
        cell.collectionArray = self.tags;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else if (indexPath.section == 1) {
        GuiderProfileAlbumCell *albumCell = [[GuiderProfileAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        albumCell.albumArray = self.albumArray;
        albumCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return albumCell;
    } else if (indexPath.section == 2) {
        GuiderProfileTourViewCell *profileTourCell = [[GuiderProfileTourViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        profileTourCell.userInfo = self.userInfo;
        profileTourCell.footprintCount.text = _userInfo.footprintDescription;
        profileTourCell.planCount.text = [NSString stringWithFormat:@"%ld篇",_userInfo.guideCount];
        
        // 添加事件
        [profileTourCell.footprintBtn addTarget:self action:@selector(visitTracks) forControlEvents:UIControlEventTouchUpInside];
        [profileTourCell.planBtn addTarget:self action:@selector(seeOthersPlan) forControlEvents:UIControlEventTouchUpInside];
        [profileTourCell.tourBtn addTarget:self action:@selector(seeOtherTour) forControlEvents:UIControlEventTouchUpInside];
        
        profileTourCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return profileTourCell;
    } else if (indexPath.section == 3) {
        GuiderProfileAbout *cell = [[GuiderProfileAbout alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.content = self.userInfo.signature;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
        GuiderProfileAbout *cell = [[GuiderProfileAbout alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.content = self.userInfo.profile;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

// 计算collectionViewCell的高度
- (CGFloat)calculateTagsHeight
{
    NSArray *tags = self.tags;
    CGFloat tagSumH = 50;
    CGFloat tagSumW = 0;
    for (NSString *tag in tags) {
        CGSize size = CGSizeMake(kWindowWidth - 40,CGFLOAT_MAX);
        NSDictionary *dict = @{NSFontAttributeName: [UIFont systemFontOfSize:17.0]};
        CGSize contentSize = [tag boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
        tagSumW += contentSize.width+10;
        if (tagSumW > kWindowWidth-20) {
            tagSumW = 0;
            tagSumH += 50;
        }
    }
    return tagSumH;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self calculateTagsHeight]+10;
    } else if (indexPath.section == 1) {
        CGFloat collectionW = (kWindowWidth-10-20) / 3;
        return collectionW + 20;
    } else if (indexPath.section == 2) {
        return 132;
    } else if (indexPath.section == 3) {
        if (self.userInfo.signature.length == 0) return 50;
        CGSize size = CGSizeMake(kWindowWidth - 40,CGFLOAT_MAX);//LableWight标签宽度，固定的
        
        //计算实际frame大小，并将label的frame变成实际大小
        NSDictionary *dict = @{NSFontAttributeName: [UIFont systemFontOfSize:18.0]};
        CGSize contentSize = [self.userInfo.signature boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
        return contentSize.height + 34;
    } else if (indexPath.section == 4) {
        if (self.userInfo.profile.length == 0) return 50;
        CGSize size = CGSizeMake(kWindowWidth - 40,CGFLOAT_MAX);//LableWight标签宽度，固定的
        //计算实际frame大小，并将label的frame变成实际大小
        NSDictionary *dict = @{NSFontAttributeName: [UIFont systemFontOfSize:18.0]};
        CGSize contentSize = [self.userInfo.profile boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil].size;
        return contentSize.height + 34;
    }
    return 150;
}

#pragma mark - 设置头部和尾部
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MineProfileTitleView *titleView = [[MineProfileTitleView alloc] init];
    
    if (section == 0) {
        [titleView.titleBtn setTitle:@"旅行派·达人·咨询师" forState:UIControlStateNormal];
        titleView.countLab.text = @"达人标签";
        titleView.iconImage.image = [UIImage imageNamed:@"master"];
    } else if (section == 1) {
        NSString *title = [NSString stringWithFormat:@"%@的相册",_userInfo.nickName];
        [titleView.titleBtn setTitle:title forState:UIControlStateNormal];
        NSString *albumCount = [NSString stringWithFormat:@"%ld图",self.albumArray.count];
        titleView.countLab.text = albumCount;
        titleView.iconImage.image = [UIImage imageNamed:@"picture_biaoti"];
    } else if (section == 2) {
        NSString *title = [NSString stringWithFormat:@"%@的旅行",_userInfo.nickName];
        [titleView.titleBtn setTitle:title forState:UIControlStateNormal];
        titleView.iconImage.image = [UIImage imageNamed:@"travel_biaoti"];
    } else if (section == 3) {
        NSString *title = [NSString stringWithFormat:@"关于%@",_userInfo.nickName];
        [titleView.titleBtn setTitle:title forState:UIControlStateNormal];
        titleView.iconImage.image = [UIImage imageNamed:@"about"];
    } else {
        [titleView.titleBtn setTitle:@"派派点评" forState:UIControlStateNormal];
        titleView.iconImage.image = [UIImage imageNamed:@"paipai"];
    }
    return titleView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [[UIView alloc] init];
    footer.backgroundColor = APP_PAGE_COLOR;
    UIButton *topLine = [UIButton buttonWithType:UIButtonTypeCustom];
    topLine.backgroundColor = UIColorFromRGB(0x000000);
    topLine.alpha = 0.05;
    topLine.frame = CGRectMake(0, 0, kWindowWidth, 1);
    [footer addSubview:topLine];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36;
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

- (void)addToFriend
{
    
    if ([AccountManager shareAccountManager].isLogin) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"朋友验证" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *nameTextField = [alert textFieldAtIndex:0];
        AccountManager *accountManager = [AccountManager shareAccountManager];
        nameTextField.text = [NSString stringWithFormat:@"Hi, 我是%@", accountManager.account.nickName];
        [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self requestAddContactWithHello:nameTextField.text];
            }
        }];
    } else {
        [self userLogin];
    }
}

#pragma mark - HTTP请求
#pragma mark - http method

/**
 *  邀请好友
 *
 *  @param helloStr
 */
- (void)requestAddContactWithHello:(NSString *)helloStr
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    
    FrendManager *frendManager = [IMClientManager shareInstance].frendManager;
    if ([helloStr stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0) {
        helloStr = [NSString stringWithFormat:@"Hi, 我是%@", accountManager.account.nickName];
    }
    __weak typeof(GuiderProfileViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf content:64];
    [frendManager asyncRequestAddContactWithUserId:_userId helloStr:helloStr completion:^(BOOL isSuccess, NSInteger errorCode) {
        [hud hideTZHUD];
        if (isSuccess) {
            [SVProgressHUD showHint:@"请求已发送，等待对方验证"];
        } else {
            [SVProgressHUD showHint:@"添加失败"];
        }
    }];
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

#pragma mark - 点击更多按钮
- (IBAction)moreAction:(UIButton *)sender
{
    UIActionSheet *sheet;
    if (_isMyFriend) {
        sheet = [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:self
                                   cancelButtonTitle:@"取消"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:@"删除朋友", nil];
    } else {
        
        NSString *actionSheetTitle = nil;
        BOOL isBlackUser = [FrendModel typeIsCorrect:_userInfo.type typeWeight:IMFrendWeightTypeBlackList];
        if (isBlackUser) {
            // 如果已经是黑名单,则显示取消屏蔽用户
            actionSheetTitle = @"取消屏蔽用户";
        } else {
            actionSheetTitle = @"屏蔽用户";
        }
        sheet = [[UIActionSheet alloc] initWithTitle:nil
                                            delegate:self
                                   cancelButtonTitle:@"取消"
                              destructiveButtonTitle:nil
                                   otherButtonTitles:actionSheetTitle, nil];
    }
    
    [sheet showInView:self.view];
}

- (void)removeContact
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    FrendManager *frendManager = [IMClientManager shareInstance].frendManager;
    __weak typeof(GuiderProfileViewController *)weakSelf = self;
    TZProgressHUD *hud = [[TZProgressHUD alloc] init];
    [hud showHUDInViewController:weakSelf];
    
    [frendManager asyncRemoveContactWithUserId:_userId completion:^(BOOL isSuccess, NSInteger errorCode) {
        [hud hideTZHUD];
        
        if (isSuccess) {
            [accountManager removeContact:_userInfo];
            [SVProgressHUD showHint:@"已删除～"];
            [[NSNotificationCenter defaultCenter] postNotificationName:contactListNeedUpdateNoti object:nil];
            [self performSelector:@selector(goBack) withObject:nil afterDelay:0.4];
            
        } else {
            if (self.isShowing) {
                [SVProgressHUD showHint:@"请求也是失败了"];
            }
        }
    }];
}

/**
 *  屏蔽用户
 */
- (void)blackUser
{
    // 用户类型如果不是黑名单类型,则屏蔽用户
    if (![FrendModel typeIsCorrect:_userInfo.type typeWeight:IMFrendWeightTypeBlackList]) {
        
        __weak typeof(GuiderProfileViewController *)weakSelf = self;
        TZProgressHUD *hud = [[TZProgressHUD alloc] init];
        [hud showHUDInViewController:weakSelf];
        FrendManager *frendManager = [IMClientManager shareInstance].frendManager;
        
        // 屏蔽用户
        [frendManager asyncBlackContactWithUserId:_userId completion:^(BOOL isSuccess, NSInteger errorCode) {
            [hud hideTZHUD];
            
            if (isSuccess) {
                _userInfo.type = _userInfo.type + IMFrendWeightTypeBlackList;
                [SVProgressHUD showHint:@"已屏蔽用户"];
            }
        }];
        
    } else {  // 用户类型如果是黑名单类型,则取消屏蔽用户
        __weak typeof(GuiderProfileViewController *)weakSelf = self;
        TZProgressHUD *hud = [[TZProgressHUD alloc] init];
        [hud showHUDInViewController:weakSelf];
        FrendManager *frendManager = [IMClientManager shareInstance].frendManager;
        
        // 取消屏蔽用户
        [frendManager asyncCancelBlackContactWithUserId:_userId completion:^(BOOL isSuccess, NSInteger errorCode) {
            [hud hideTZHUD];
            _userInfo.type = _userInfo.type - IMFrendWeightTypeBlackList;
            if (isSuccess) {
                [SVProgressHUD showHint:@"取消用户屏蔽成功"];
            }
        }];
        
    }
}

//显示达人交流的引导页面
- (void)showExpertTipsViewWithView:(UIView *)sourceView
{
    CMPopTipView *tipView = [[CMPopTipView alloc] initWithMessage:@"有问题可以向达人请教噢"];
    tipView.backgroundColor = APP_THEME_COLOR;
    tipView.dismissTapAnywhere = YES;
    tipView.hasGradientBackground = NO;
    tipView.hasShadow = YES;
    tipView.borderColor = APP_THEME_COLOR;
    tipView.sidePadding = 5;
    tipView.maxWidth = 110;
    tipView.has3DStyle = NO;
    [tipView presentPointingAtView:sourceView inView:self.view animated:YES];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"kShowExpertTipsView"];
}

#pragma mark - UIActionsheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSString *message = nil;
        BOOL isBlackUser = [FrendModel typeIsCorrect:_userInfo.type typeWeight:IMFrendWeightTypeBlackList];
        if(_isMyFriend) {
            message = @"确定删除好友?";
        } else {
            if (isBlackUser) {
                // 如果已经是黑名单,则显示取消屏蔽用户
                message = @"确定取消屏蔽用户?";
            } else {
                message = @"确定屏蔽用户?";
            }
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if (_isMyFriend) {
                    [self removeContact];
                } else {
                    [self blackUser];
                }
            }
        }];
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
