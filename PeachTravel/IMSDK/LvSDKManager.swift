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
    var cmdMessageManager: CMDMessageManager!
    var netWorkReachability: NetworkReachability!
    
    weak var delegate: IMClientDelegate?
    
    override init() {
        super.init()
        netWorkReachability = NetworkReachability()
       
    }
    
    private func setUpSDKWhenLogin() {
        messageReceiveManager = MessageReceiveManager()
        messageSendManager = MessageSendManager()
        conversationManager = ChatConversationManager()
        messageSendManager.addMessageSendDelegate(conversationManager)
        cmdMessageManager = CMDMessageManager()
        cmdMessageManager.addCMDMessageListener(IMDiscussionGroupManager.shareInstance(), withRoutingKey: CMDMessageRoutingKey.DiscussionGroup_CMD)
        cmdMessageManager.addCMDMessageListener(FrendManager(userId: AccountManager.shareAccountManager().account.userId), withRoutingKey: CMDMessageRoutingKey.Frend_CMD)
        
        messageReceiveManager.addMessageReceiveListener(cmdMessageManager, withRoutingKey: MessageReceiveDelegateRoutingKey.cmd)
        messageReceiveManager.addMessageReceiveListener(conversationManager, withRoutingKey: MessageReceiveDelegateRoutingKey.normal)
        if AccountManager.shareAccountManager().isLogin() {
            messageReceiveManager.ACKMessageWithReceivedMessages(nil)
        }
    }
    
    private func setUpSDKWhenLogout() {
        messageReceiveManager = nil
        messageSendManager = nil
        conversationManager = nil
        cmdMessageManager = nil
    }
    
    deinit {
        println("IMClientManager deinit")
    }
    
    class func shareInstance() -> IMClientManager {
        return iMClientManager
    }
    
    /**
    用户登录成功
    */
    func userDidLogin(userId: Int) {
        accountId = userId
        self.setUpSDKWhenLogin()
        self.connectionSetup(true, errorCode: 0)
        let daoHelper = DaoHelper.shareInstance()
        daoHelper.userDidLogin()
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








