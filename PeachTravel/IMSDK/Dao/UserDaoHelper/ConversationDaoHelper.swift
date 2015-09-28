//
//  ConversationDaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.

import UIKit

private let conversationTableName = "ConversationList"

protocol ConversationDaoProtocol {
    /**
    创建FrendMeta表，用于存放聊天列表信息
    :returns:
    */
    func createConversationsTable();
    
    /**
    添加一条记录会话列表记录
    :param: userId 会话列表 id
    :param: lastUpdateTime 会话列表最后一次更新的时间
    */
    func addConversation(conversation :ChatConversation)
    
    /**
    获取所有的聊天会话列表
    :returns:
    */
    func getAllCoversation() -> Array<ChatConversation>
    
    /**
    移除一个 conversation
    :param: chatterId 需要移除的 ID
    :returns: 移除是否成功
    */
    func removeConversationfromDB(chatterId: Int)
    
    /**
    更新某个会话的未读消息的数量
    
    :param: conversation
    */
    func updateUnreadMessageCountInConversation(unReadMessageCount: Int, chatterId: Int)
    
    /**
    更新会话的时间戳
    
    :param: timeStamp
    :param: userId    
    */
    func updateTimestampInConversation(timeStamp: Int, userId: Int)
    
    /**
    更新会话的会话 id
    
    :param: conversationId
    :param: userId         
    */
    func updateConversationIdInConversation(conversationId: String, userId: Int)

}

class ConversationDaoHelper: BaseDaoHelper, ConversationDaoProtocol {
    
    override init(db: FMDatabase, dbQueue: FMDatabaseQueue) {
        super.init(db: db, dbQueue: dbQueue)
        
    }
    
    //MARK: *******  ConversationDaoProtocol  ******

