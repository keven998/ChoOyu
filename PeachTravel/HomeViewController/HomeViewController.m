//
//  HomeViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/1.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HomeViewController.h"
#import "SearchDestinationViewController.h"
#import "MineViewContoller.h"
#import "PageOne.h"
#import "PageTwo.h"
#import "PageThree.h"
#import "EAIntroView.h"
#import "ChatListViewController.h"
#import "LoginViewController.h"
#import "GuiderDistributeViewController.h"
#import "ChatListViewController.h"
#import "RegisterViewController.h"
#import "PrepareViewController.h"
#import "JDStatusBarNotification.h"
#import "PeachTravel-swift.h"

#define kBackGroundImage    @"backGroundImage"

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;

@interface HomeViewController ()<UIGestureRecognizerDelegate, EAIntroDelegate, UITabBarControllerDelegate, UnreadMessageCountChangeDelegate, MessageReceiveManagerDelegate>
{
    NSInteger badgeNum;
}
@property (nonatomic, strong) UIImageView *coverView;

@property (strong, nonatomic) NSDate *lastPlaySoundDate;

/**
 *  未读消息的label
 */
@property (nonatomic, strong) UILabel *unReadMsgLabel;

@property (nonatomic, strong) SearchDestinationViewController *searchPoiCtl;
@property (nonatomic, strong) MineViewContoller *mineCtl;
@property (nonatomic, strong) ChatListViewController *chatListCtl;
@property (nonatomic, strong) GuiderDistributeViewController *guiderCtl;

@property (nonatomic, strong) PageOne *pageView1;
@property (nonatomic, strong) PageTwo *pageView2;
@property (nonatomic, strong) PageThree *pageView3;

@end

@implementation HomeViewController

#pragma mark - lifeCycle

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 1.先设置tabBar,控制三个控制器
    [self setupViewControllers];
    
    // 2.判断是否登录,如果没有登录,跳转到登录界面
    if (![[AccountManager shareAccountManager] isLogin]) {
        [self setupLoginPage];
    } else {    // 登录之后,就调用接收普通消息的方法注册消息
        IMClientManager *imclientManager = [IMClientManager shareInstance];
        [imclientManager.messageReceiveManager addMessageReceiveListener:self withRoutingKey:MessageReceiveDelegateRoutingKeynormal];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidRegister) name:userDidRegistedNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogout) name:userDidLogoutNoti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLogin) name:userDidLoginNoti object:nil];
    
    [self setupConverView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupLoginPage
{
    PrepareViewController *prepareCtl = [[PrepareViewController alloc] init];
    prepareCtl.rootViewController = self;
    prepareCtl.view.frame = self.view.frame;
    [self addChildViewController:prepareCtl];
    [self.view addSubview:prepareCtl.view];
    [prepareCtl willMoveToParentViewController:self];
}

- (void)setupConverView
{
    if ((!shouldSkipIntroduce && kShouldShowIntroduceWhenFirstLaunch) || !kIsNotFirstInstall) {
        [self beginIntroduce];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[[AppUtils alloc] init].appVersion];
    } else {
        _coverView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_coverView];
        [self loadCoverData];
        [self updateBackgroundData:[[NSUserDefaults standardUserDefaults] objectForKey:kBackGroundImage]];
    }
}

- (void)didReceiveMemoryWarning
{
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

//进入聊天功能
- (IBAction)jumpIM:(UIButton *)sender
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([accountManager isLogin]) {
        [self.navigationController pushViewController:self.chatListCtl animated:YES];
    } else {
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
        [self performSelector:@selector(goLogin:) withObject:nil afterDelay:0.8];
    }
}

- (IBAction)goLogin:(id)sender
{
    LoginViewController *loginCtl = [[LoginViewController alloc] initWithCompletion:^(BOOL completed) {
        [self userDidLogin];
    }];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
    loginCtl.isPushed = NO;
    [self presentViewController:nctl animated:YES completion:nil];
}

