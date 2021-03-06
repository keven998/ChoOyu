//
//  BaseMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 4/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class BaseMessage: NSObject {
    var localId: Int
    var messageId: String = ""
    var abbrevMsg: String?
    var serverId: Int
    var message: String
    var messageType: IMMessageType
    var status: IMMessageStatus
    var createTime: Int
    var sendType: IMMessageSendType
    var chatterId: Int   //与你对话的人，如果是单聊那么是用户 id 如果是群组的话那么是群组 id
    var senderId: Int    //发送消息的人, 如果是单聊是用户 id， 如果是群聊，那么是发送消息的那个人的 id
    var reveiverId: Int?  //接收消息的人
    var senderName: String?   // 发送消息的人, 如果是单聊是用户 nickname， 如果是群聊，那么是发送消息的那个人的 nickname
    var metadataId: String?
    var chatType: IMChatType = IMChatType.IMChatSingleType
    var conversationId: String?
    
    override init() {
        localId = -1
        serverId = -1
        message = ""
        messageType = .TextMessageType
        status = .IMMessageSuccessful
        createTime = 0
        sendType = .MessageSendMine
        chatterId = -1
        senderId = -1
        super.init()
    }
    
    /**
    初始化通过 contents 将具体消息的其他内容补充全,  子类重写
    :param: contents
    */
    func fillContentWithContent(contents: String) {
        
    }
    
    /**
    初始化通过 contents 将具体消息的其他内容补充全， 子类重写
    :param: contents
    */
    func fillContentWithContentDic(contentsDic: NSDictionary) {
        
    }

}
