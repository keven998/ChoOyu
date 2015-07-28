//
//  AppDelegate.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/16/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "AppDelegate.h"
#import "UMSocial.h"
#import "UMSocialSinaHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "AccountManager.h"
#import "WXApiObject.h"
#import "WXApi.h"
#import "iRate.h"
#import "PeachTravel-swift.h"

@interface AppDelegate ()

@property (assign, nonatomic) int lastPayloadIndex;
@property (retain, nonatomic) NSString *payloadId;
@property (nonatomic, strong) HomeViewController *homeViewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self lvApplication:application didFinishLaunchingWithOptions:launchOptions];
    if (IS_IOS8) {
        [[UINavigationBar appearance] setTranslucent:NO];
    }
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"common_icon_navigaiton_back"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"common_icon_navigaiton_back"]];
    [[UINavigationBar appearance] setBackgroundImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR]
                                       forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"bg_navigationbar_shadow.png"]];
    [[UINavigationBar appearance] setTitleTextAttributes:
        [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    
    // 设置阴影效果
    [UINavigationBar appearance].layer.shadowColor = [UIColor redColor].CGColor; //shadowColor阴影颜色
    [UINavigationBar appearance].layer.shadowOffset = CGSizeMake(20.0f , 20.0f); //shadowOffset阴影偏移x，y向(上/下)偏移(-/+)2
    [UINavigationBar appearance].layer.shadowOpacity = 0.5f;//阴影透明度，默认0
    [UINavigationBar appearance].layer.shadowRadius = 20.0f;//阴影半径
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = APP_PAGE_COLOR;
    
    _homeViewController = [[HomeViewController alloc] init];
    self.window.rootViewController = _homeViewController;
    [self.window makeKeyAndVisible];
    
    /** 设置友盟分享**/
    [UMSocialData openLog:NO];
    [UMSocialData setAppKey:UMENG_KEY];
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    [UMSocialQQHandler setQQWithAppId:SHARE_QQ_APPID appKey:SHARE_QQ_KEY url:@"http://www.umeng.com/social"];
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:SHARE_WEIXIN_APPID appSecret:SHARE_WEIXIN_SECRET url:@"http://www.lvxingpai.com"];
    
    /**设置友盟统计**/
//    [MobClick startWithAppkey:UMENG_KEY reportPolicy:(ReportPolicy) REALTIME channelId:nil];

#ifndef __OPTIMIZE__
//    [MobClick setCrashReportEnabled:NO];
#else
//    [MobClick setCrashReportEnabled:YES];
#endif
    
    [iRate sharedInstance].promptAtLaunch = NO;
    
    // 程序启动的时候存储未读数的状态
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    BOOL isShowUnreadCount = YES;
    [defaults setBool:isShowUnreadCount forKey:kShouldShowUnreadFrendRequestNoti];
    [defaults synchronize];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [self lvApplication:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [self lvApplication:application didFailToRegisterForRemoteNotificationsWithError:error];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (!result) {
        result = [WXApi handleOpenURL:url delegate:self];
    }
    return  result;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (!result) {
        result = [WXApi handleOpenURL:url delegate:self];
    }
    return  result;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self lvApplicationDidBecomeActive:application];
    [_homeViewController updateViewWithUnreadMessageCount];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

// WXApiDelegate的代理方法
- (void)onResp:(BaseResp *)resp
{
    SendAuthResp * result = (SendAuthResp *)resp;
    NSString * code = result.code;
    
    //微信授权失败,取消登录
    if (!code) {
        return;
    }
    NSDictionary *userInfo = @{@"code" : code};
    [[NSNotificationCenter defaultCenter] postNotificationName:weixinDidLoginNoti object:nil userInfo:userInfo];
}

@end