- (IBAction)goRegist:(id)sender
{
    RegisterViewController *loginCtl = [[RegisterViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
    [self presentViewController:nctl animated:YES completion:nil];
}

- (IBAction)goPass:(id)sender
{
    [self setSelectedIndex:1];
    [_coverView removeFromSuperview];
    _coverView = nil;
}

#pragma mark - private Methods

- (void)userDidLogin
{
    NSArray *controllers = [self childViewControllers];
    if (controllers != nil && controllers.count > 0) {
        UIViewController *ctl = [controllers lastObject];
        if ([ctl isKindOfClass:[PrepareViewController class]]) {
            PrepareViewController *vc = (PrepareViewController *)ctl;
            [vc.view removeFromSuperview];
            [vc removeFromParentViewController];
        }
    }
    [self updateViewWithUnreadMessageCount];
}

- (void)userDidRegister
{
     NSString *key = [NSString stringWithFormat:@"%@_%ld", kShouldShowFinishUserInfoNoti, [AccountManager shareAccountManager].account.userId];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self showSomeTabbarNoti];
}

- (void)userDidLogout
{
    [self updateViewWithUnreadMessageCount];
}

/**
 *  跳转到web 界面
 */
- (void)jumpToWebViewCtl
{
    
}

#pragma mark - loadStroy

- (void)loadCoverData
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
    if (IS_IPHONE_6P) {
        [params setObject:[NSNumber numberWithFloat:self.view.frame.size.width*3] forKey:@"width"];
        [params setObject:[NSNumber numberWithFloat:self.view.frame.size.height*3] forKey:@"height"];
    } else {
        [params setObject:[NSNumber numberWithFloat:self.view.frame.size.width*2] forKey:@"width"];
        [params setObject:[NSNumber numberWithFloat:self.view.frame.size.height*2] forKey:@"height"];
    }
    
    //获取封面故事接口
    [manager GET:API_GET_COVER_STORIES parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        if (code == 0) {
            if (!([[[responseObject objectForKey:@"result"] objectForKey:@"image"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kBackGroundImage]])) {
                [self updateBackgroundData:[[responseObject objectForKey:@"result"] objectForKey:@"image"]];
            }
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
}

- (void)updateBackgroundData:(NSString *)imageUrl
{
    if (_coverView != nil) {
        [_coverView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"Default-375w-667h@2x~iphone"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                if (_coverView != nil) {
                    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                             selector:@selector(dismiss:)
                                                               object:nil];
                    [self performSelector:@selector(dismiss:) withObject:nil afterDelay:3];
                }
            }
        }];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:imageUrl forKey:kBackGroundImage];
}

#pragma mark - help

- (void)beginIntroduce
{
    _coverView.hidden = YES;
    EAIntroPage *page1 = [EAIntroPage page];
    EAIntroPage *page2 = [EAIntroPage page];
    EAIntroPage *page3 = [EAIntroPage page];
    EAIntroPage *page4 = [EAIntroPage page];

    {
        NSString *imageName;
        
        NSLog(@"%lf", self.view.frame.size.height);
        if (self.view.frame.size.height == 480) {
            imageName =  @"introduce_4_1.png";
        } else {
            imageName = @"introduce_6_1.png";
        }
        UIImageView *image = [[UIImageView alloc] initWithFrame:self.view.bounds];
        image.image = [UIImage imageNamed:imageName];
        page1.bgImage = image;
    }
  
    {
        NSString *imageName;
        if (self.view.frame.size.height == 480) {
            imageName =  @"introduce_4_2.png";
        } else {
            imageName = @"introduce_6_2.png";
        }
        UIImageView *image = [[UIImageView alloc] initWithFrame:self.view.bounds];
        image.image = [UIImage imageNamed:imageName];
        page2.bgImage = image;
    }
    
    {
        NSString *imageName;
        if (self.view.frame.size.height == 480) {
            imageName =  @"introduce_4_3.png";
        } else {
            imageName = @"introduce_6_3.png";
        }
        UIImageView *image = [[UIImageView alloc] initWithFrame:self.view.bounds];
        image.image = [UIImage imageNamed:imageName];
        page3.bgImage = image;
    }
    
    {
        NSString *imageName;
        if (self.view.frame.size.height == 480) {
            imageName =  @"introduce_4_4.png";
        } else {
            imageName = @"introduce_6_4.png";
        }
        UIImageView *image = [[UIImageView alloc] initWithFrame:self.view.bounds];
        image.image = [UIImage imageNamed:imageName];
        page4.bgImage = image;
    }
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3,page4]];
    [intro setDelegate:self];
    
    [intro showInView:self.view animateDuration:0];
}

