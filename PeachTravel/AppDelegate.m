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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //设置友盟分享
    [UMSocialData openLog:NO];
    [UMSocialData setAppKey:UMENG_KEY];
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    [UMSocialQQHandler setQQWithAppId:SHARE_QQ_APPID appKey:SHARE_QQ_KEY url:@"http://www.umeng.com/social"];
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:SHARE_WEIXIN_APPID appSecret:SHARE_WEIXIN_SECRET url:@"http://www.lvxingpai.com"];
    
    return YES;
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

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

-(void)onReq:(BaseReq *)req
{
    NSLog(@"%@",req);
}

-(void)onResp:(BaseResp *)resp
{
    SendAuthResp * result = (SendAuthResp *)resp;
    
    NSString * code = result.code;
    NSString * state = result.state;
    NSString * lang = result.lang;
    NSString * country = result.country;
    
    NSLog(@"code is %@  \n\
          state is %@ \n\
          lang is %@ \n\
          country is %@ " , code , state , lang , country );
    
    NSUserDefaults * userInfo = [[NSUserDefaults alloc]init];
    [userInfo setObject:code forKey:@"code"];
    [userInfo setObject:state forKey:@"state"];
    [userInfo setObject:lang forKey:@"lang"];
    [userInfo setObject:country forKey:@"country"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString * requestUrl = [NSString stringWithFormat:@"%@sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",WECHAT_API_DOMAIN,SHARE_WEIXIN_APPID,SHARE_WEIXIN_SECRET,code];
    
    NSLog(@"%@", requestUrl);
    
//    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
//    jsonReponseSerializer.acceptableContentTypes = nil;
//    manager.responseSerializer = jsonReponseSerializer;
//    
//    [manager GET:requestUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary * result = responseObject;
//        [userInfo setObject:[result objectForKey:@"access_token"] forKey:@"access_token"];
//        [userInfo setObject:[result objectForKey:@"expires_in"] forKey:@"expires_in"];
//        [userInfo setObject:[result objectForKey:@"openid"] forKey:@"openid"];
//        [userInfo setObject:[result objectForKey:@"refresh_token"] forKey:@"scope"];
//        [userInfo setObject:[result objectForKey:@"scope"] forKey:@"scope"];
//        [self getUserInfo:[result objectForKey:@"access_token"] andOpenid:[result objectForKey:@"openid"]];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"wechat resp Error: %@", error);
//    }];
}

-(void)getUserInfo:(NSString *)access_token andOpenid:(NSString *)openid
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString * requestUrl = [NSString stringWithFormat:@"%@sns/userinfo?access_token=%@&openid=%@", WECHAT_API_DOMAIN,access_token,openid];
    
    AFJSONResponseSerializer *jsonReponseSerializer = [AFJSONResponseSerializer serializer];
    jsonReponseSerializer.acceptableContentTypes = nil;
    manager.responseSerializer = jsonReponseSerializer;
    
    [manager GET:requestUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"wechat callback user info %@" , responseObject );
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_GetUserProfileSuccess" object:nil userInfo:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"wechat resp Error: %@", error);
    }]; 
}

@end
