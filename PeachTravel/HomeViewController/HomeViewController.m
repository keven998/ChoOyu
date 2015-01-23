//
//  HomeViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/1.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "HomeViewController.h"
#import "ToolBoxViewController.h"
#import "HotDestinationCollectionViewController.h"
#import "MineTableViewController.h"
#import "RDVTabBarItem.h"
#import <QuartzCore/QuartzCore.h>
#import "PageOne.h"
#import "PageTwo.h"
#import "PageThree.h"
#import "EAIntroView.h"
#import "TZCMDChatHelper.h"
#import "IMRootViewController.h"
#import "ContactListViewController.h"
#import "ChatListViewController.h"
#import "LoginViewController.h"

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;

@interface HomeViewController ()<UIGestureRecognizerDelegate, EAIntroDelegate, IChatManagerDelegate, MHTabBarControllerDelegate>

@property (nonatomic, strong) UIImageView *coverView;

@property (strong, nonatomic) NSDate *lastPlaySoundDate;

@property (nonatomic, strong) ToolBoxViewController *toolBoxCtl;
@property (nonatomic, strong) HotDestinationCollectionViewController *hotDestinationCtl;
@property (nonatomic, strong) MineTableViewController *mineCtl;

@property (nonatomic, strong) PageOne *pageView1;
@property (nonatomic, strong) PageTwo *pageView2;
@property (nonatomic, strong) PageThree *pageView3;

@end

@implementation HomeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupViewControllers];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = YES;
    [self setupConverView];
    //获取未读消息数，此时并没有把self注册为SDK的delegate，读取出的未读数是上次退出程序时的
    [self didUnreadMessagesCountChanged];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_shouldJumpToChatListWhenAppLaunch && _coverView != nil) {
        [_coverView removeFromSuperview];
        _coverView = nil;
        [self jumpToChatListCtl];
    }
    
    if (_coverView != nil) {
        NSString *backGroundImageStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"backGroundImage"];
        [_coverView sd_setImageWithURL:[NSURL URLWithString:backGroundImageStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                _coverView.image = [UIImage imageNamed:@"story_default.png"];
            }
        }];
        [self loadData];
    }
    self.navigationController.navigationBar.hidden = YES;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)dealloc
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void) setupConverView {

    _coverView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _coverView.userInteractionEnabled = YES;
    _coverView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
   
    [self.view addSubview:_coverView];
    
    _coverView.backgroundColor = [UIColor whiteColor];

    if (!shouldSkipIntroduce && kShouldShowIntroduceWhenFirstLaunch) {
        [self beginIntroduce];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[[AppUtils alloc] init].appVersion];
    } else {
        [self performSelector:@selector(dismiss:) withObject:nil afterDelay:1.8];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBActions

- (void)dismiss:(id)sender
{
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionFlipFromRight;
    [UIView animateWithDuration:0.2 delay:0.0 options:options animations:^{
        _coverView.alpha = 0.2;
    }  completion:^(BOOL finished) {
        _coverView.alpha = 0;
        [_coverView removeFromSuperview];
        _coverView = nil;
    }];
}

/**
 *  跳转到聊天列表
 */
- (void)jumpToChatListCtl
{
    [self jumpIM:nil];
}

//进入聊天功能
- (IBAction)jumpIM:(UIButton *)sender {
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        ContactListViewController *contactListCtl = [[ContactListViewController alloc] init];
        contactListCtl.title = @"桃友";
        if ([accountManager numberOfUnReadFrendRequest]) {
            contactListCtl.notify = YES;
        } else {
            contactListCtl.notify = NO;
        }
        
        ChatListViewController *chatListCtl = [[ChatListViewController alloc] init];
        chatListCtl.title = @"Talk";
        chatListCtl.notify = NO;
        
        NSArray *viewControllers = [NSArray arrayWithObjects:chatListCtl,contactListCtl, nil];
        IMRootViewController *IMRootCtl = [[IMRootViewController alloc] init];
        IMRootCtl.delegate = self;
        IMRootCtl.viewControllers = viewControllers;
        [self.navigationController pushViewController:IMRootCtl animated:YES];
        
    } else {
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
        [self performSelector:@selector(goLogin:) withObject:nil afterDelay:0.8];
    }
}

