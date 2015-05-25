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

class IMClientManager: NSObject, ConnectionManagerDelegate {
    
    let connectionManager: ConnectionManager
    let messageReceiveManager: MessageReceiveManager
    let messageSendManager: MessageSendManager
    let conversationManager: ChatConversationManager
    let cmdMessageManager: CMDMessageManager
    
    weak var delegate: IMClientDelegate?
    
    override init() {
        connectionManager = ConnectionManager()
        messageReceiveManager = MessageReceiveManager()
        messageSendManager = MessageSendManager()
        conversationManager = ChatConversationManager()
        messageSendManager.addMessageSendDelegate(conversationManager)
        cmdMessageManager = CMDMessageManager()
        messageReceiveManager.addMessageReceiveListener(cmdMessageManager, withRoutingKey: MessageReceiveDelegateRoutingKey.cmd)
        messageReceiveManager.addMessageReceiveListener(conversationManager, withRoutingKey: MessageReceiveDelegateRoutingKey.normal)
        if AccountManager.shareAccountManager().isLogin() {
            messageReceiveManager.ACKMessageWithReceivedMessages(nil)
        }
        super.init()
        connectionManager.connectionManagerDelegate = self
       
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
    func userDidLogin() {
        self.connectionSetup(true, errorCode: 0)
        let daoHelper = DaoHelper.shareInstance()
        daoHelper.userDidLogin()
        MessageManager.shareInsatance().startTimer2ACK()

    }
    
    
//MARK: ConnectionManager
    func connectionSetup(isSuccess: Bool, errorCode: Int) {
        if isSuccess {
          
                   }
        delegate?.userDidLogin(isSuccess, errorCode: errorCode)
    }


}
