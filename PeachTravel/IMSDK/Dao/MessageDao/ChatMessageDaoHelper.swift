//
//  ChatMessageDaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 4/14/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

protocol ChatMessageDaoHelperProtocol{
    func createChatTable(tableName: String)
    func insertChatMessage(tableName: String, message:BaseMessage)
    
    func deleteChatMessage(tableName: String, localId: Int)
    
    func deleteAllMessage(tableName: String)
    
    func insertChatMessageList(messageList: Array<BaseMessage>)
    
    func updateMessageInDB(tableName: String, message:BaseMessage)
    
    /**
    按条件获取聊天列表
    :param: fromTable    获取聊天信息的表
    :param: untilLocalId 获取到哪条localid
    :param: messageCount 需要获取的数量
    :returns: 获取到的聊天信息
    */
    func selectChatMessageList(chatterId: Int, untilLocalId: Int, messageCount: Int) -> Array<BaseMessage> 
    
    /**
    找出所有聊天列表中的最后一条会话
    :returns:
    */
    func selectAllLastServerChatMessageInDB() -> NSDictionary
    
    
    /**
    某个聊天中最后一条服务器的聊天记录
    :param: fromTable
    :returns:
    */
    func selectLastServerMessage(fromTable: String) -> BaseMessage?

    /**
    获取指定的聊天列表的最有一条
    
    :param: tableName 获取数据的表明
    
    :returns:
    */
    func selectLastLocalMessageInChatTable(tableName: NSString) -> BaseMessage?
    
    /**
    消息在数据库里是否存在
    
    :param: tableName 消息所在的表
    :param: message   消息内容
    
    :returns: true：存在     false：不存在
    */
    func messageIsExitInTable(tableName: String, message: BaseMessage) -> Bool
    
    func updateMessageContents(tableName: String, message: BaseMessage)
    
    func selectAllImageMessageInChatTable(tableName: NSString) -> Array<BaseMessage> 
    
}

class ChatMessageDaoHelper:BaseDaoHelper, ChatMessageDaoHelperProtocol {
    
    /**
    当数据库没打开的时候创建聊天表
    :param: tableName 表名
    :returns: 创建是否成功
    */
    func createChatTableWithoutOpen(tableName: String) {
        if dataBase.open() {
            self.createChatTable(tableName)
            debug_print("success createChatTableWithoutOpen")
            dataBase.close()

        } else {
            debug_print("error createChatTableWithoutOpen")
        }
    }
    