- (IBAction)goLogin:(id)sender
{
    LoginViewController *loginCtl = [[LoginViewController alloc] init];
    UINavigationController *nctl = [[UINavigationController alloc] initWithRootViewController:loginCtl];
    loginCtl.isPushed = NO;
    [self.navigationController presentViewController:nctl animated:YES completion:nil];
}

/**
 *  跳转到web 界面
 */
- (void)jumpToWebViewCtl
{
    
}

#pragma mark - loadStroy
- (void)loadData
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AppUtils *utils = [[AppUtils alloc] init];
    [manager.requestSerializer setValue:utils.appVersion forHTTPHeaderField:@"Version"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"iOS %@",utils.systemVersion] forHTTPHeaderField:@"Platform"];
    
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSNumber *imageWidth = [NSNumber numberWithInt:(kWindowWidth)*2];
    [params setObject:imageWidth forKey:@"imgWidth"];
    [params setObject:[NSNumber numberWithFloat:self.view.frame.size.width*2] forKey:@"width"];
    [params setObject:[NSNumber numberWithFloat:self.view.frame.size.height*2] forKey:@"height"];
    
    //获取封面故事接口
    [manager GET:API_GET_COVER_STORIES parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if (!([[[responseObject objectForKey:@"result"] objectForKey:@"image"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"backGroundImage"]])) {
                [self updateBackgroundData:[[responseObject objectForKey:@"result"] objectForKey:@"image"]];
            }
        } else {
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}

- (void)updateBackgroundData:(NSString *)imageUrl
{
    if (_coverView != nil) {
        [_coverView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"story_default.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                if (_coverView != nil) {
                    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                             selector:@selector(dismiss:)
                                                               object:nil];
                    [self performSelector:@selector(dismiss:) withObject:nil afterDelay:1.2];
                }
            }
        }];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:imageUrl forKey:@"backGroundImage"];
}

#pragma mark - help
- (void)beginIntroduce
{
    _coverView.hidden = YES;
    EAIntroPage *page1 = [EAIntroPage page];
    _pageView1 = [[PageOne alloc] initWithFrame:self.view.bounds];
    page1.bgImage = _pageView1.backGroundImageView;
    page1.titleIconView = _pageView1.titleView;
    page1.titleIconPositionY = self.view.bounds.size.height/2-30;
    
    EAIntroPage *page2 = [EAIntroPage page];
    _pageView2 = [[PageTwo alloc] initWithFrame:self.view.bounds];
    page2.bgImage = _pageView2.backGroundImageView;
    page2.titleIconView = _pageView2.titleView;
    page2.titleIconPositionY = self.view.bounds.size.height/2-30;
    
    
    EAIntroPage *page3 = [EAIntroPage page];
    _pageView3 = [[PageThree alloc] initWithFrame:self.view.bounds];
    page3.bgImage = _pageView3.backGroundImageView;
    page3.titleIconView = _pageView3.titleView;
    page3.titleIconPositionY = self.view.bounds.size.height/2-40;
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
    [intro setDelegate:self];
    
    [intro showInView:self.view animateDuration:0];
}

#pragma mark - EAIntroDelegate

- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSInteger)pageIndex
{
    if (pageIndex == 0) {
        [_pageView1 startAnimation];
    }
    if (pageIndex == 1) {
        [_pageView2 startAnimation];
    }
    if (pageIndex == 2) {
        [_pageView3 startAnimation];
    }
}

- (void)intro:(EAIntroView *)introView pageStartScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex
{
    if (pageIndex == 0) {
        [_pageView1 stopAnimation];
    }
}

