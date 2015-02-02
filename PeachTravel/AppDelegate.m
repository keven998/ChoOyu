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
#import "GexinSdk.h"
#import "HomeViewController.h"

@interface AppDelegate () <GexinSdkDelegate>

@property (strong, nonatomic) GexinSdk *gexinPusher;
@property (assign, nonatomic) int lastPayloadIndex;
@property (retain, nonatomic) NSString *payloadId;
@property (nonatomic, strong) HomeViewController *homeViewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
//    [[UINavigationBar appearance] setBarTintColor:APP_THEME_COLOR];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                            NSFontAttributeName : [UIFont fontWithName:@"MicrosoftYaHei" size:17.0]}];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    _homeViewController = [[HomeViewController alloc] init];
    
    //TODO:区分出是 个退 的推送还是 环信 的推送
    NSDictionary* message = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (message) {
        _homeViewController.shouldJumpToChatListWhenAppLaunch = YES;
    }
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:_homeViewController];
    [self.window makeKeyAndVisible];
    
   
    
    /** 设置友盟 **/
    [UMSocialData openLog:NO];
    [UMSocialData setAppKey:UMENG_KEY];
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    [UMSocialQQHandler setQQWithAppId:SHARE_QQ_APPID appKey:SHARE_QQ_KEY url:@"http://www.umeng.com/social"];
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:SHARE_WEIXIN_APPID appSecret:SHARE_WEIXIN_SECRET url:@"http://www.lvxingpai.com"];
    
    /*****注册推送*****/
    [self registerRemoteNotification];
    
    /****** 设置环信 ******/
    
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"TaoziAPNS_Development";
#else
    apnsCertName = @"TaoziAPNS_Production";
#endif

#if DEBUG
    [[EaseMob sharedInstance] enableUncaughtExceptionHandler];
#endif
    
    [[[EaseMob sharedInstance] chatManager] setIsAutoFetchBuddyList:YES];
    
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"aizou#taozi" apnsCertName:apnsCertName];

    //以下一行代码的方法里实现了自动登录，异步登录，需要监听[didLoginWithInfo: error:]
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    /******设置个推*****/
    [self startGeTuiSdk];
    
    return YES;
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    
    //设置个推
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSString *geTuideviceToken = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"deviceToken:%@", geTuideviceToken);
    // [3]:向个推服务器注册deviceToken
    if (_gexinPusher) {
        [_gexinPusher registerDeviceToken:geTuideviceToken];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
    
    // [3-EXT]:如果APNS注册失败，通知个推服务器
    if (_gexinPusher) {
        [_gexinPusher registerDeviceToken:@""];
    }
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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[EaseMob sharedInstance] application:application didReceiveRemoteNotification:userInfo];
}

/**
 *  程序收到本地推送消息
 *
 *  @param application
 *  @param notification 
 */
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[EaseMob sharedInstance] application:application didReceiveLocalNotification:notification];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"applicationDidEnterBackground" object:nil];
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
    [self stopGeTuiSdk];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationDidBecomeActive:application];
    [self startGeTuiSdk];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillTerminate:application];
    [self saveContext];
}

#pragma mark - IChatManagerDelegate 好友变化

- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message
{
    if (!username) {
        return;
    }
    if (!message) {
        message = [NSString stringWithFormat:@"%@ 添加你为好友", username];
    }
}

#pragma mark - IChatManagerDelegate 群组变化

- (void)didReceiveGroupInvitationFrom:(NSString *)groupId
                              inviter:(NSString *)username
                              message:(NSString *)message
{
    if (!groupId || !username) {
        return;
    }
    
    NSString *groupName = groupId;
    if (!message || message.length == 0) {
        message = [NSString stringWithFormat:@"%@ 邀请你加入群组\'%@\'", username, groupName];
    }
    NSLog(@"%@",message);
}

//接收到入群申请
- (void)didReceiveApplyToJoinGroup:(NSString *)groupId
                         groupname:(NSString *)groupname
                     applyUsername:(NSString *)username
                            reason:(NSString *)reason
                             error:(EMError *)error
{
    if (!groupId || !username) {
        return;
    }
    
    if (!reason || reason.length == 0) {
        reason = [NSString stringWithFormat:@"%@ 申请加入群组\'%@\'", username, groupname];
    }
    else{
        reason = [NSString stringWithFormat:@"%@ 申请加入群组\'%@\'：%@", username, groupname, reason];
    }
    
    if (error) {
        NSString *message = [NSString stringWithFormat:@"发送申请失败:%@\n原因：%@", reason, error.description];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else{
        NSLog(@"%@", reason);
    }
}

- (void)didReceiveRejectApplyToJoinGroupFrom:(NSString *)fromId
                                   groupname:(NSString *)groupname
                                      reason:(NSString *)reason
{
    if (!reason || reason.length == 0) {
        reason = [NSString stringWithFormat:@"被拒绝加入群组\'%@\'", groupname];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"申请提示" message:reason delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error
{
    NSString *tmpStr = group.groupSubject;
    NSString *str;
    if (!tmpStr || tmpStr.length == 0) {
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *obj in groupArray) {
            if ([obj.groupId isEqualToString:group.groupId]) {
                tmpStr = obj.groupSubject;
                break;
            }
        }
    }
    
    if (reason == eGroupLeaveReason_BeRemoved) {
        str = [NSString stringWithFormat:@"你被从群组\'%@\'中踢出", tmpStr];
    }
    if (str.length > 0) {
    }
}

#pragma mark - IChatManagerDelegate

- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    NSLog(@"网络状态发生变化");
}

#pragma mark - EMChatManagerPushNotificationDelegate

/**
 *  环信绑定失败
 *
 *  @param error
 */

- (void)didBindDeviceWithError:(EMError *)error
{
    if (error) {
        NSLog(@"环信推送绑定失败");
    }
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

#pragma mark - 个推

- (void)startGeTuiSdk
{
    if (!_gexinPusher) {
        NSError *err = nil;
        _gexinPusher = [GexinSdk createSdkWithAppId:kGeTuiAppId
                                             appKey:kGeTuiAppKey
                                          appSecret:kGeTuiAppSecret
                                         appVersion:@"0.0.0"
                                           delegate:self
                                              error:&err];
        if (!_gexinPusher) {

        } else {

        }
        
    }
}

- (void)stopGeTuiSdk
{
    if (_gexinPusher) {
        [_gexinPusher destroy];
        _gexinPusher = nil;
    }
}

- (void)registerRemoteNotification {
#if !TARGET_IPHONE_SIMULATOR
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    //iOS8 注册APNS
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
    
#endif
    
}

#pragma mark - GexinSdkDelegate
- (void)GexinSdkDidRegisterClient:(NSString *)clientId
{
}

/**
 *  启动程序收到个退的推送
 *
 *  @param payloadId
 *  @param appId
 */
- (void)GexinSdkDidReceivePayload:(NSString *)payloadId fromApplication:(NSString *)appId
{
    // [4]: 收到个推消息
    NSData *payload = [_gexinPusher retrivePayloadById:payloadId];
    NSString *payloadMsg = nil;
    if (payload) {
        payloadMsg = [[NSString alloc] initWithBytes:payload.bytes
                                              length:payload.length
                                            encoding:NSUTF8StringEncoding];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"*****GexinSdkDidReceivePayload_推送%@", payloadMsg] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    [alert show];
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