    /**
    从会话列表数据库里获取所有的会话列表,按照时间逆序排列
    :returns: 包含所有会话列表
    */
    func getAllCoversation() -> Array<ChatConversation> {
        var retArray = Array<ChatConversation>()
        
        if !super.tableIsExit(conversationTableName) {
            self.createConversationsTable()
        }
        if !super.tableIsExit(frendTableName) {
            FrendDaoHelper.createFrendTable(dataBase)
        }
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
          
            let sql = "select * from \(conversationTableName) left join \(frendTableName) on \(conversationTableName).ChatterId = \(frendTableName).UserId order by LastUpdateTime DESC"
            let rs = dataBase.executeQuery(sql, withArgumentsInArray: nil)
            if rs != nil {
                while rs.next() {
                    //如果是取的 cmd 的会话，直接 pass 掉
                    if Int(rs.intForColumn("ChatterId")) == 0 {
                        return
                    }
                    let conversation = ChatConversation()
                    conversation.chatterId = Int(rs.intForColumn("ChatterId"))
                    conversation.lastUpdateTime = Int(rs.longForColumn("LastUpdateTime"))
                    conversation.isBlockMessage = Bool(rs.boolForColumn("isBlockMessage"))
                    conversation.isTopConversation = Bool(rs.boolForColumn("isTopConversation"))

                    if let memoStr = rs.stringForColumn("Memo") {
                        if memoStr != "" {
                            conversation.chatterName = memoStr
                        } else {
                            if let chatterName = rs.stringForColumn("NickName") {
                               conversation.chatterName = chatterName
                            } else {
                                conversation.chatterName = "\(conversation.chatterId)"
                            }
                        }
                        
                    } else if let chatterName = rs.stringForColumn("NickName") {
                        conversation.chatterName = chatterName

                    } else {
                        conversation.chatterName = "\(conversation.chatterId)"
                    }
                    if let avatarSmall = rs.stringForColumn("AvatarSmall") {
                        if avatarSmall != "" {
                            conversation.chatterAvatar = avatarSmall
                            
                        } else {
                            conversation.chatterAvatar = rs.stringForColumn("Avatar")
                        }
                    } else {
                        conversation.chatterAvatar = rs.stringForColumn("Avatar")
                    }

                    let typeValue  = rs.intForColumn("Type")
                    conversation.fillConversationType(frendType: IMFrendType(rawValue: Int(typeValue))!)
                    conversation.unReadMessageCount = Int(rs.intForColumn("UnreadMessageCount"))
                    if let conversationId = rs.stringForColumn("ConversationId") {
                        conversation.conversationId = String(conversationId)
                    }

                    retArray.append(conversation)
                }
            }
        }
        return retArray
    }
    
    /**
    创建一个会话表
    :returns:
    */
    func createConversationsTable() {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in

            let sql = "create table '\(conversationTableName)' (ChatterId INTEGER PRIMARY KEY NOT NULL, LastUpdateTime INTEGER, ConversationId String, UnreadMessageCount INTEGER, isBlockMessage BOOL, isTopConversation BOOL)"
            
            if (dataBase.executeUpdate(sql, withArgumentsInArray: nil)) {
                debug_print("success 执行 sql 语句：\(sql)")
            } else {
                debug_print("error 执行 sql 语句：\(sql)")
                
            }
        }
    }
    
    /**
    添加一个会话
    :param: userId         会话的 chatter ID
    :param: lastUpdateTime 最后一次更新的时间
    */
    func addConversation(conversation :ChatConversation) {
        if !self.tableIsExit(conversationTableName) {
            self.createConversationsTable()
        }
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in

            if let conversationId = conversation.conversationId {
                let sql = "insert into \(conversationTableName) (ChatterId, LastUpdateTime, ConversationId, isBlockMessage, isTopConversation) values (?,?,?,?,?)"
                debug_print("执行 addConversation userId: \(conversation.chatterId)")
                let array = [conversation.chatterId, conversation.lastUpdateTime, conversationId, conversation.isBlockMessage, conversation.isTopConversation]
                if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
                    debug_print("success 执行 sql 语句：\(sql)")
                    
                } else {
                    debug_print("error 执行 sql 语句：\(sql)")
                }
                
            } else {
                let sql = "insert into \(conversationTableName) (ChatterId, LastUpdateTime) values (?,?)"
                debug_print("执行 addConversation userId: \(conversation.chatterId)")
                let array = [conversation.chatterId, conversation.lastUpdateTime, conversation.isBlockMessage, conversation.isTopConversation]
                if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
                    debug_print("success 执行 sql 语句：\(sql)")
                    
                } else {
                    debug_print("error 执行 sql 语句：\(sql)")
                    
                }
            }
        }
    }
    
    func updateUnreadMessageCountInConversation(unReadMessageCount: Int, chatterId: Int) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "update \(conversationTableName) set UnreadMessageCount = ? where ChatterId = ?"
            debug_print("执行 updateUnreadMessageCountInConversation chatterId: \(chatterId)")
            let array = [unReadMessageCount, chatterId]
            if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
                debug_print("success 执行 sql 语句：\(sql)")
                
            } else {
                debug_print("error 执行 sql 语句：\(sql)")
            }
        }
    }
    
    func updateTimestampInConversation(timeStamp: Int, userId: Int) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "update \(conversationTableName) set LastUpdateTime = ? where ChatterId = ?"
            debug_print("执行 updateTimestampInConversation userId: \(userId)")
            let array = [timeStamp, userId]
            if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
                debug_print("success 执行 sql 语句：\(sql)")
            } else {
                debug_print("error 执行 sql 语句：\(sql)")
            }
        }
    }
    
    /**
    更新会话的免打扰状态
    
    :param: isBlock
    :param: userId
    */
    func updateBlockStatusInConversation(isBlock: Bool, userId: Int) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "update \(conversationTableName) set isBlockMessage = ? where ChatterId = ?"
            debug_print("执行 update isBlockMessage: \(isBlock)")
            let array = [isBlock, userId]
            if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
                debug_print("success 执行 sql 语句：\(sql)")
            } else {
                debug_print("error 执行 sql 语句：\(sql)")
            }
        }
    }
    
    /**
    更新会话的置顶状态
    
    :param: isTopConversation
    :param: userId            
    */
    func updateTopStatusInConversation(isTopConversation: Bool, userId: Int) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "update \(conversationTableName) set isTopConversation = ? where ChatterId = ?"
            debug_print("执行 update isTopConversation: \(isTopConversation)")
            let array = [isTopConversation, userId]
            if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
                debug_print("success 执行 sql 语句：\(sql)")
            } else {
                debug_print("error 执行 sql 语句：\(sql)")
            }
        }
    }

    func updateConversationIdInConversation(conversationId: String, userId: Int) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "update \(conversationTableName) set ConversationId = ? where ChatterId = ?"
            debug_print("执行 updateConversationIdInConversation userId: \(userId)")
            let array = [conversationId, userId]
            if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
                debug_print("success 执行 sql 语句：\(sql)")
                
            } else {
                debug_print("error 执行 sql 语句：\(sql)")
            }
        }
    }
    
    func removeConversationfromDB(chatterId: Int) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "delete from \(conversationTableName) where ChatterId = ?"
            if dataBase.executeUpdate(sql, withArgumentsInArray: [chatterId]) {
                debug_print("success 执行 sql 语句：\(sql)")
            } else {
                debug_print("error 执行 sql 语句：\(sql)")
            }
        }
    }
    
    
}