    /**
    当数据库打开的时候创建表，就不需要重新打开数据库了
    :param: tableName 表明
    :returns: 创建是否成功
    */
    func createChatTable(tableName: String) {
        
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "create table '\(tableName)' (LocalId INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, ServerId INTEGER, Status int(4), Type int(4), Message TEXT, CreateTime INTEGER, SendType int, SenderId int)"
            if (dataBase.executeUpdate(sql, withArgumentsInArray: nil)) {
                debug_print("success 执行 sql 语句：\(sql)")
            } else {
                debug_print("error 执行 sql 语句：\(sql)")
            }
        }
    }
    
    func dropChatTable(tableName: String) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "drop table '\(tableName)'"
            if (dataBase.executeUpdate(sql, withArgumentsInArray: nil)) {
                debug_print("success 执行 sql 语句：\(sql)")
            } else {
                debug_print("error 执行 sql 语句：\(sql)")
            }
        }
    }
    
    func deleteAllMessage(tableName: String) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "delete from '\(tableName)'"
            if (dataBase.executeUpdate(sql, withArgumentsInArray: nil)) {
                debug_print("success 执行 sql 语句：\(sql)")
            } else {
                debug_print("error 执行 sql 语句：\(sql)")
            }
        }
    }
    
    func deleteChatMessage(tableName: String, localId: Int) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "delete from '\(tableName)' where LocalId = ?"
            if (dataBase.executeUpdate(sql, withArgumentsInArray: [localId])) {
                debug_print("success 执行 sql 语句：\(sql)")
            } else {
                debug_print("error 执行 sql 语句：\(sql)")
            }
        }
    }
    
    /**
    插入一条聊天表数据
    :param: table 表明
    :returns: 更新是否成功
    */
    func insertChatMessage(tableName: String, message:BaseMessage) {
        if !super.tableIsExit(tableName) {
            self.createChatTable(tableName)
        }
        
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
           
            let sql = "insert into \(tableName) (ServerId, Status, Type, Message, CreateTime, SendType, SenderId) values (?,?,?,?,?,?,?)"
            let array = [message.serverId, message.status.rawValue, message.messageType.rawValue, message.message, message.createTime, message.sendType.rawValue, message.senderId]
            if dataBase.executeUpdate(sql, withArgumentsInArray:array as [AnyObject]) {
                message.localId = Int(dataBase.lastInsertRowId())
                debug_print("success 执行 sql 语句：\(sql) message:\(message.message)  serverId:\(message.serverId)")
        
            } else {
                debug_print("error 执行 sql 语句：\(sql), message:\(message.message)  serverId:\(message.serverId)")
            }
        }
    }
    
    /**
    插入一组聊天记录
    
    :param: tableName
    :param: messageList
    */
    func insertChatMessageList(messageList: Array<BaseMessage>) {
        for message in messageList {
            let tableName = "chat_\(message.chatterId)"
            self.insertChatMessage(tableName, message:message)
        }
    }
    
    /**
    更新表的 serverId
    :param: tableName 需要更新的表
    :param: message 更新内容
    */
    func updateMessageInDB(tableName: String, message:BaseMessage) {
        if !super.tableIsExit(tableName) {
            self.createChatTable(tableName)
        }
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "update \(tableName) set ServerId = ?, Status = ?  where LocalId = ?"
            if dataBase.executeUpdate(sql, withArgumentsInArray:[message.serverId, message.status.rawValue, message.localId]) {
                debug_print("success 执行 sql 语句：\(sql)")
            } else {
                debug_print("error 执行 sql 语句：\(sql)")
            }
        }
    }

    /**
    更新消息的 contents 字段
    
    :param: tableName 需要更新的表
    :param: contents 新的内容
    */
    func updateMessageContents(tableName: String, message: BaseMessage) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "update \(tableName) set Message = ? where LocalId = ?"
            if dataBase.executeUpdate(sql, withArgumentsInArray:[message.message, message.localId]) {
                debug_print("success 执行更新消息内容的 sql 语句：\(sql)")
            } else {
                debug_print("error 执行更新消息内容的 sql 语句：\(sql) message: \(message.message) serverId:\(message.serverId), localId:\(message.localId)")
            }
        }
    }
    
    func selectChatMessageList(chatterId: Int, untilLocalId: Int, messageCount: Int) -> Array<BaseMessage> {
        var retArray = Array<BaseMessage>()
        
        let tableName = "chat_\(chatterId)"

        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "select * from (select * from \(tableName) where LocalId < ? order by LocalId desc limit \(messageCount)) order by LocalId"
            debug_print("执行 sql 语句 : \(sql)")
            let rs = dataBase.executeQuery(sql, withArgumentsInArray: [untilLocalId, messageCount])
            if (rs != nil) {
                while rs.next() {
                    if let message = ChatMessageDaoHelper.messageModelWithFMResultSet(rs, tableName: tableName) {
                        message.chatterId = chatterId
                        retArray.append(message)
                    }
                }
            }
        }
        return retArray
    }
    
    /**
    消息在数据库里是否存在
    
    :param: tableName 消息所在的表
    :param: message   消息内容
    
    :returns: true：存在     false：不存在
    */
    func messageIsExitInTable(tableName: String, message: BaseMessage) -> Bool {
        
        var retResult: Bool = false
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "select * from \(tableName) where serverId = ?"
            let rs = dataBase.executeQuery(sql, withArgumentsInArray: [message.serverId])
            if (rs != nil) {
                while rs.next() {
                    retResult = true
                }
            }
        }
        return retResult
    }
    
    /**
    取到最后一条与服务器同步的消息
    :param: fromTable
    :returns:
    */
    func selectLastServerMessage(fromTable: String) -> BaseMessage? {
        var retMessage: BaseMessage?
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "select * from \(fromTable) where serverId > 0 order by LocalId desc limit 1"
            let rs = dataBase.executeQuery(sql, withArgumentsInArray: nil)
            if (rs != nil) {
                while rs.next() {
                    retMessage = ChatMessageDaoHelper.messageModelWithFMResultSet(rs, tableName: fromTable)
                }
            }
        }
        return retMessage
    }
    
    /**
    获取所有的聊天列表里的最后一条消息
    :returns:
    */
    func selectAllLastServerChatMessageInDB() -> NSDictionary {
        let retDic = NSMutableDictionary()
        let allTables = super.selectAllTableName(keyWord: "chat")
        for tableName in allTables {
            let message = self.selectLastServerMessage(tableName as! String)
            if let message = message {
                retDic.setObject(message.serverId, forKey: message.chatterId)
            }
        }
        return retDic
    }
    
    /**
    获取指定的聊天列表里的最后一条消息
    :returns:
    */
    func selectLastLocalMessageInChatTable(tableName: NSString) -> BaseMessage? {
        var retMessage: BaseMessage?
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            
            let sql = "select * from \(tableName) order by LocalId desc limit 1"
            let rs = dataBase.executeQuery(sql, withArgumentsInArray: nil)
            if (rs != nil) {
                while rs.next() {
                    retMessage = ChatMessageDaoHelper.messageModelWithFMResultSet(rs, tableName: tableName)
                }
            }
        }
        return retMessage
    }
    
