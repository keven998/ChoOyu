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

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self lvApplication:application didFinishLaunchingWithOptions:launchOptions];
    if (IS_IOS8) {
        [[UINavigationBar appearance] setTranslucent:NO];
    } else {
        
    }
    [[UINavigationBar appearance] setTintColor:APP_THEME_COLOR];
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"ic_navigation_back.png"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"ic_navigation_back.png"]];
    [[UINavigationBar appearance] setBackgroundImage:[ConvertMethods createImageWithColor:[UIColor whiteColor]]
                                       forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[ConvertMethods createImageWithColor:APP_THEME_COLOR]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    //目前只有环信的推送。因此暂时
//    NSDictionary* message = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (message) {
//        _homeViewController.shouldJumpToChatListWhenAppLaunch = YES;
//    }
    self.window.rootViewController = [[HomeViewController alloc] init];
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

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self saveContext];
}

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

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"UserInfo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"UserInfoDB.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                       NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES],
                                       NSInferMappingModelAutomaticallyOption, nil];

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:optionsDictionary error:&error]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


@end




