//
//  HomeViewController.m
//  PeachTravel
//
//  Created by Luo Yong on 14/12/1.
//  Copyright (c) 2014年 com.aizou.www. All rights reserved.
//

#import "HomeViewController.h"
#import "ToolsHomeViewController.h"
#import "MineTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PageOne.h"
#import "PageTwo.h"
#import "PageThree.h"
#import "EAIntroView.h"
#import "TZCMDChatHelper.h"
#import "ChatListViewController.h"
#import "LoginViewController.h"
#import "ChatListViewController.h"
#import "RegisterViewController.h"
#import "PrepareViewController.h"
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

@property (nonatomic, strong) ToolsHomeViewController *toolBoxCtl;
@property (nonatomic, strong) MineTableViewController *mineCtl;
@property (nonatomic, strong) ChatListViewController *chatListCtl;

@property (nonatomic, strong) PageOne *pageView1;
@property (nonatomic, strong) PageTwo *pageView2;
@property (nonatomic, strong) PageThree *pageView3;

@end

@implementation HomeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViewControllers];
    
    if (![[AccountManager shareAccountManager] isLogin]) {
        [self setupLoginPage];
    } else {
        IMClientManager *imclientManager = [IMClientManager shareInstance];
        [imclientManager.messageReceiveManager addMessageReceiveListener:self withRoutingKey:MessageReceiveDelegateRoutingKeynormal];

    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setupLoginPage {
    PrepareViewController *prepareCtl = [[PrepareViewController alloc] init];
    prepareCtl.rootViewController = self;
    prepareCtl.view.frame = self.view.frame;
    [self addChildViewController:prepareCtl];
    [self.view addSubview:prepareCtl.view];
    [prepareCtl willMoveToParentViewController:self];
    
    [self setupConverView];
    //    [self beginIntroduce];
}

- (void) setupConverView {
    if (!shouldSkipIntroduce && kShouldShowIntroduceWhenFirstLaunch) {
        //        [self beginIntroduce];
        //        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[[AppUtils alloc] init].appVersion];
    } else {
        _coverView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _coverView.userInteractionEnabled = YES;
        _coverView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_coverView];
        [self performSelector:@selector(dismiss:) withObject:nil afterDelay:1.5];
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

//进入聊天功能
- (IBAction)jumpIM:(UIButton *)sender {
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

- (IBAction)goRegist:(id)sender {
    RegisterViewController *loginCtl = [[RegisterViewController alloc] init];
    TZNavigationViewController *nctl = [[TZNavigationViewController alloc] initWithRootViewController:loginCtl];
    [self presentViewController:nctl animated:YES completion:nil];
}

- (IBAction)goPass:(id)sender {
    [self setSelectedIndex:1];
    [_coverView removeFromSuperview];
    _coverView = nil;
}

- (void) userDidLogin {
    NSArray *controllers = [self childViewControllers];
    if (controllers != nil && controllers.count > 0) {
        UIViewController *ctl = [controllers lastObject];
        if ([ctl isKindOfClass:[PrepareViewController class]]) {
            PrepareViewController *vc = (PrepareViewController *)ctl;
            [vc.view removeFromSuperview];
            [vc removeFromParentViewController];
        }
    }
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
    //    self.tabBar.backgroundImage = [UIImage imageNamed:@"tababr.png"];
    //    self.tabBar.shadowImage = [UIImage new];
    self.tabBar.selectedImageTintColor = APP_THEME_COLOR;
    //    self.tabBar.opaque = YES;
    //    self.tabBar.backgroundColor = [UIColor clearColor];
    
    _chatListCtl = [[ChatListViewController alloc] init];
    _chatListCtl.delegate = self;
    TZNavigationViewController *firstNavigationController = [[TZNavigationViewController alloc]
                                                             initWithRootViewController:self.chatListCtl];
    
    _toolBoxCtl = [[ToolsHomeViewController alloc] init];
    TZNavigationViewController *secondNavigationController = [[TZNavigationViewController alloc]
                                                              initWithRootViewController:_toolBoxCtl];
    
    _mineCtl = [[MineTableViewController alloc] init];
    TZNavigationViewController *FourthNavigationController = [[TZNavigationViewController alloc]
                                                              initWithRootViewController:_mineCtl];
    
    
    [self setViewControllers:@[firstNavigationController, secondNavigationController,
                               FourthNavigationController]];
    [self customizeTabBarForController];
}

- (void)customizeTabBarForController
{
    
    NSArray *tabBarItemImages = @[@"ic_home", @"ic_loc", @"ic_person"];
    //    NSArray *titles = @[@"消息", @"旅行", @"我"];
    NSInteger index = 0;
    
    for (UITabBarItem *item in self.tabBar.items) {
        //        item.title = titles[index];
        item.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal", [tabBarItemImages objectAtIndex:index]]];
        item.selectedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected", [tabBarItemImages objectAtIndex:index]]];
        item.imageInsets = UIEdgeInsetsMake(7, 0, -7, 0);
        index++;
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

- (void)receiveNewMessage:(BaseMessage * __nonnull)message
{
    BOOL needShowNotification;
    IMClientManager *clientManager = [IMClientManager shareInstance];
    
    ChatConversation *conversation = [clientManager.conversationManager getExistConversationInConversationList:message.chatterId];
    needShowNotification = ![conversation isBlockMessag];
    if (needShowNotification) {
        if (!conversation.isCurrentConversation) {
            [self updateViewWithUnreadMessageCount];
        }
#if !TARGET_IPHONE_SIMULATOR
        [self playSoundAndVibration];
        
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
    
}

- (void)showNotificationWithMessage:(BaseMessage *)message
{
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    notification.alertBody = @"您有一条新消息";
    
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
        }
    }
    return YES;
}


@end