//MARK: 获取所有的图片消息
    func selectAllImageMessageInChatTable(tableName: NSString) -> Array<BaseMessage> {
        var imageMessageArray = Array<BaseMessage>()
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            
            let sql = "select * from \(tableName) where type = 2"
            let rs = dataBase.executeQuery(sql, withArgumentsInArray: nil)
            if (rs != nil) {
                while rs.next() {
                    if let retMessage = ChatMessageDaoHelper.messageModelWithFMResultSet(rs, tableName: tableName) {
                        imageMessageArray.append(retMessage)
                    }
                }
            }
        }
        return imageMessageArray
    }
    
    
//MARK: class methods
    
    /**
    将数据库的查询结果转为 messagemodel
    :param: rs 数据库查询结果
    :returns: 转换的message model
    */
    class func messageModelWithFMResultSet(rs: FMResultSet, tableName: NSString) -> BaseMessage? {
        var retMessage: BaseMessage?
        if let messageType = IMMessageType(rawValue: Int(rs.intForColumn("Type"))) {
            switch messageType {
            case .TextMessageType:
                retMessage = TextMessage()
                retMessage?.message = rs.stringForColumn("Message")
                
            case .AudioMessageType:
                retMessage = AudioMessage()
                
            case .ImageMessageType:
                retMessage = ImageMessage()
                
            case .LocationMessageType:
                retMessage = LocationMessage()
                
            case .CityPoiMessageType:
                retMessage = IMCityMessage()
                
            case .SpotMessageType:
                retMessage = IMSpotMessage()
                
            case .GuideMessageType:
                retMessage = IMGuideMessage()
                
            case .TravelNoteMessageType:
                retMessage = IMTravelNoteMessage()
                
            case .RestaurantMessageType:
                retMessage = IMRestaurantMessage()
                
            case .ShoppingMessageType:
                retMessage = IMShoppingMessage()
                
            case .HotelMessageType:
                retMessage = IMHotelMessage()
                
            case .CMDMessageType:
                retMessage = IMCMDMessage()
                
            case .TipsMessageType:
                retMessage = TipsMessage()
                
            case .QuestionMessageType:
                retMessage = QuestionMessage()
                
            case .Html5MessageType:
                retMessage = HtmlMessage()
                
            case .GoodsMessageType:
                break
                
            case .GoodsLinkMessageType:
                break
                
            case .OrderTipsMessageType:
                retMessage = OrderTipsMessage()
            }
            
            //attention: 因为表明的结构为 chat_100。所以从第五位取可以取到 chatterid
            let chatterIdStr = tableName.substringFromIndex(5)
            retMessage?.chatterId = Int(chatterIdStr)!

            let contents = rs.stringForColumn("Message")
            retMessage?.fillContentWithContent(contents)
            
            retMessage?.message = contents
            
            retMessage?.senderId  = Int(rs.intForColumn("SenderId"))
            retMessage?.sendType = IMMessageSendType(rawValue: Int(rs.intForColumn("SendType")))!
            retMessage?.createTime = Int(rs.intForColumn("CreateTime"))
            retMessage?.localId = Int(rs.intForColumn("LocalId"))
            retMessage?.serverId = Int(rs.intForColumn("ServerId"))
            if let status = IMMessageStatus(rawValue: Int(rs.intForColumn("status"))) {
                if status == IMMessageStatus.IMMessageSending {
                    let imClientMessage = IMClientManager.shareInstance()
                    if !imClientMessage.messageSendManager.messageIsReallySending(retMessage!) {
                        retMessage?.status = IMMessageStatus.IMMessageFailed
                        let daoHelper = DaoHelper.shareInstance()
                        daoHelper.updateMessageInDB(tableName as String, message: retMessage!)
                    } else {
                        retMessage?.status = status
                    }
                } else {
                    retMessage?.status = status
                }
            }
        }
        return retMessage
    }
}


















