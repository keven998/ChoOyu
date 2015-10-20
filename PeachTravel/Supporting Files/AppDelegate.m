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
#import <AlipaySDK/AlipaySDK.h>

@interface AppDelegate ()

@property (assign, nonatomic) int lastPayloadIndex;
@property (retain, nonatomic) NSString *payloadId;
@property (nonatomic, strong) HomeViewController *homeViewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self lvApplication:application didFinishLaunchingWithOptions:launchOptions];
    
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage imageNamed:@"navi_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"bg_navigationbar_shadow.png"]];
    [[UINavigationBar appearance] setTitleTextAttributes:
        [NSDictionary dictionaryWithObject:COLOR_TEXT_I forKey:NSForegroundColorAttributeName]];
    
    // 设置阴影效果
    [UINavigationBar appearance].layer.shadowColor = [UIColor redColor].CGColor; //shadowColor阴影颜色
    [UINavigationBar appearance].layer.shadowOffset = CGSizeMake(20.0f , 20.0f); //shadowOffset阴影偏移x，y向(上/下)偏移(-/+)2
    [UINavigationBar appearance].layer.shadowOpacity = 0.5f;//阴影透明度，默认0
    [UINavigationBar appearance].layer.shadowRadius = 10.0f;//阴影半径
    [UINavigationBar appearance].tintColor = COLOR_TEXT_I;
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    
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
    [MobClick startWithAppkey:UMENG_KEY reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];

#ifndef __OPTIMIZE__
    [MobClick setCrashReportEnabled:NO];
#else
    [MobClick setCrashReportEnabled:YES];
#endif
    
    [iRate sharedInstance].promptAtLaunch = NO;
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // 注册远程推送的DeviceToken
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
    // TODO:- 加入alipay回调
    /** 支付宝：
     Lvxingpai://safepay/?%7B%22memo%22:%7B%22memo%22:%22%22,%22ResultStatus%22:%229000%22,%22result%22:%22partner=%5C%222088021950613142%5C%22&seller_id=%5C%22xjpay@xuejianinc.com%5C%22&out_trade_no=%5C%22DWP0M5BYMHIY2L3%5C%22&subject=%5C%221%5C%22&body=%5C%22%E6%88%91%E6%98%AF%E6%B5%8B%E8%AF%95%E6%95%B0%E6%8D%AE%5C%22&total_fee=%5C%220.02%5C%22&notify_url=%5C%22http:%5C/%5C/www.xxx.com%5C%22&service=%5C%22mobile.securitypay.pay%5C%22&payment_type=%5C%221%5C%22&_input_charset=%5C%22utf-8%5C%22&it_b_pay=%5C%2230m%5C%22&show_url=%5C%22m.alipay.com%5C%22&success=%5C%22true%5C%22&sign_type=%5C%22RSA%5C%22&sign=%5C%22L8taQO1J6kHgDpk6XX4qIuSYR6ZsMww4rel+RDO6myo7CDDUc%5C/y8HOMaUMhP7X25Irbf%5C/HiMx5YJPVAaTR1epNkoRMu9rjLbalFlkKP%5C/v6rHLuBGEvlOdLOLj%5C/yq8wYMsLrW8V2XNIGx7Q16UxC8uFGZnvttqVe6z03HqZ2QZ%5C/0=%5C%22%22%7D,%22requestType%22:%22safepay%22%7D
     */
    NSLog(@"application-----%@",application);
    NSLog(@"sourceApplication------%@",sourceApplication);
    NSLog(@"url-------%@",url.absoluteString);
    NSLog(@"annotation--------%@",annotation);
    
    if ([sourceApplication isEqualToString:@"com.alipay.iphoneclient"]) {
        NSLog(@"询问支付是否成功");
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

- (void)applicationWillEnterForeground:(UIApplication *)application
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




