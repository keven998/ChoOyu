//
//  ChatConversationManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

@objc protocol ChatConversationManagerDelegate {
    
    /**
    会话列表状态需要更新
    :param: 需要更新的会话
    */
    func conversationStatusHasChanged(conversation: ChatConversation)
    
    /**
    有些会话已经移除
    :param: conversationList
    */
    func conversationsHaveRemoved(conversationList: NSArray)
    
    /**
    有些会话已经添加
    :param: conversationList
    */
    func conversationsHaveAdded(conversationList: NSArray)
    
}

class ChatConversationManager: NSObject, MessageReceiveManagerDelegate, MessageSendManagerDelegate {
    
    private var conversationList: Array<ChatConversation>
    
    //所有会话的未读消息个数总和
    var totalMessageUnreadCount: Int {
        get {
            var totalCount = 0
            for conversation in conversationList {
                totalCount += conversation.unReadMessageCount
            }
            return totalCount
        }
    }
    
    var delegate: ChatConversationManagerDelegate?
        
    override init() {
        conversationList = Array<ChatConversation>()
        super.init()
    }
    
    func getConversationList() -> NSArray {
        if conversationList.count < 1 {
            self.updateConversationListFromDB()
        }
        self.reorderConversationList()
        return conversationList
    }
    
    func updateConversationListFromDB() {
        var daoHelper = DaoHelper.shareInstance()
        NSLog("****开始获取会话列表*****")
        conversationList = daoHelper.getAllConversationList()
        NSLog("****结束获取会话列表*****")
    }
    
    private func conversationIsExit(conversation: ChatConversation) -> Bool {
        for exitConversation in conversationList {
            if exitConversation.chatterId == conversation.chatterId {
                return true
            }
        }
        return false
    }
    
    /**
    将 conversationlist 重新排序
    */
    func reorderConversationList() {
        sort(&conversationList, { (conversation1: ChatConversation, conversation2: ChatConversation) -> Bool in
            if conversation1.isTopConversation && !conversation2.isTopConversation {
                return true
            } else if !conversation1.isTopConversation && conversation2.isTopConversation {
                return false
            } else {
                return conversation1.lastUpdateTime >= conversation2.lastUpdateTime
            }
        })
    }

    /**
    新建会话列表, 会话的 用户 id
    */
    func createNewConversation(#chatterId: Int, chatType: IMChatType) -> ChatConversation {
        var conversation = ChatConversation()
        conversation.chatterId = chatterId
        var time = NSDate().timeIntervalSince1970
        var timeInt: Int = Int(round(time))
        conversation.lastUpdateTime = timeInt
        conversation.chatType = chatType
        
        var frendManager = FrendManager.shareInstance()
        
        if let frend = frendManager.getFrendInfoFromDB(userId: chatterId) {
            self.fillConversationWithFrendData(conversation, frendModel: frend)
            addConversation(conversation)
            
        } else {
            self.asyncGetConversationInfoFromServer(conversation, completion: { (fullConversation) -> () in
                self.addConversation(conversation)
            })
        }
        return conversation
    }
    
    /**
    通过一条 message 新建一个会话
    :param: message
    :returns:
    */
    func createNewConversation(#message: BaseMessage) -> ChatConversation {
        return self.createNewConversation(chatterId: message.chatterId, chatType: message.chatType)
    }

    /**
    通过 chatterid 获取一个 conversation，如果已经存在那么返回一个已存在的，如果不存在新建一个新的
    
    :param: chatterId
    
    :returns:
    */
    func getConversationWithChatterId(chatterId: Int, chatType: IMChatType) -> ChatConversation {
        for exitConversation in conversationList {
            if exitConversation.chatterId == chatterId {
                return exitConversation
            }
        }
        var conversation = self.createNewConversation(chatterId: chatterId, chatType: chatType)
        self.addConversation(conversation)
        return conversation
    }
    
    /**
    通过一条消息得到这条消息所属的 conversation
    :param: message
    :returns:
    */
    func getConversationWithMessage(message: BaseMessage) -> ChatConversation? {
        for exitConversation in conversationList {
            if exitConversation.chatterId == message.chatterId {
                return exitConversation
            }
        }
        return nil
    }
    
