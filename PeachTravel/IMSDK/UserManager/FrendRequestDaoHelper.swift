//
//  FrendRequestDaoHelper.swift
//  PeachTravel
//
//  Created by liangpengshuai on 6/30/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

let frendRequestTableName = "FrendRequest"

class FrendRequestDaoHelper: BaseDaoHelper {
    
    func createFrendTable() {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "create table '\(frendRequestTableName)' (UserId INTEGER PRIMARY KEY NOT NULL, NickName TEXT, Avatar Text, Status INTEGER, Sex INTEGER, Date Double, Message: Text)"
            if (dataBase.executeUpdate(sql, withArgumentsInArray: nil)) {
                println("success 执行 sql 语句：\(sql)")
                
            } else {
                println("error 执行 sql 语句：\(sql)")
            }
        }
    }
    
    func getAllFrendRequest() -> Array<FrendRequest> {
        var retArray = Array<FrendRequest>()
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "select * from \(frendRequestTableName)"
            var rs = dataBase.executeQuery(sql, withArgumentsInArray: nil)
            if (rs != nil) {
                while rs.next() {
                    retArray.append(self.fillFrendRequestModelWithFMResultSet(rs))
                }
            }
        }
        return retArray
    }
    
    func addFrendRequestion2DB(request: FrendRequest) {
        if !super.tableIsExit(frendRequestTableName) {
            createFrendTable()
        }
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "insert into \(frendTableName) (UserId, NickName, Avatar, Status, Sex, Date, Message) values (?,?,?,?,?,?,?)"
            println("执行 sql 语句：\(sql)")
            var array = [request.userId, request.nickName, request.status.rawValue, request.avatar, request.gender.rawValue, request.requestDate, request.attachMsg]
            dataBase.executeUpdate(sql, withArgumentsInArray: array as [AnyObject])
        }
    }
    
    func removeFrendRequest(userId: Int) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "delete from \(frendRequestTableName) where UserId = ?"
            if dataBase.executeUpdate(sql, withArgumentsInArray: [userId]) {
                println("执行 deleteAllContactsFromDB 语句 成功")
            } else {
                println("执行 deleteAllContactsFromDB 语句 失败")
                
            }
        }
    }
    
    func changeFrendRequestStatus(userId: Int, status: TZFrendRequest) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "update \(frendRequestTableName) set Status = ? where UserId = ?"
            println("执行 sql 语句：\(sql)")
            var array = [status.rawValue, userId]
            dataBase.executeUpdate(sql, withArgumentsInArray: array as [AnyObject])
        }
    }
    
    //MARK: private methods
    private func fillFrendRequestModelWithFMResultSet(rs: FMResultSet) -> FrendRequest {
        var frend = FrendRequest()
        frend.userId = Int(rs.intForColumn("UserId"))
        frend.nickName = rs.stringForColumn("NickName")
        frend.avatar = rs.stringForColumn("Avatar")
        frend.gender = UserGender(rawValue: Int(rs.intForColumn("Sex")))!
        frend.status = TZFrendRequest(rawValue: Int(rs.intForColumn("Status")))!
        frend.attachMsg = rs.stringForColumn("Message")
        return frend
    }
}



