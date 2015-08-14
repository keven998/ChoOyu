//
//  ChatConversation.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

@objc protocol ChatConversationDelegate {
    
    /**
    会话中的消息
    
    :param: messageChangedList
    */
    optional func receiverMessage(message: BaseMessage)
    
    /**
    消息发送完成
    :param: message   发送完成后的消息
    :param: errorCode 发送的错误代码
    */
    optional func didSendMessage(message: BaseMessage)
}

class ChatConversation: NSObject {
    var conversationId: String?
    var chatterId: Int = 0
    var chatterName: String = ""
    var chatterAvatar: String?
    var lastUpdateTime: Int = 0
    var defalutMessageNumber: Int = 0
    var chatMessageList: Array<BaseMessage>
    var chatType: IMChatType = IMChatType.IMChatSingleType     //聊天类型，默认是单聊
    var isCurrentConversation: Bool = false {             //是否是当前显示的会话，默认为 false
        willSet {
            if newValue == false {
                if chatMessageList.count > defalutMessageNumber {
                    let range = Range(start: 0, end: chatMessageList.count-defalutMessageNumber)
                    chatMessageList.removeRange(range)
                }
            }
        }
    }
    var isTopConversation: Bool = false                        //是否置顶
    var isBlockMessage: Bool = false                            //是否设置为免打扰
    var unReadMessageCount: Int {
        willSet {
            ChatConversation.updateUnreadMessageCountInDB(newValue, chatterId: chatterId)
        }
    }//未读消息的数量， 默认为0
    
    weak var delegate: ChatConversationDelegate?
    
    override init() {
        chatterId = 0
        chatMessageList = Array()
        unReadMessageCount = 0
        super.init()
    }
    
    deinit {
        debug_println("ChatConversation deinit")
    }
    
    func updateTimeStamp(newValue: Int) {
        lastUpdateTime = newValue
        ChatConversation.updateConversationTimestampInDB(newValue, chatterId: chatterId)
    }
    
    func fillConversationType(#frendType: IMFrendType) {
        if FrendModel.typeIsCorrect(frendType, typeWeight: IMFrendWeightType.Frend) {
            chatType = IMChatType.IMChatSingleType
            
        } else if FrendModel.typeIsCorrect(frendType, typeWeight: IMFrendWeightType.Group) {
            chatType = IMChatType.IMChatGroupType
            
        } else if FrendModel.typeIsCorrect(frendType, typeWeight: IMFrendWeightType.DiscussionGroup) {
            chatType = IMChatType.IMChatDiscussionGroupType
        }
    }
    
//MARK: private function
    
    /**
    更新最新一条本地消息
    */
    var lastLocalMessage: BaseMessage? {
        get {
            let retMessage = chatMessageList.last
            if retMessage != nil {
                return retMessage

            } else {
                let daoHelper = DaoHelper.shareInstance()
                let tableName = "chat_\(chatterId)"
                return daoHelper.selectLastLocalMessageInChatTable(tableName)
            }
        }
    }
    
    /**
    更新最后一条与服务器同步的 message, 默认的 serverid 为-1，如果大于0则为与服务器同步的 message
    */
    var lastServerMessage: BaseMessage? {
        get {
            for var i = chatMessageList.count-1; i>0; i-- {
                let message = chatMessageList[i]
                if message.serverId >= 0 {
                    return message
                }
            }
            let daoHelper = DaoHelper.shareInstance()
            let tableName = "chat_\(chatterId)"
            return daoHelper.selectLastServerMessage(tableName)
        }
    }
    
//MARK: public Internal function
    
    func deleteMessage(#localId: Int) {
        for (index, value) in enumerate(self.chatMessageList) {
            if value.localId == localId {
                self.chatMessageList.removeAtIndex(index)
            }
        }
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.deleteChatMessage("chat_\(chatterId)", localId: localId)
    }
    
    /**
    删除会话中所有的信息
    */
    func deleteAllMessage() {
        self.chatMessageList.removeAll(keepCapacity: false)
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.delteAllMessageInDB("chat_\(chatterId)")
    }
    
    /**
    添加收到的消息到消息列表中
    :param: messageList
    */
    func addReceiveMessage(message: BaseMessage) {
        chatMessageList.append(message)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            delegate?.receiverMessage?(message)
        })
        self.updateTimeStamp(Int(NSDate().timeIntervalSince1970))
    }
    
    /**
    初始化会话中的聊天记录
    */
    func getDefaultChatMessageInConversation(messageCount: Int) {
        defalutMessageNumber = messageCount
        
        // 如果服务器返回的数据数量大于展示消息数,直接返回
        if chatMessageList.count >= messageCount {
            return
        }
        NSLog("开始加载聊天界面记录")
        var daoHelper = DaoHelper.shareInstance()
        var retArray = NSArray()
        chatMessageList = daoHelper.selectChatMessageList(chatterId, untilLocalId: Int.max, messageCount: messageCount)

        NSLog("结束加载聊天界面记录")
    }
    
    /**
    获取更多的消息
    
    :param: messageCount 目标数量
    
    :returns: 消息的增量
    */
    func getMoreChatMessageInConversation(messageCount: Int) -> Array<BaseMessage> {
        
        NSLog("开始加载更多的聊天界面记录")
        let daoHelper = DaoHelper.shareInstance()
        let tableName = "chat_\(chatterId)"
        let retArray = NSArray()
        let localId: Int
        if chatMessageList.count > 0 {
            localId = (chatMessageList.first)!.localId
        } else {
            localId = Int.max
        }
        let moreMessages = daoHelper.selectChatMessageList(chatterId, untilLocalId: localId, messageCount: messageCount)
        
        for var i = moreMessages.count-1; i>=0; i-- {
            let message = moreMessages[i]
            chatMessageList.insert(message, atIndex: 0)
        }
        
        NSLog("结束加载更多的聊天界面记录")
        return moreMessages
    }
    
    /**
    获取会话中的图片消息
    
    :returns: 所有的会话的图片消息
    */
    func getAllImageMessageInConversation() -> Array<BaseMessage> {
        let daoHelper = DaoHelper.shareInstance()
        let tableName = "chat_\(chatterId)"
        return daoHelper.getAllImageMessageInChatTable(tableName)
    }
    
    /**
    将会话的未读消息置为0
    */
    func resetConvsersationUnreadMessageCount() {
        unReadMessageCount = 0
        ChatConversation.updateUnreadMessageCountInDB(0, chatterId: chatterId)
    }
    
    /**
    更新数据库里未读消息的数量
    
    :param: count
    */
    private class func updateUnreadMessageCountInDB(count: Int, chatterId: Int) {
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.updateUnreadMessageCountInConversation(count, userId: chatterId)
    }
    
    private class func updateConversationTimestampInDB(timestamp: Int,  chatterId: Int) {
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.updateTimestampInConversation(timestamp, userId: chatterId)
    }
    
    /**
    添加一条发送的消息的发送列表中
    :param: message
    */
    func addSendingMessage(message: BaseMessage) {
        chatMessageList.append(message)
        self.updateTimeStamp(message.createTime)
    }
    
    /**
    消息发送完成，可能成功可能失败
    :param: message   发送完后的消息
    */
    func messageHaveSended(message: BaseMessage) {
        for var i=chatMessageList.count-1; i>0; i-- {
            var tempMessage = chatMessageList[i]
            if tempMessage.localId == message.localId {
                tempMessage.status = message.status
                tempMessage.serverId = message.serverId
            }
        }
        delegate?.didSendMessage?(message)
    }
}


