//
//  AppDelegate.m
//  PeachTravel
//
//  Created by liangpengshuai on 9/16/14.
//  Copyright (c) 2014 com.aizou.www. All rights reserved.
//

#import "AppDelegate.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocialQQHandler.h"
#import "AccountManager.h"
#import "WXApiObject.h"
#import "WXApi.h"
#import "iRate.h"
#import "TZPayManager.h"
#import "PeachTravel-swift.h"
#import <AlipaySDK/AlipaySDK.h>

@interface AppDelegate ()

@property (assign, nonatomic) int lastPayloadIndex;
@property (retain, nonatomic) NSString *payloadId;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self lvApplication:application didFinishLaunchingWithOptions:launchOptions];
    [UINavigationBar appearance].translucent = YES;
        
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].barTintColor = APP_NAVIGATIONBAR_COLOR;
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    _homeViewController = [[HomeViewController alloc] init];
    self.window.rootViewController = _homeViewController;
    
    [self.window makeKeyAndVisible];
    
    /** 设置友盟分享**/
    [UMSocialData openLog:NO];
    [UMSocialData setAppKey:UMENG_KEY];
    [UMSocialQQHandler setQQWithAppId:SHARE_QQ_APPID appKey:SHARE_QQ_KEY url:@"http://www.umeng.com/social"];
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:SHARE_WEIXIN_APPID appSecret:SHARE_WEIXIN_SECRET url:@"http://www.lvxingpai.com"];
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:SHARE_SINA_APPKEY secret:SHARE_SINA_SECRET
                                         RedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    /**设置友盟统计**/
    [MobClick startWithAppkey:UMENG_KEY reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    
    [WXApi registerApp:SHARE_WEIXIN_APPID withDescription:@"lvxingpai"];

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
    //支付宝返回
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            if ([[resultDic objectForKey:@"resultStatus"] intValue] == 9000) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kOrderPayResultNoti
                                                                    object:nil
                                                                  userInfo:@{
                                                                             @"result":@{
                                                                                     @"code" : [NSNumber numberWithInt:0],
                                                                                     }
                                                                             }];

                
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kOrderPayResultNoti
                                                                    object:nil
                                                                  userInfo:@{
                                                                             @"result":@{
                                                                                     @"code" : [NSNumber numberWithInt:-1],
                                                                                     }
                                                                             }];

            }
        }];
        return YES;
    } else {
        BOOL result = [UMSocialSnsService handleOpenURL:url];
        if (!result) {
            result = [WXApi handleOpenURL:url delegate:self];
        }
        
        return  result;
    }
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
    //微信支付信息
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *payResp = (PayResp *)resp;
        [[NSNotificationCenter defaultCenter] postNotificationName:kOrderPayResultNoti
                                                            object:nil
                                                          userInfo:@{
                                                                     @"result":@{
                                                                             @"code" : [NSNumber numberWithInt:payResp.errCode],
                                                                             }
                                                                     }];
      
        
    } else {  //微信登录信息
        SendAuthResp * result = (SendAuthResp *)resp;
        NSString * code = result.code;
        NSLog(@"获取微信登录 token%@", code);
        NSDictionary *userInfo;
        //微信授权失败,取消登录
        if (code) {
            userInfo = @{@"code" : code};
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:weixinDidLoginNoti object:nil userInfo:userInfo];
    }
}

@end