    /**
     添加一个会话到会话列表里
    :param: chatterId
    */
    func addConversation(conversation: ChatConversation) {
        if self.conversationIsExit(conversation) {
            return
        }
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.addConversation(conversation)
        self.conversationList.append(conversation)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            delegate?.conversationsHaveAdded(conversationList)
        })
    }
    
    /**
    移除一个 conversation
    :param: chatterId
    :Bool: 是否成功
    */
    func removeConversation(#chatterId: Int) -> Bool {
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.removeConversationfromDB(chatterId)
        for i in 0 ..< conversationList.count {
            var conversation = conversationList[i]
            if conversation.chatterId == chatterId {
                conversationList.removeAtIndex(i)
                delegate?.conversationsHaveRemoved([conversation])
                return true
            }
        }
        return false
    }
    
    /**
    从网上获取一个会话的详细信息
    
    :param: conversation
    :param: completion
    */
    func asyncGetConversationInfoFromServer(conversation: ChatConversation, completion:(fullConversation: ChatConversation?) -> ()) {
        if conversation.chatType == IMChatType.IMChatSingleType {
            var frendManager = FrendManager.shareInstance()
            frendManager.asyncGetFrendInfoFromServer(conversation.chatterId, completion: { (isSuccess, errorCode, frendInfo) -> () in
                if let frend = frendInfo {
                    self.fillConversationWithFrendData(conversation, frendModel: frend)
                }
                completion(fullConversation: conversation)
            })
            
        } else if conversation.chatType == IMChatType.IMChatDiscussionGroupType {
            
        } else if conversation.chatType == IMChatType.IMChatGroupType {
            
        }
       
    }
    
//MARK: private methods
    
    /**
    处理收到的消息，将收到的消息对应的插入 conversation 里，更新最后一条本地消息，和最后一条服务器消息
    :param: message 待处理的消息
    */
    private func handleReceiveMessage(message: BaseMessage) {
        if let conversation = self.getConversationWithMessage(message) {
            conversation.addReceiveMessage(message)
            if !conversation.isCurrentConversation {
                conversation.unReadMessageCount++
            }
            if conversation.conversationId == nil {
                conversation.conversationId = message.conversationId
                var daoHelper = DaoHelper.shareInstance()
                daoHelper.updateConversationIdInConversation(conversation.conversationId!, userId: conversation.chatterId)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                delegate?.conversationStatusHasChanged(conversation)
            })
            return
        }
        
        //如果在所有的已有会话里找不到这条消息的会话，那么新建一个会话并加入到会话列表里

        var conversation = createNewConversation(message: message)
        var frendManager = FrendManager.shareInstance()
        conversation.addReceiveMessage(message)
        conversation.unReadMessageCount = 1
    }
    
    /**
    利用 frend 信息来补全 conversation 的信息
    
    :param: conversation
    :param: frendModel
    */
    private func fillConversationWithFrendData(conversation: ChatConversation, frendModel: FrendModel) {
        conversation.fillConversationType(frendType: frendModel.type)
        conversation.chatterName = frendModel.nickName
        conversation.chatterId = frendModel.userId
    }
    
    /**
    处理刚开始发送的消息。只更新最后一条本地消息，等发送成功后更新最后一条本地消息
    :param: message
    */
    private func handleSendingMessage(message: BaseMessage) {
        if let conversation = self.getConversationWithMessage(message) {
            conversation.addSendingMessage(message)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                delegate?.conversationStatusHasChanged(conversation)
            })
        }
    }
    
    /**
    处理已经发送成功的消息，更新指定 conversation 里的最后一条服务器消息
    :param: message
    */
    private func handleSendedMessage(message: BaseMessage) {
        if let conversation = self.getConversationWithMessage(message) {
            conversation.messageHaveSended(message)
            if conversation.lastLocalMessage?.localId == message.localId {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    delegate?.conversationStatusHasChanged(conversation)
                })
            }
        }
    }
    
//MARK: MessageTransferManagerDelegate
    /**
    会话中增加了一条新消息
    :param: message
    */
    func receiveNewMessage(message: BaseMessage) {
        self.handleReceiveMessage(message)
    }
    
    /**
    消息已经被发送，包含成功和失败的情况
    
    :param: message
    */
    func messageHasSended(message: BaseMessage) {
        self.handleSendedMessage(message)
    }
    
    /**
    新发送了一条消息
    
    :param: message
    */
    func sendNewMessage(message: BaseMessage) {
        self.handleSendingMessage(message)
    }
    
    
}










