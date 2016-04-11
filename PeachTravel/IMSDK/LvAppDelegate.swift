//
//  LvAppDelegate.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

let isiOS8 = (UIDevice.currentDevice().systemVersion as NSString).doubleValue >= 8.0

extension AppDelegate {
    
    
    func lvApplication(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // 程序启动之后调用此方法,如果用户登录,执行下列操作
        if (AccountManager.shareAccountManager().isLogin()) {
            IMClientManager.shareInstance().userDidLogin(AccountManager.shareAccountManager().account.userId)
            let connectionManager = ConnectionManager.shareInstance()
            connectionManager.bindUserIdWithRegistionId(AccountManager.shareAccountManager().account.userId)
        }
    
        let setting = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(setting)
            
        ConnectionManager.shareInstance().createPushConnection()
        return true
    }
    
    func lvApplicationWillResignActive(application: UIApplication) {
        
    }
    
    func lvApplicationDidEnterBackground(application: UIApplication) {
        
    }
    
    func lvApplicationWillEnterForeground(application: UIApplication) {
    }
    
    func lvApplicationDidBecomeActive(application: UIApplication) {
    }
    
    func lvApplicationWillTerminate(application: UIApplication) {
    }

    func lvApplication(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let tempStr = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>"))
        let token = tempStr.stringByReplacingOccurrencesOfString(" ", withString: "")
        NSLog("设备 token 为\(token)")
        let pushSDKManager = PushSDKManager.shareInstance()
        pushSDKManager.registerDeviceToken(token)
    }
    
    func lvApplication(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        let pushSDKManager = PushSDKManager.shareInstance()
        pushSDKManager.registerDeviceToken("")
    }
    
    func lvApplication(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
    }
    
    func lvApplication(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
    }

}
