- (void)introDidFinish:(EAIntroView *)introView
{
    
}

- (void)setupViewControllers
{
    _toolBoxCtl = [[ToolBoxViewController alloc] init];
    UINavigationController *firstNavigationController = [[UINavigationController alloc]
                                                         initWithRootViewController:_toolBoxCtl];
    
    _hotDestinationCtl = [[HotDestinationCollectionViewController alloc] init];
    UINavigationController *secondNavigationController = [[UINavigationController alloc]
                                                          initWithRootViewController:_hotDestinationCtl];
    
    _mineCtl = [[MineTableViewController alloc] init];
    UINavigationController *thirdNavigationController = [[UINavigationController alloc]
                                                         initWithRootViewController:_mineCtl];
    
    [self setViewControllers:@[firstNavigationController, secondNavigationController,
                               thirdNavigationController]];
    [self customizeTabBarForController];
}

- (void)customizeTabBarForController
{
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 77);
    self.tabBar.frame = frame;
    self.tabBar.backgroundColor = [UIColor clearColor];
    
    UIView *imView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/4, 77.5)];
    imView.backgroundColor = [UIColor clearColor];
    
    UIView *imBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 28, (self.view.frame.size.width)/4, 49)];
    imBackView.backgroundColor = APP_THEME_COLOR;
    [imView addSubview:imBackView];
    
    UIButton *IMBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [IMBtn setImage:[UIImage imageNamed:@"ic_IM.png"] forState:UIControlStateNormal];
    [IMBtn addTarget:self action:@selector(jumpIM:) forControlEvents:UIControlEventTouchUpInside];
    IMBtn.center = CGPointMake(imView.bounds.size.width/2, imView.bounds.size.height/2);
    [imView addSubview:IMBtn];
    [self.tabBar addSubview:imView];
    
    self.tabBar.contentEdgeInsets = UIEdgeInsetsMake(0, (self.view.frame.size.width)/4, 0, 0);
    
    NSArray *tabBarItemImages = @[@"ic_tao", @"ic_loc", @"ic_person"];
    NSInteger index = 0;
    
    for (RDVTabBarItem *item in [[self tabBar] items]) {
        item.titlePositionAdjustment = UIOffsetMake(0, 6);
        item.selectedTitleAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"MicrosoftYaHei" size:11.0], NSForegroundColorAttributeName : APP_THEME_COLOR};
        item.unselectedTitleAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"MicrosoftYaHei" size:11.0], NSForegroundColorAttributeName : TEXT_COLOR_TITLE_SUBTITLE};
        
        item.itemHeight = 49.0;
        item.backgroundColor = APP_THEME_COLOR;

        if ([[[self tabBar] items] indexOfObject:item] != 0) {
            NSLog(@"%@", NSStringFromCGRect(item.frame));
            UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, 0.5, 33)];
            spaceView.backgroundColor = APP_DIVIDER_COLOR;
            [item addSubview:spaceView];
        }
        
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        index++;
    }
}

/**
 *  统计未读消息数
 *
 *  @return 
 */

-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

#pragma mark - IChatManagerDelegate 消息变化

- (void)networkChanged:(EMConnectionState)connectionState
{
    NSLog(@"网络状态发生变化");
}

- (void)didUpdateConversationList:(NSArray *)conversationList
{
    NSLog(@"聊天的内容发生变化");
}

// 未读消息数量变化回调
-(void)didUnreadMessagesCountChanged
{
    [self setupUnreadMessageCount];
}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessages{
    [self setupUnreadMessageCount];
}

- (void)didFinishedReceiveOfflineCmdMessages:(NSArray *)offlineCmdMessages
{
    for (EMMessage *cmdMessage in offlineCmdMessages) {
        [TZCMDChatHelper distributeCMDMsg:cmdMessage];
    }
    NSLog(@"我收到了很多透传消息");
}

