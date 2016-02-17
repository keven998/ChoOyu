//
//  LvSDKManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

private let iMClientManager = IMClientManager()

/*
    1.通过IMClientManager,控制消息接收管理对象,消息发送管理对象,聊天会话管理对象,好友管理对象,好友请求管理对象,CMD消息管理对象,网络连通检测对象
    2.提供了一些方法:获取聊天文件的目录
*/
class IMClientManager: NSObject {
    
    var accountId: Int = -1;
    var messageReceiveManager: MessageReceiveManager!
    var messageSendManager: MessageSendManager!
    var conversationManager: ChatConversationManager!
    var frendManager: FrendManager!
    var frendRequestManager: FrendRequestManager!
    var cmdMessageManager: CMDMessageManager!
    var netWorkReachability: NetworkReachability!
    
    /// 保存聊天图片文件的目录
    var userChatImagePath: String {
        get {
            let locationStr = documentPath.stringByAppendingString("/\(accountId)/ChatImage/")
            let fileManager = NSFileManager()

            if !fileManager.fileExistsAtPath(locationStr) {
                do {
                    try fileManager.createDirectoryAtPath(locationStr, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    
                }
            }
            return locationStr
        }
    }
    
    /// 保存聊天语音文件的目录
    var userChatAudioPath: String {
        get {
            let locationStr = documentPath.stringByAppendingString("/\(accountId)/ChatAudio/")
            let fileManager = NSFileManager()
            
            if !fileManager.fileExistsAtPath(locationStr) {
                do {
                    try fileManager.createDirectoryAtPath(locationStr, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    
                }
            }
            return locationStr
        }
    }
    
    /// 保存聊天临时文件的目录
    var userChatTempPath: String {
        get {
            let locationStr = documentPath.stringByAppendingString("/\(accountId)/ChatTemp/")
            let fileManager = NSFileManager()
            
            if !fileManager.fileExistsAtPath(locationStr) {
                do {
                    try fileManager.createDirectoryAtPath(locationStr, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    
                }
            }
            return locationStr
        }
    }
    
    override init() {
        super.init()
        netWorkReachability = NetworkReachability()
    }
    
    
    /*
        当登录的时候设置初始化的sdk
    */
    private func setUpSDKWhenLogin() {
        messageReceiveManager = MessageReceiveManager()
        
        // 初始化与服务器建立长连接的对象
        let pushSDKManager = PushSDKManager.shareInstance()
        pushSDKManager.addPushMessageListener(messageReceiveManager, withRoutingKey: "IM")

        messageSendManager = MessageSendManager()
        conversationManager = ChatConversationManager()
        frendManager = FrendManager(userId: accountId)
        frendRequestManager = FrendRequestManager(userId: accountId)
        messageSendManager.addMessageSendDelegate(conversationManager)
        cmdMessageManager = CMDMessageManager()
        
        // 调用CMD消息的讨论组和普通消息
        cmdMessageManager.addCMDMessageListener(IMDiscussionGroupManager.shareInstance(), withRoutingKey: CMDMessageRoutingKey.DiscussionGroup_CMD)
        cmdMessageManager.addCMDMessageListener(IMClientManager.shareInstance().frendManager, withRoutingKey: CMDMessageRoutingKey.Frend_CMD)
        
        messageReceiveManager.addMessageReceiveListener(cmdMessageManager, withRoutingKey: MessageReceiveDelegateRoutingKey.cmd)
        messageReceiveManager.addMessageReceiveListener(conversationManager, withRoutingKey: MessageReceiveDelegateRoutingKey.normal)
    }
    
    //  当登出的时候设置初始化的sdk
    private func setUpSDKWhenLogout() {
        
        if let manager = messageReceiveManager {
            let pushSDKManager = PushSDKManager.shareInstance()
            pushSDKManager.removePushMessageListener(manager, withRoutingKey: "IM")
        }
        messageReceiveManager = nil
        messageSendManager = nil
        conversationManager = nil
        cmdMessageManager = nil
        frendManager = nil
        frendRequestManager = nil
    }
    
    deinit {
        debug_print("IMClientManager deinit")
    }
    
    class func shareInstance() -> IMClientManager {
        return iMClientManager
    }
    
    /**
    用户登录成功
    */
    func userDidLogin(userId: Int) {
        accountId = userId
        let daoHelper = DaoHelper.shareInstance()
        daoHelper.setupDatabase()
        self.setUpSDKWhenLogin()
        MessageManager.shareInsatance().startTimer2ACK()
    }
    
    func userDidLogout() {
        self.setUpSDKWhenLogout()
        MessageManager.shareInsatance().stopTimer()
    }
    
//MARK: ConnectionManager
    func connectionSetup(isSuccess: Bool, errorCode: Int) {
        if isSuccess {
          
        }
    }
}








