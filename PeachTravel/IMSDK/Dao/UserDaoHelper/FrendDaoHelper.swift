//
//  UserDaoHelper.swift
//  TZIM
//
//  Created by liangpengshuai on 4/20/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

let frendTableName = "Frend"

protocol FrendDaoProtocol {
    
    /**
    创建好友表
    :returns:
    */
    func createFrendTable()
    
    /**
    删除好友表
    :returns: 
    */
    func deleteFrendTable()
    
    /**
    添加一个联系人到数据库里
    :param: frend
    :returns:
    */
    func addFrend2DB(frend: FrendModel)
    
    /**
    获取所有的是我的好友的列表
    :returns:
    */
    func selectAllContacts() -> Array<FrendModel>
    
    /**
    frend是否在数据库里存在
    :param: userId
    :returns:
    */
    func frendIsExitInDB(userId: Int) -> Bool
    
    /**
    获取我所有的群组列表
    
    :returns:
    */
    func selectAllGroup() -> Array<IMGroupModel>
    
    /**
    通过 userId 来获取 frend
    
    :param: userId
    
    :returns:
    */
    func selectFrend(#userId: Int) -> FrendModel?
    
    /**
    更新好友类型
    
    :param: userId
    :param: type
    */
    func updateFrendType(#userId: Int, type: IMFrendType)
}

class FrendDaoHelper: BaseDaoHelper, FrendDaoProtocol {
    
    /**
    创建 frend 表，frend 表存的是所有好友和非好友的人。利用 type 来区分类型
    :returns:
    */
    
    class func createFrendTable(DB: FMDatabase) -> Bool {
        
        var sql = "create table '\(frendTableName)' (UserId INTEGER PRIMARY KEY NOT NULL, NickName TEXT, Avatar Text, AvatarSmall Text, ShortPY Text, FullPY Text, Signature Text, Memo Text, Sex INTEGER, Type INTEGER, ExtData Text)"
        if (DB.executeUpdate(sql, withArgumentsInArray: nil)) {
            println("执行 sql 语句：\(sql)")
            return true
        }
        return false
    }
    
    func createFrendTable() {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "create table '\(frendTableName)' (UserId INTEGER PRIMARY KEY NOT NULL, NickName TEXT, Avatar Text, AvatarSmall Text, ShortPY Text, FullPY Text, Signature Text, Memo Text, Sex INTEGER, Type INTEGER, ExtData Text)"
            if (dataBase.executeUpdate(sql, withArgumentsInArray: nil)) {
                println("success 执行 sql 语句：\(sql)")
                
            } else {
                println("error 执行 sql 语句：\(sql)")
            }
        }
    }
    
    func deleteFrendTable() {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in

            var sql = "drop table Frend"
            dataBase.executeUpdate(sql, withArgumentsInArray: nil)
        }
    }
    
    func addFrend2DB(frend: FrendModel) {
        if !super.tableIsExit(frendTableName) {
            createFrendTable()
        }
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in

            var sql = "insert or replace into \(frendTableName) (UserId, NickName, Avatar, AvatarSmall, ShortPY, FullPY, Signature, Memo, Sex, Type, ExtData) values (?,?,?,?,?,?,?,?,?,?,?)"
            println("执行 sql 语句：\(sql)")
            var array = [frend.userId, frend.nickName, frend.avatar, frend.avatarSmall, frend.shortPY, frend.fullPY, frend.signature, frend.memo, frend.sex, frend.type.rawValue, frend.extData]
            dataBase.executeUpdate(sql, withArgumentsInArray: array as [AnyObject])
        }
    }
    
    func selectFrend(#userId: Int) -> FrendModel? {
        var frend: FrendModel?
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "select * from \(frendTableName) where UserId = ?"
            var rs = dataBase.executeQuery(sql, withArgumentsInArray: [userId])
            if (rs != nil) {
                while rs.next() {
                    frend = self.fillFrendModelWithFMResultSet(rs)
                }
            }
        }
        return frend
    }
    
    /**
    获取所有的是我的好友的列表
    :returns:
    */
    func selectAllContacts() -> Array<FrendModel> {
        var retArray = Array<FrendModel>()
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "select * from \(frendTableName) where Type = ? or Type = ? or Type = ? or Type = ?"
            var rs = dataBase.executeQuery(sql, withArgumentsInArray: [IMFrendType.Frend.rawValue, IMFrendType.ChatTop_Frend.rawValue, IMFrendType.Frend_Business.rawValue, IMFrendType.Frend_Expert.rawValue])
            if (rs != nil) {
                while rs.next() {
                    retArray.append(self.fillFrendModelWithFMResultSet(rs))
                }
            }
        }
        return retArray
    }
    
    func deleteAllContactsFromDB() {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "delete from \(frendTableName) where Type = ? or Type = ? or Type = ? or Type = ?"
            if dataBase.executeUpdate(sql, withArgumentsInArray: [IMFrendType.Frend.rawValue, IMFrendType.ChatTop_Frend.rawValue, IMFrendType.Frend_Business.rawValue, IMFrendType.Frend_Expert.rawValue]) {
                println("执行 deleteAllContactsFromDB 语句 成功")
            } else {
                println("执行 deleteAllContactsFromDB 语句 失败")

            }
        }
    }
    
    /**
    好友是否是在数据库里已经存在
    :param: userId
    :returns:
    */
    func frendIsExitInDB(userId: Int) -> Bool {
        var sql = "select * from \(frendTableName) where UserId = ?"
        var rs = dataBase.executeQuery(sql, withArgumentsInArray: [userId])
        if (rs != nil) {
            while rs.next() {
               return true
            }
        }
        return false
    }
    
    
//MARK: private methods
    private func fillFrendModelWithFMResultSet(rs: FMResultSet) -> FrendModel {
        var frend = FrendModel()
        frend.userId = Int(rs.intForColumn("UserId"))
        frend.nickName = rs.stringForColumn("NickName")
        frend.avatar = rs.stringForColumn("Avatar")
        frend.avatarSmall = rs.stringForColumn("AvatarSmall")
        frend.signature = rs.stringForColumn("Signature")
        frend.sex = String(rs.intForColumn("Sex"))
        frend.fullPY = rs.stringForColumn("FullPY")
        frend.type = IMFrendType(rawValue: Int(rs.intForColumn("Type")))!
        frend.memo = rs.stringForColumn("memo")
        if let data = rs.stringForColumn("ExtData") {
            frend.extData = data
        }
        return frend
    }
    
//MARK: Group
    
    /**
    获取所有的是我的群组 的列表
    :returns:
    */
    func selectAllGroup() -> Array<IMGroupModel> {
        var retArray = Array<IMGroupModel>()
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "select * from \(frendTableName) where Type = ?"
            var rs = dataBase.executeQuery(sql, withArgumentsInArray: [IMFrendType.Group.rawValue])
            if (rs != nil) {
                while rs.next() {
                    var group = IMGroupModel()
                    group.groupId = Int(rs.intForColumn("UserId"))
                    group.subject = rs.stringForColumn("NickName")
                    group.conversationId = rs.stringForColumn("ConversationId")
                    retArray.append(group)
                }
            }
        }
        return retArray
    }
    
    func updateFrendType(#userId: Int, type: IMFrendType) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            
            var sql = "update \(frendTableName) set Type = ? where UserId = ?"
            println("执行 sql 语句：\(sql)")
            var array = [type.rawValue, userId]
            dataBase.executeUpdate(sql, withArgumentsInArray: array as [AnyObject])
        }
    }

}