// 收到消息回调
-(void)didReceiveMessage:(EMMessage *)message
{
    NSLog(@"收到消息，消息为%@", message);
    
    BOOL needShowNotification = message.isGroup ? [self needShowNotification:message.conversationChatter] : YES;
    if (needShowNotification) {
#if !TARGET_IPHONE_SIMULATOR
        [self playSoundAndVibration];
        
        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (!isAppActivity) {
            [self showNotificationWithMessage:message];
        }
#endif
    }
}

/**
 *  接收到透传消息的回调，当程序 activity 的时候
 *
 *  @param cmdMessage
 */
- (void)didReceiveCmdMessage:(EMMessage *)cmdMessage
{
    [TZCMDChatHelper distributeCMDMsg:cmdMessage];
    NSLog(@"接收到透传消息:  %@",cmdMessage);
}

/**
 *  是否需要显示推送通知
 *
 *  @param fromChatter
 *
 *  @return
 */
- (BOOL)needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EaseMob sharedInstance].chatManager ignoredGroupIds];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    
    if (ret) {
        EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
        
        do {
            if (options.noDisturbing) {
                NSDate *now = [NSDate date];
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:now];
                NSInteger hour = [components hour];
                //        NSInteger minute= [components minute];
                
                NSUInteger startH = options.noDisturbingStartH;
                NSUInteger endH = options.noDisturbingEndH;
                if (startH>endH) {
                    endH += 24;
                }
                
                if (hour>=startH && hour<=endH) {
                    ret = NO;
                    break;
                }
            }
        } while (0);
    }
    
    return ret;
}

- (void)playSoundAndVibration{
    //如果距离上次响铃和震动时间太短, 则跳过响铃
    NSLog(@"%@, %@", [NSDate date], self.lastPlaySoundDate);
    
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        return;
    }
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EaseMob sharedInstance].deviceManager asyncPlayNewMessageSound];
    // 收到消息时，震动
    [[EaseMob sharedInstance].deviceManager asyncPlayVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = @"[图片]";
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = @"[位置]";
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = @"[音频]";
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = @"[视频]";
            }
                break;
            default:
                break;
        }
        
        NSString *title = message.from;
        if (message.isGroup) {
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:message.conversationChatter]) {
                    title = [NSString stringWithFormat:@"%@(%@)", message.groupSenderName, group.groupSubject];
                    break;
                }
            }
        }
        
        notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    }
    else{
        notification.alertBody = @"您有一条新消息";
    }
    
    notification.alertAction = @"打开";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    //    UIApplication *application = [UIApplication sharedApplication];
    //    application.applicationIconBadgeNumber += 1;
}

#pragma mark - IChatManagerDelegate 登陆回调（主要用于监听自动登录是否成功）

- (void)didLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    if (error) {
        NSLog(@"自动登录失败");
    } else {
        NSLog(@"自动登录成功");
    }
}

#pragma mark - IChatManagerDelegate 好友变化

- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message
{
#if !TARGET_IPHONE_SIMULATOR
    [self playSoundAndVibration];
    
    BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
    if (!isAppActivity) {
        //发送本地推送
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date]; //触发通知的时间
        notification.alertBody = [NSString stringWithFormat:@"%@ %@", username, @"添加你为桃友"];
        notification.alertAction = @"打开";
        notification.timeZone = [NSTimeZone defaultTimeZone];
    }
#endif
    
}

- (void)didUpdateBuddyList:(NSArray *)buddyList
            changedBuddies:(NSArray *)changedBuddies
                     isAdd:(BOOL)isAdd
{
    NSLog(@"buddyList:%@/n changeedBuddies:%@", buddyList, changedBuddies);
}

- (void)didRemovedByBuddy:(NSString *)username
{
    NSLog(@"didRemovedByBuddy我要删除会话");
    [[EaseMob sharedInstance].chatManager removeConversationByChatter:username deleteMessages:YES];
}

