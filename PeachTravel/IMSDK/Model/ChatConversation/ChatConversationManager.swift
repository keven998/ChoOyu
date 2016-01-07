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
        getConversationList()
    }
    
    func getConversationList() -> NSArray {
        if conversationList.count < 1 {
            self.updateConversationListFromDB()
        }
        self.reorderConversationList()
        return conversationList
    }
    
    func updateConversationListFromDB() {
        let daoHelper = DaoHelper.shareInstance()
        conversationList = daoHelper.getAllConversationList()
        self.setUpDefaultConversation()
        self.reorderConversationList()
        self.updateAllConversationStatusFromServer()
    }
    
    func updateAllConversationStatusFromServer() {
        let imClientManager = IMClientManager.shareInstance()
        let url = "\(HedyUserUrl)/\(imClientManager.accountId)/conversations"
        var params: Dictionary<String, String>
        if conversationList.count == 0 {
            return
        } else if conversationList.count == 1 {
            let chatterId = conversationList.first!.chatterId
            params = ["targetIds": "\(chatterId)"]
        } else {
            var str = ""
            for (index, conversation) in conversationList.enumerate() {
                if index == conversationList.count-1 {
                    str += ("\(conversation.chatterId)")
                } else {
                    str += ("\(conversation.chatterId),")
                }
                
            }
            params = ["targetIds": str]
        }
        NetworkTransportAPI.asyncGET(requestUrl: url, parameters: params, completionBlock: { (isSuccess, errorCode, retMessage) -> () in
            if isSuccess {
                let daoHelper = DaoHelper.shareInstance()
                if let array = retMessage as? NSArray {
                    for data in array {
                        if let dic = data as? NSDictionary {
                            let userId = dic.objectForKey("targetId") as! Int
                            let muted = dic.objectForKey("muted") as! Bool
                            for con in self.conversationList {
                                if con.chatterId == userId {
                                    con.isBlockMessage = muted
                                    daoHelper.updateBlockStatusInConversation(muted, userId: userId)
                                    break
                                }
                            }

                        }
                    }
                }
                
            }
        })

    }
    
    /**
    异步从服务器上取得一个会话的信息
    
    :param: chatterId
    :param: completionBlock
    :param: conversation
    */
    func asyncGetConversationInfoFromServer(chatterId chatterId: Int, completionBlock: (isSuccess: Bool, conversation: ChatConversation?) -> ()) {
        let imClientManager = IMClientManager.shareInstance()
        let url = "\(HedyUserUrl)/\(imClientManager.accountId)/conversations"
        let params = ["targetIds": "\(chatterId)"]
        NetworkTransportAPI.asyncGET(requestUrl: url, parameters: params, completionBlock: { (isSuccess, errorCode, retMessage) -> () in
            if isSuccess {
                var conversation: ChatConversation?
                if let array = retMessage as? NSArray {
                    if let objc = array.firstObject as? NSDictionary {
                        let daoHelper = DaoHelper.shareInstance()
                        conversation = ChatConversation()
                        if let conversationId = objc.objectForKey("id") as? String {
                            conversation!.conversationId = conversationId
                            daoHelper.updateConversationIdInConversation(conversation!.conversationId!, userId: conversation!.chatterId)
                        }
                        if let muted = objc.objectForKey("muted") as? Bool {
                            conversation!.isBlockMessage = muted
                            daoHelper.updateBlockStatusInConversation(conversation!.isBlockMessage, userId: conversation!.chatterId)
                        }
                    }
                }
                completionBlock(isSuccess: true, conversation: conversation)

            } else {
                completionBlock(isSuccess: false, conversation: nil)
            }
        })
    }
    
    /**
    将 conversationlist 重新排序,问问>派派>置顶>其他时间顺序
    */
    func reorderConversationList() {
        conversationList.sortInPlace { (conversation1: ChatConversation, conversation2: ChatConversation) -> Bool in
            if conversation1.isTopConversation && !conversation2.isTopConversation {
                return true
            } else if !conversation1.isTopConversation && conversation2.isTopConversation {
                return false
            } else if conversation1.lastUpdateTime == conversation2.lastUpdateTime {
                return conversation1.chatterId > conversation2.chatterId
            } else {
                return conversation1.lastUpdateTime >= conversation2.lastUpdateTime
            }
        }
    }
    
    /**
    修改会话的状态(免打扰)
    
    :param: groupId
    :param: groupState
    
    */
    func asyncChangeConversationBlockStatus(chatterId chatterId: Int, isBlock: Bool, completion: (isSuccess: Bool, errorCode: Int) -> ()) {
        if let exitConversation = self.getExistConversationInConversationList(chatterId) {
            
            let imClientManager = IMClientManager.shareInstance()
            if let conversationId = exitConversation.conversationId {
                let url = "\(HedyUserUrl)/\(imClientManager.accountId)/conversations/\(conversationId)"
                let params = ["mute": isBlock]
                NetworkTransportAPI.asyncPATCH(requstUrl: url, parameters: params, completionBlock: { (isSuccess, errorCode, retMessage) -> () in
                    if isSuccess {
                        exitConversation.isBlockMessage = isBlock
                        let daoHelper = DaoHelper.shareInstance()
                        daoHelper.updateBlockStatusInConversation(isBlock, userId: chatterId)
                    }
                    completion(isSuccess: isSuccess, errorCode: errorCode)
                })
                
            } else {
                let url = "\(HedyUserUrl)/\(imClientManager.accountId)/conversations/\(chatterId)"
                let params = ["mute": isBlock]
                NetworkTransportAPI.asyncPATCH(requstUrl: url, parameters: params, completionBlock: { (isSuccess, errorCode, retMessage) -> () in
                    if isSuccess {
                        exitConversation.isBlockMessage = isBlock
                        let daoHelper = DaoHelper.shareInstance()
                        daoHelper.updateBlockStatusInConversation(isBlock, userId: chatterId)
                    }
                    completion(isSuccess: isSuccess, errorCode: errorCode)
                })
            }

        }
    }

    /**
    新建会话, 会话的 用户 id
    */
    func createNewConversation(chatterId chatterId: Int, chatType: IMChatType) -> ChatConversation {
        let exitConversation = ChatConversation()
        exitConversation.chatterId = chatterId
        self.asyncGetConversationInfoFromServer(chatterId: chatterId) { (isSuccess, conversation) -> () in
            if isSuccess {
                if let con = conversation {
                    exitConversation.conversationId = con.conversationId
                    exitConversation.isBlockMessage = con.isBlockMessage
                }
            }
        }
        let time = NSDate().timeIntervalSince1970
        let timeInt: Int = Int(round(time))
        exitConversation.lastUpdateTime = timeInt
        exitConversation.chatType = chatType
        let frendManager = IMClientManager.shareInstance().frendManager
    
        if let frend = frendManager.getFrendInfoFromDB(userId: chatterId) {
            //如果此联系人的属性为屏蔽消息，则不添加新的会话
            if !FrendModel.typeIsCorrect(frend.type, typeWeight: IMFrendWeightType.BlackList) {
                self.fillConversationWithFrendData(exitConversation, frendModel: frend)
                addConversation(exitConversation)
            }
            
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
    func createNewConversation(message message: BaseMessage) -> ChatConversation {
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
        let conversation = self.createNewConversation(chatterId: chatterId, chatType: chatType)
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
        let daoHelper = DaoHelper.shareInstance()
        daoHelper.addConversation(conversation)
        self.conversationList.append(conversation)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.delegate?.conversationsHaveAdded(self.conversationList)
        })
    }
    
    /**
    移除一个 conversation
    :param: chatterId
    :Bool: 是否成功
    */
    func removeConversation(chatterId chatterId: Int, deleteMessage: Bool) {
        let daoHelper = DaoHelper.shareInstance()
        daoHelper.removeConversationfromDB(chatterId)
        for i in 0 ..< conversationList.count {
            let conversation = conversationList[i]
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
        let paiConversation = ChatConversation()
        paiConversation.chatterId = Int(PaipaiUserId)
        paiConversation.chatterName = "派派客服";
        paiConversation.lastUpdateTime = Int(NSDate().timeIntervalSince1970)+2
        self.addConversation(paiConversation)
        
        let tradeConversation = ChatConversation()
        tradeConversation.chatterId = Int(TransactionMessageUserId)
        tradeConversation.chatterName = "交易消息";
        tradeConversation.lastUpdateTime = Int(NSDate().timeIntervalSince1970)+1
        self.addConversation(tradeConversation)
        
        let activityConversation = ChatConversation()
        activityConversation.chatterId = Int(ActivityMessageUserId)
        activityConversation.chatterName = "活动消息";
        activityConversation.lastUpdateTime = Int(NSDate().timeIntervalSince1970)
        self.addConversation(activityConversation);

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
    :param: message 处理中的消息
    */
    private func handleReceiveMessage(message: BaseMessage) {
        if let conversation = self.getConversationWithMessage(message) {
            conversation.addReceiveMessage(message)
            debug_print("conversation: \(conversation.chatterName)")
            //如果当前的 conversation 不是正在显示的，并且消息不是从另一个终端已我的身份发送的
            if !conversation.isCurrentConversation && (message.senderId != IMClientManager.shareInstance().accountId) {
                conversation.unReadMessageCount++
            }
            if (conversation.conversationId == nil && message.conversationId != nil) {
                conversation.conversationId = message.conversationId
                let daoHelper = DaoHelper.shareInstance()
                daoHelper.updateConversationIdInConversation(conversation.conversationId!, userId: conversation.chatterId)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.delegate?.conversationStatusHasChanged(conversation)
            })
            return
        }
        
        //如果在所有的已有会话里找不到这条消息的会话，那么新建一个会话并加入到会话列表里

        let conversation = createNewConversation(message: message)
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
                self.delegate?.conversationStatusHasChanged(conversation)
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
                    self.delegate?.conversationStatusHasChanged(conversation)
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










