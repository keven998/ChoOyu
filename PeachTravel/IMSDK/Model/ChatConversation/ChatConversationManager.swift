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
        conversationList = daoHelper.getAllConversationList()
        self.setUpDefaultConversation()
        self.reorderConversationList()
    }
    
    /**
    异步回去一个会话到 conversationId 如果本地数据库有，那么直接返回，如果没有，那么从服务器上获取,获取 conversationid 值的时候顺便把 conversationid 属性设置
    
    :param: chatterId
    :param: completionBlock
    :param: conversationId
    */
    func asyncGetConversationInfoFromServer(#chatterId: Int, completionBlock: (isSuccess: Bool, conversation: ChatConversation?) -> ()) {
        let imClientManager = IMClientManager.shareInstance()
        let url = "\(HedyUserUrl)/\(imClientManager.accountId)/conversations/\(chatterId)"
        NetworkTransportAPI.asyncGET(requestUrl: url, parameters: nil, completionBlock: { (isSuccess, errorCode, retMessage) -> () in
            if isSuccess {
                if let objc = retMessage as? NSDictionary {
                    let daoHelper = DaoHelper.shareInstance()
                    let conversation = ChatConversation()
                    if let conversationId = objc.objectForKey("id") as? String {
                        conversation.conversationId = conversationId
                        daoHelper.updateConversationIdInConversation(conversation.conversationId!, userId: conversation.chatterId)
                    }
                    if let muted = objc.objectForKey("muted") as? Bool {
                        conversation.isBlockMessag = muted
                        daoHelper.updateBlockStatusInConversation(conversation.isBlockMessag, userId: conversation.chatterId)
                    }
                    completionBlock(isSuccess: true, conversation: conversation)
                }
            } else {
                completionBlock(isSuccess: false, conversation: nil)
            }
        })
    }
    
    /**
    将 conversationlist 重新排序,问问>派派>置顶>其他时间顺序
    */
    func reorderConversationList() {
        sort(&conversationList, { (conversation1: ChatConversation, conversation2: ChatConversation) -> Bool in
            if conversation1.chatterId == 10001 {
                return true
            }
            if conversation2.chatterId == 10001 {
                return false
            }
            if conversation2.chatterId == 10000 && conversation1.chatterId == 10001 {
                return true
            }
            if conversation1.chatterId == 10000 && conversation2.chatterId == 10001 {
                return false
            }
            if conversation1.chatterId == 10000 && conversation2.chatterId != 10000 {
                return true
            }
            if conversation2.chatterId == 10000 && conversation1.chatterId != 10001 {
                return false
            }
            if conversation1.isTopConversation && !conversation2.isTopConversation {
                return true
            } else if !conversation1.isTopConversation && conversation2.isTopConversation {
                return false
            } else if conversation1.lastUpdateTime == conversation2.lastUpdateTime {
                return conversation1.chatterId > conversation2.chatterId
            } else {
                return conversation1.lastUpdateTime >= conversation2.lastUpdateTime
            }
        })
    }
    
    /**
    修改会话的状态(免打扰)
    
    :param: groupId
    :param: groupState
    
    */
    func asyncChangeConversationBlockStatus(#chatterId: Int, isBlock: Bool, completion: (isSuccess: Bool, errorCode: Int) -> ()) {
        if let exitConversation = self.getExistConversationInConversationList(chatterId) {
            
            let imClientManager = IMClientManager.shareInstance()
            if let conversationId = exitConversation.conversationId {
                let url = "\(HedyUserUrl)/\(imClientManager.accountId)/conversations/\(conversationId)"
                let params = ["mute": isBlock]
                NetworkTransportAPI.asyncPATCH(requstUrl: url, parameters: params, completionBlock: { (isSuccess, errorCode, retMessage) -> () in
                    if isSuccess {
                        exitConversation.isBlockMessag = isBlock
                        let daoHelper = DaoHelper.shareInstance()
                        daoHelper.updateBlockStatusInConversation(isBlock, userId: chatterId)
                    }
                    completion(isSuccess: isSuccess, errorCode: errorCode)
                })
                
            } else {
                self.asyncGetConversationInfoFromServer(chatterId: chatterId, completionBlock: { (isSuccess, conversation) -> () in
                    if isSuccess {
                        if let conversationId = conversation!.conversationId {
                            let url = "\(HedyUserUrl)/\(imClientManager.accountId)/conversations/\(conversation?.conversationId!)"
                            let params = ["mute": isBlock]
                            NetworkTransportAPI.asyncPATCH(requstUrl: url, parameters: params, completionBlock: { (isSuccess, errorCode, retMessage) -> () in
                                if isSuccess {
                                    exitConversation.isBlockMessag = isBlock
                                    let daoHelper = DaoHelper.shareInstance()
                                    daoHelper.updateBlockStatusInConversation(isBlock, userId: chatterId)
                                }
                                completion(isSuccess: isSuccess, errorCode: errorCode)
                            })
                        } else {
                            completion(isSuccess: false, errorCode: 0)
                        }
                    } else {
                        completion(isSuccess: false, errorCode: 0)
                    }
                })
            }

        }
    }

    /**
    新建会话, 会话的 用户 id
    */
    func createNewConversation(#chatterId: Int, chatType: IMChatType) -> ChatConversation {
        var exitConversation = ChatConversation()
        exitConversation.chatterId = chatterId
        self.asyncGetConversationInfoFromServer(chatterId: chatterId) { (isSuccess, conversation) -> () in
            if isSuccess {
                exitConversation.conversationId = conversation!.conversationId
                exitConversation.isBlockMessag = conversation!.isBlockMessag
            }
        }
        var time = NSDate().timeIntervalSince1970
        var timeInt: Int = Int(round(time))
        exitConversation.lastUpdateTime = timeInt
        exitConversation.chatType = chatType
        var frendManager = IMClientManager.shareInstance().frendManager
        
        var type: IMFrendWeightType?
        if chatType == IMChatType.IMChatDiscussionGroupType {
            type = IMFrendWeightType.DiscussionGroup
        }
        if chatType == IMChatType.IMChatGroupType {
            type = IMFrendWeightType.Group
        }
    
        if let frend = frendManager.getFrendInfoFromDB(userId: chatterId, frendType: type) {
            self.fillConversationWithFrendData(exitConversation, frendModel: frend)
            addConversation(exitConversation)
            
        } else {
            self.asyncChatterUserInfoInConversationFromServer(exitConversation, completion: { (fullConversation: ChatConversation) -> () in
                self.addConversation(fullConversation)
            })
        }
        return exitConversation
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
    在已存在的会话列表中取出一条会话
    
    :param: chatterId
    
    :returns: 
    */
    func getExistConversationInConversationList(chatterId: Int) -> ChatConversation? {
        for exitConversation in conversationList {
            if exitConversation.chatterId == chatterId {
                return exitConversation
            }
        }
        return nil
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
    func removeConversation(#chatterId: Int, deleteMessage: Bool) {
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.removeConversationfromDB(chatterId)
        for i in 0 ..< conversationList.count {
            var conversation = conversationList[i]
            if conversation.chatterId == chatterId {
                conversationList.removeAtIndex(i)
                delegate?.conversationsHaveRemoved([conversation])
                break
            }
        }
        if deleteMessage {
            daoHelper.dropMessageTable("chat_\(chatterId)")
        }
    }
    
    /**
    从网上获取一个会话的聊天信息
    
    :param: conversation
    :param: completion
    */
    func asyncChatterUserInfoInConversationFromServer(conversation: ChatConversation, completion:(fullConversation: ChatConversation) -> ()) {
        if conversation.chatType == IMChatType.IMChatSingleType {
            let frendManager = IMClientManager.shareInstance().frendManager
            frendManager.asyncGetFrendInfoFromServer(conversation.chatterId, completion: { (isSuccess, errorCode, frendInfo) -> () in
                if let frend = frendInfo {
                    self.fillConversationWithFrendData(conversation, frendModel: frend)
                }
                completion(fullConversation: conversation)
            })
            
        } else if conversation.chatType == IMChatType.IMChatDiscussionGroupType {
            let discussionGroupManager = IMDiscussionGroupManager.shareInstance()
            discussionGroupManager.asyncGetDiscussionGroupInfoFromServer(conversation.chatterId, completion: { (isSuccess, errorCode, discussionGroup) -> () in
                if let group = discussionGroup {
                    self.fillConversationWithIMDiscussionGroup(conversation, group: group)
                    
                } else {
                    let group = IMDiscussionGroup()
                    group.groupId = conversation.chatterId
                    let groupManager = IMDiscussionGroupManager.shareInstance()
                    groupManager.updateGroupInfoInDB(group)
                    self.fillConversationWithIMDiscussionGroup(conversation, group: group)
                }
                completion(fullConversation: conversation)
            })
            
        } else if conversation.chatType == IMChatType.IMChatGroupType {
            
        }
       
    }
    
//MARK: private methods
    
    /**
    设置初始化会话，旅行问问和派派
    */
    private func setUpDefaultConversation() {
        let conversationWenwen = ChatConversation()
        //派派的 conversation
        conversationWenwen.chatterId = 10001
        conversationWenwen.chatterName = "旅行问问";
        conversationWenwen.lastUpdateTime = Int(NSDate().timeIntervalSince1970)
        self.addConversation(conversationWenwen)
        let conversation = ChatConversation()
        
        //派派的 conversation
        conversation.chatterId = 10000
        conversation.chatterName = "派派";
        conversation.lastUpdateTime = Int(NSDate().timeIntervalSince1970)
        self.addConversation(conversation)
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
    处理收到的消息，将收到的消息对应的插入 conversation 里，更新最后一条本地消息，和最后一条服务器消息
    :param: message 待处理的消息
    */
    private func handleReceiveMessage(message: BaseMessage) {
        if let conversation = self.getConversationWithMessage(message) {
            conversation.addReceiveMessage(message)
            debug_println("conversation: \(conversation.chatterName)")
            if !conversation.isCurrentConversation {
                conversation.unReadMessageCount++
            }
            if (conversation.conversationId == nil && message.conversationId != nil) {
                conversation.conversationId = message.conversationId
                let daoHelper = DaoHelper.shareInstance()
                daoHelper.updateConversationIdInConversation(conversation.conversationId!, userId: conversation.chatterId)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                delegate?.conversationStatusHasChanged(conversation)
            })
            return
        }
        
        //如果在所有的已有会话里找不到这条消息的会话，那么新建一个会话并加入到会话列表里

        var conversation = createNewConversation(message: message)
        var frendManager = IMClientManager.shareInstance().frendManager
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
        if frendModel.memo != "" {
            conversation.chatterName = frendModel.memo
        } else {
            conversation.chatterName = frendModel.nickName
        }
        if frendModel.avatarSmall != "" {
            conversation.chatterAvatar = frendModel.avatarSmall
        } else {
            conversation.chatterAvatar = frendModel.avatar
        }
        conversation.chatterId = frendModel.userId
    }
    
    /**
    利用 IMDiscussionGroup 信息来补全 conversation 的信息
    
    :param: conversation
    :param: frendModel
    */
    private func fillConversationWithIMDiscussionGroup(conversation: ChatConversation, group: IMDiscussionGroup) {
        conversation.chatType = IMChatType.IMChatDiscussionGroupType
        conversation.chatterName = group.subject ?? ""
        conversation.chatterId = group.groupId
    }
    
    /**
    利用 IMGroupModel 信息来补全 conversation 的信息
    
    :param: conversation
    :param: frendModel
    */
    private func fillConversationWithFrendIMGroup(conversation: ChatConversation, group: IMGroupModel) {
        conversation.chatType = IMChatType.IMChatDiscussionGroupType
        conversation.chatterName = group.subject
        conversation.chatterId = group.groupId
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










