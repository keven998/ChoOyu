//
//  LvSDKManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

private let iMClientManager = IMClientManager()

@objc protocol IMClientDelegate {
    
    func userDidLogin(isSuccess: Bool, errorCode: Int)
    
}

class IMClientManager: NSObject {
    
    var accountId: Int = -1;
    var messageReceiveManager: MessageReceiveManager!
    var messageSendManager: MessageSendManager!
    var conversationManager: ChatConversationManager!
    var frendManager: FrendManager!
    var frendRequestManager: FrendRequestManager!
    var cmdMessageManager: CMDMessageManager!
    
    /// 保存聊天图片文件的目录
    var userChatImagePath: String {
        get {
            let locationStr = documentPath.stringByAppendingPathComponent("\(accountId)/ChatImage/")
            let fileManager = NSFileManager()

            if !fileManager.fileExistsAtPath(locationStr) {
                fileManager.createDirectoryAtPath(locationStr, withIntermediateDirectories: true, attributes: nil, error: nil)
            }
            return locationStr
        }
    }
    
    /// 保存聊天语音文件的目录
    var userChatAudioPath: String {
        get {
            let locationStr = documentPath.stringByAppendingPathComponent("\(accountId)/ChatAudio/")
            let fileManager = NSFileManager()
            
            if !fileManager.fileExistsAtPath(locationStr) {
                fileManager.createDirectoryAtPath(locationStr, withIntermediateDirectories: true, attributes: nil, error: nil)
            }
            return locationStr
        }
    }
    
    /// 保存聊天临时文件的目录
    var userChatTempPath: String {
        get {
            let locationStr = documentPath.stringByAppendingPathComponent("\(accountId)/ChatTemp/")
            let fileManager = NSFileManager()
            
            if !fileManager.fileExistsAtPath(locationStr) {
                fileManager.createDirectoryAtPath(locationStr, withIntermediateDirectories: true, attributes: nil, error: nil)
            }
            return locationStr
        }
    }
    
    weak var delegate: IMClientDelegate?
    
    override init() {
        super.init()
    }
    
    private func setUpSDKWhenLogin() {
        messageReceiveManager = MessageReceiveManager()
        let pushSDKManager = PushSDKManager.shareInstance()
        pushSDKManager.addPushMessageListener(messageReceiveManager, withRoutingKey: "IM")

        messageSendManager = MessageSendManager()
        conversationManager = ChatConversationManager()
        frendManager = FrendManager(userId: accountId)
        frendRequestManager = FrendRequestManager(userId: accountId)
        messageSendManager.addMessageSendDelegate(conversationManager)
        cmdMessageManager = CMDMessageManager()
        cmdMessageManager.addCMDMessageListener(IMDiscussionGroupManager.shareInstance(), withRoutingKey: CMDMessageRoutingKey.DiscussionGroup_CMD)
        cmdMessageManager.addCMDMessageListener(IMClientManager.shareInstance().frendManager, withRoutingKey: CMDMessageRoutingKey.Frend_CMD)
        messageReceiveManager.addMessageReceiveListener(cmdMessageManager, withRoutingKey: MessageReceiveDelegateRoutingKey.cmd)
        messageReceiveManager.addMessageReceiveListener(conversationManager, withRoutingKey: MessageReceiveDelegateRoutingKey.normal)
    }
    
    private func setUpSDKWhenLogout() {
        
        let pushSDKManager = PushSDKManager.shareInstance()
        pushSDKManager.removePushMessageListener(messageReceiveManager, withRoutingKey: "IM")
        messageReceiveManager = nil
        messageSendManager = nil
        conversationManager = nil
        cmdMessageManager = nil
        frendManager = nil
        frendRequestManager = nil
    }
    
    deinit {
        debug_println("IMClientManager deinit")
    }
    
    class func shareInstance() -> IMClientManager {
        return iMClientManager
    }
    
    /**
    用户登录成功
    */
    func userDidLogin(userId: Int) {
        accountId = userId
        self.connectionSetup(true, errorCode: 0)
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
        delegate?.userDidLogin(isSuccess, errorCode: errorCode)
    }
}