- (void)didAcceptedByBuddy:(NSString *)username
{
}

- (void)didRejectedByBuddy:(NSString *)username
{
    NSLog(@"%@", [NSString stringWithFormat:@"你被'%@'无耻的拒绝了", username]);
}

- (void)didAcceptBuddySucceed:(NSString *)username{
}

#pragma mark - IChatManagerDelegate 群组变化

- (void)didReceiveGroupInvitationFrom:(NSString *)groupId
                              inviter:(NSString *)username
                              message:(NSString *)message
{
    NSLog(@"didReceiveGroupInvitationFrom");
    [self playSoundAndVibration];
}

- (void)groupDidUpdateInfo:(EMGroup *)group error:(EMError *)error
{
    NSLog(@"groupDidUpdateInfo");
    AccountManager *accountManager = [AccountManager shareAccountManager];
    [accountManager updateGroup:group.groupId withGroupOwner:group.owner groupSubject:group.groupSubject groupInfo:group.groupDescription];
}

- (void)didAcceptInvitationFromGroup:(EMGroup *)group
                               error:(EMError *)error
{
    NSLog(@"didAcceptInvitationFromGroup");
}

- (void)didUpdateGroupList:(NSArray *)allGroups error:(EMError *)error
{
    NSLog(@"didUpdateGroupList");
}

//接收到入群申请
- (void)didReceiveApplyToJoinGroup:(NSString *)groupId
                         groupname:(NSString *)groupname
                     applyUsername:(NSString *)username
                            reason:(NSString *)reason
                             error:(EMError *)error
{
    if (!error) {
#if !TARGET_IPHONE_SIMULATOR
        NSLog(@"didReceiveGroupInvitationFrom");
        [self playSoundAndVibration];
#endif
        
    }
}

/*!
 @method
 @brief 离开一个群组后的回调
 @param group  所要离开的群组对象
 @param reason 离开的原因
 @param error  错误信息
 @discussion
 离开的原因包含主动退出, 被别人请出, 和销毁群组三种情况
 */

- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error
{
    NSLog(@"%@", group);
}

- (void)didReceiveGroupRejectFrom:(NSString *)groupId
                          invitee:(NSString *)username
                           reason:(NSString *)reason
{
    NSLog(@"%@", [NSString stringWithFormat:@"你被'%@'无耻的拒绝了", username]);
}


- (void)didReceiveAcceptApplyToJoinGroup:(NSString *)groupId
                               groupname:(NSString *)groupname
{
    NSString *message = [NSString stringWithFormat:@"同意加入群组\'%@\'", groupname];
    [self showHint:message];
}

#pragma mark - IChatManagerDelegate 登录状态变化

- (void)didLoginFromOtherDevice
{
    __weak typeof (HomeViewController *)weakSelf = self;
    [[EaseMob sharedInstance].chatManager asyncLogoffWithCompletion:^(NSDictionary *info, EMError *error) {
        AccountManager *accountManager = [AccountManager shareAccountManager];
        [accountManager asyncLogout:^(BOOL isSuccess) {
            if (isSuccess) {
            } else {
                [weakSelf showHint:@"退出失败"];
            }
        }];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"你的账号已在其他地方登录"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil,
                                  nil];
        alertView.tag = 100;
        [alertView show];
    } onQueue:nil];
}

- (void)didRemovedFromServer {
    [[EaseMob sharedInstance].chatManager asyncLogoffWithCompletion:^(NSDictionary *info, EMError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"你的账号已被从服务器端移除"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil,
                                  nil];
        alertView.tag = 101;
        [alertView show];
    } onQueue:nil];
}

- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    
}

#pragma mark -

- (void)willAutoReconnect{
    NSLog(@"正在重连中");
}

- (void)didAutoReconnectFinishedWithError:(NSError *)error{
    if (error) {
        NSLog(@"重连失败，稍候将继续重连");
    }else{
        NSLog(@"重连成功");
    }
}

@end