#pragma mark - EAIntroDelegate

- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSInteger)pageIndex
{
    if (pageIndex == 0) {
        [_pageView1 startAnimation];
    }
    else if (pageIndex == 1) {
        [_pageView2 startAnimation];
    }
    else if (pageIndex == 2) {
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
    self.tabBar.translucent = NO;
    self.delegate = self;
    self.tabBar.selectedImageTintColor = APP_THEME_COLOR;
    
    _chatListCtl = [[ChatListViewController alloc] init];
    _chatListCtl.delegate = self;
    TZNavigationViewController *firstNavigationController = [[TZNavigationViewController alloc]
                                                             initWithRootViewController:self.chatListCtl];
    
    _guiderCtl = [[GuiderDistributeViewController alloc] init];
    TZNavigationViewController *secondNavigationController = [[TZNavigationViewController alloc]
                                                              initWithRootViewController:_guiderCtl];
    
    _searchPoiCtl = [[SearchDestinationViewController alloc] init];
    TZNavigationViewController *thirdNavigationController = [[TZNavigationViewController alloc]
                                                              initWithRootViewController:_searchPoiCtl];
    
    _mineCtl = [[MineViewContoller alloc] init];
    TZNavigationViewController *fourthNavigationController = [[TZNavigationViewController alloc]
                                                              initWithRootViewController:_mineCtl];
    
    
    [self setViewControllers:@[firstNavigationController, secondNavigationController, thirdNavigationController
                               , fourthNavigationController]];
    [self customizeTabBarForController];

}

- (void)customizeTabBarForController
{
    
    NSArray *tabBarItemImages = @[@"ic_tabbar_chat", @"ic_tabbar_expert", @"ic_tabbar_search", @"ic_tabbar_mine"];
    NSArray *tabbarItemNames = @[@"消息", @"达人", @"搜索", @"我的"];
    NSInteger index = 0;
    
    for (UITabBarItem *item in self.tabBar.items) {
        //        item.title = titles[index];
        item.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal", [tabBarItemImages objectAtIndex:index]]];
        item.selectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected", [tabBarItemImages objectAtIndex:index]]];
        item.title = [tabbarItemNames objectAtIndex:index];
        index++;
    }
    [self showSomeTabbarNoti];
}

/**
 *  展示一些tabbar上的提醒
 */
- (void)showSomeTabbarNoti
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@_%ld", kShouldShowFinishUserInfoNoti, [AccountManager shareAccountManager].account.userId];
    BOOL shouldShowNoti = [[defaults objectForKey:key] boolValue] && [[AccountManager shareAccountManager] isLogin];
    
    if (shouldShowNoti) {
        UIView *dotView = [[UIView alloc] init];
        dotView.tag = 101;
        CGRect tabFrame = self.tabBar.frame;
        dotView.backgroundColor = [UIColor redColor];
        dotView.layer.cornerRadius = 3.0;
        dotView.clipsToBounds = YES;
        CGFloat x = ceilf(0.87 * tabFrame.size.width);
        CGFloat y = ceilf(0.2 * tabFrame.size.height);
        dotView.frame = CGRectMake(x, y, 6, 6);
        [self.tabBar addSubview:dotView];
    } else {
        for (UIView *view in self.tabBar.subviews) {
            if (view.tag == 101) {
                [view removeFromSuperview];
            }
        }
    }
}

