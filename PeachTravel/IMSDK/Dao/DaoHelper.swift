//
//  DaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 4/14/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//   数据库的一些操作

import UIKit

private let daoHelper = DaoHelper()

let documentPath: String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] 
let tempDirectory: String = NSTemporaryDirectory()

let databaseWriteQueue = dispatch_queue_create("com.database.write", nil)

public class DaoHelper:NSObject {
    private var db: FMDatabase
    private var chatMessageDaoHelper: ChatMessageDaoHelper
    private var metaDataDaoHelper: MetaDataDaoHelper

    private var conversationHelper: ConversationDaoHelper
    private var dbQueue: FMDatabaseQueue
    
    class func shareInstance() -> DaoHelper {
        return daoHelper
    }
    
    override init() {
        var userId = -1
        if let account = AccountManager.shareAccountManager().account {
            userId = account.userId
        }
        
        let dbPath: String = documentPath.stringByAppendingString("/\(userId)/user.sqlite")
        
        debug_print("dbPath: \(dbPath)")
        
        // 创建文件路径
        let fileManager =  NSFileManager()
        
        if !fileManager.fileExistsAtPath(dbPath) {
            let directryPath = documentPath.stringByAppendingString("/\(userId)")
            do {
                try fileManager.createDirectoryAtPath(directryPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                
            }
        }
        
        db = FMDatabase(path: dbPath)
        dbQueue = FMDatabaseQueue(path: dbPath)
        
        chatMessageDaoHelper = ChatMessageDaoHelper(db: db, dbQueue: dbQueue)
        metaDataDaoHelper = MetaDataDaoHelper(db: db)
        conversationHelper = ConversationDaoHelper(db: db, dbQueue: dbQueue)

        super.init()
    }
    
    func setupDatabase() {
        self.fillDatabase()
    }
    
    func fillDatabase() {
        var userId = -1
        if let account = AccountManager.shareAccountManager().account {
            userId = account.userId
        }
        
        let dbPath: String = documentPath.stringByAppendingString("/\(userId)/user.sqlite")
        
        debug_print("dbPath: \(dbPath)")
        
        let fileManager =  NSFileManager()
        
        if !fileManager.fileExistsAtPath(dbPath) {
            let directryPath = documentPath.stringByAppendingString("/\(userId)")
            do {
                try fileManager.createDirectoryAtPath(directryPath, withIntermediateDirectories: true, attributes: nil)
                
            } catch {
                
            }
        }
        
        db = FMDatabase(path: dbPath)
        dbQueue = FMDatabaseQueue(path: dbPath)
        
        chatMessageDaoHelper = ChatMessageDaoHelper(db: db, dbQueue: dbQueue)
        metaDataDaoHelper = MetaDataDaoHelper(db: db)
        conversationHelper = ConversationDaoHelper(db: db, dbQueue: dbQueue)
    }
    
    private func openDB() -> Bool {
        return db.open()
    }
    
    private func closeDB() -> Bool {
        return db.close()
    }
    
    //MARK:ChatMessageDaoHelperProtocol
    
    func createChatTable(tableName: String) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.chatMessageDaoHelper.createChatTable(tableName)
        })
    }
    
    func createAudioMessageTable(tableName: String) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.metaDataDaoHelper.createAudioMessageTable(tableName)
        })
    }
    
    func deleteChatMessage(tableName: String, localId: Int) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.chatMessageDaoHelper.deleteChatMessage(tableName, localId: localId)
        })
    }
    
    func delteAllMessageInDB(tableName: String) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.chatMessageDaoHelper.deleteAllMessage(tableName)
        })
    }
    
    func dropMessageTable(tableName: String) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.chatMessageDaoHelper.dropChatTable(tableName)
        })
    }
    
    func insertChatMessage(tableName: String, message:BaseMessage) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.chatMessageDaoHelper.insertChatMessage(tableName, message:message)
        })
    }
    
    func insertChatMessageList(messageList: Array<BaseMessage>, completionBlock:()->()) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.openDB()
            self.chatMessageDaoHelper.insertChatMessageList(messageList)
            self.closeDB()
            completionBlock()
        })
    }
    
    func updateMessageInDB(tableName: String, message:BaseMessage) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.openDB()
            self.chatMessageDaoHelper.updateMessageInDB(tableName, message: message)
            self.closeDB()
        })
    }
    
    func selectChatMessageList(chatterId: Int, untilLocalId: Int, messageCount: Int) -> Array<BaseMessage> {
        return chatMessageDaoHelper.selectChatMessageList(chatterId, untilLocalId: untilLocalId, messageCount: messageCount)
    }
    
    func selectLastServerMessage(fromTable: String) -> BaseMessage? {
        if self.openDB() {
            let result = chatMessageDaoHelper.selectLastServerMessage(fromTable)
            self.closeDB()
            return result
        }
        return nil
    }
    
    func selectLastLocalMessageInChatTable(tableName: NSString) -> BaseMessage? {
        if self.openDB() {
            let result = chatMessageDaoHelper.selectLastLocalMessageInChatTable(tableName)
            self.closeDB()
            return result
        }
        return nil
    }
    
    func selectAllLastServerChatMessageInDB() -> NSDictionary {
        if self.openDB() {
            let result =  chatMessageDaoHelper.selectAllLastServerChatMessageInDB()
            self.closeDB()
            return result
            
        } else {
            return NSDictionary()
        }
    }

    /**
    消息在数据库里是否存在
    
    :param: tableName 消息所在的表
    :param: message   消息内容
    
    :returns: true：存在     false：不存在
    */
    func messageIsExitInTable(tableName: String, message: BaseMessage) -> Bool {
        if self.openDB() {
            let result = chatMessageDaoHelper.messageIsExitInTable(tableName, message: message)
            self.closeDB()
            return result

        } else {
            return false
        }
    }
    
    func updateMessageContents(tableName: String, message: BaseMessage) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.chatMessageDaoHelper.updateMessageContents(tableName, message: message)
        })
    }
    
    func getAllImageMessageInChatTable(tableName: NSString) -> Array<BaseMessage> {
        return self.chatMessageDaoHelper.selectAllImageMessageInChatTable(tableName)
    }

    //MARK: ConversationDaoProtocol
    func createConversationsTable() {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.openDB()
            self.conversationHelper.createConversationsTable()
            self.closeDB()

        })
    }
    
    func addConversation(conversation :ChatConversation) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.conversationHelper.addConversation(conversation)
        })

    }
    
    func updateBlockStatusInConversation(isBlock: Bool, userId: Int) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.conversationHelper.updateBlockStatusInConversation(isBlock, userId: userId)
        })
    }
    
    func updateTopStatusInConversation(isTopConversation: Bool, userId: Int) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.conversationHelper.updateTopStatusInConversation(isTopConversation, userId: userId)
        })
    }
    
    func getAllConversationList() -> Array<ChatConversation> {
        let retArray = conversationHelper.getAllCoversation()
        return retArray
    }
    
    func removeConversationfromDB(chatterId: Int) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.conversationHelper.removeConversationfromDB(chatterId)
        })
    }
    
    func updateUnreadMessageCountInConversation(unReadMessageCount: Int, userId: Int) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.conversationHelper.updateUnreadMessageCountInConversation(unReadMessageCount, chatterId: userId)
        })
    }
    
    func updateTimestampInConversation(timeStamp: Int, userId: Int) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.conversationHelper.updateTimestampInConversation(timeStamp, userId: userId)
        })
    }
    
    func updateConversationIdInConversation(conversationId: String, userId: Int) {
        dispatch_async(databaseWriteQueue, { () -> Void in
            self.conversationHelper.updateConversationIdInConversation(conversationId, userId: userId)
        })

    }
    
}