- (void)updateViewWithUnreadMessageCount
{
    NSInteger unreadCount = [IMClientManager shareInstance].conversationManager.totalMessageUnreadCount;
    UITabBarItem *item = [self.tabBar.items firstObject];
    if (unreadCount == 0) {
        item.badgeValue = nil;
        badgeNum = 0;
        UIApplication *application = [UIApplication sharedApplication];
        application.applicationIconBadgeNumber = badgeNum;
        
    } else if (unreadCount > 0 && unreadCount < 100){
        item.badgeValue = [NSString stringWithFormat:@"%ld", unreadCount];
        badgeNum = unreadCount;
        UIApplication *application = [UIApplication sharedApplication];
        application.applicationIconBadgeNumber = badgeNum;
    } else {
        item.badgeValue = [NSString stringWithFormat:@"99+"];
        badgeNum = unreadCount;
        UIApplication *application = [UIApplication sharedApplication];
        application.applicationIconBadgeNumber = badgeNum;
    }
}

#pragma mark - UnreadMessageCountChangeDelegate

- (void)unreadMessageCountHasChange
{
    [self updateViewWithUnreadMessageCount];
}


#pragma mark - MessageReceiveManagerDelegate
// 收到新消息
- (void)receiveNewMessage:(BaseMessage * __nonnull)message
{
    BOOL needShowNotification;
    IMClientManager *clientManager = [IMClientManager shareInstance];
    
    ChatConversation *conversation = [clientManager.conversationManager getExistConversationInConversationList:message.chatterId];
    
    // isBlockMessage: 是否是免打扰消息 并且是由他人发送的消息
    needShowNotification = ![conversation isBlockMessage] && (message.sendType == IMMessageSendTypeMessageSendSomeoneElse);
    if (needShowNotification) {
        if (!conversation.isCurrentConversation) {
            [self updateViewWithUnreadMessageCount];
            if (self.selectedIndex != 0) {
                [self showStatusMessageNoti:message];
            }
        }
#if !TARGET_IPHONE_SIMULATOR
        [self playSoundAndVibration];
        
        // 如果App不在前台,发送通知
        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (!isAppActivity) {
            [self showNotificationWithMessage:message];
            if (conversation.isCurrentConversation) {
                UIApplication *application = [UIApplication sharedApplication];
                NSInteger value = application.applicationIconBadgeNumber;
                application.applicationIconBadgeNumber = ++value;
            }
        }
#endif
    }
}

/**
 *  展现 statusbar 上的消息
 *
 *  @param message
 */
- (void)showStatusMessageNoti:(BaseMessage *) message
{
    [JDStatusBarNotification showWithStatus:message.abbrevMsg dismissAfter:2];
}

- (void)playSoundAndVibration
{
    //如果距离上次响铃和震动时间太短, 则跳过响铃
    NSLog(@"%@, %@", [NSDate date], self.lastPlaySoundDate);
    
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        return;
    }
    
//    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
}

- (void)showNotificationWithMessage:(BaseMessage *)message
{
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    if ([message.abbrevMsg isBlankString]) {
        notification.alertBody = @"您有一条新消息";
    } else {
        notification.alertBody = message.abbrevMsg;
    }
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.alertAction = @"打开";
    notification.timeZone = [NSTimeZone defaultTimeZone];

    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma mark - UITabbarViewControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    AccountManager *accountManager = [AccountManager shareAccountManager];
    if ([viewController isEqual:_chatListCtl.navigationController] && !accountManager.isLogin) {
        LoginViewController *loginCtl = [[LoginViewController alloc] init];
        TZNavigationViewController *navi = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
        [self presentViewController:navi animated:YES completion:nil];
        return NO;
    } else {
        if ([viewController isEqual:_mineCtl.navigationController]) {
            _mineCtl.navigationController.navigationBarHidden = YES;
        }
    }
    return YES;
}


@end
