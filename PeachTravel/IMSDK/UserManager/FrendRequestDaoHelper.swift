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
    
    func createFrendRequestTable() {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "create table '\(frendRequestTableName)' (RequestId TEXT PRIMARY KEY NOT NULL, UserId INTEGER, NickName TEXT, Avatar Text, Status INTEGER, Sex INTEGER, Date Double, Message Text)"
            if (dataBase.executeUpdate(sql, withArgumentsInArray: nil)) {
                debug_print("success 执行 sql 语句：\(sql)")
                
            } else {
                debug_print("error 执行 sql 语句：\(sql)")
            }
        }
    }
    
    func getAllFrendRequest() -> Array<FrendRequest> {
        var retArray = Array<FrendRequest>()
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "select * from \(frendRequestTableName)"
            let rs = dataBase.executeQuery(sql, withArgumentsInArray: nil)
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
            createFrendRequestTable()
        }
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "insert into \(frendRequestTableName) (RequestId, UserId, NickName, Avatar, Status, Sex, Date, Message) values (?,?,?,?,?,?,?,?)"
            debug_print("执行 sql 语句：\(sql)")
            let array = [request.requestId, request.userId, request.nickName, request.avatar, request.status.rawValue, request.gender.rawValue, request.requestDate, request.attachMsg]
            dataBase.executeUpdate(sql, withArgumentsInArray: array as [AnyObject])
        }
    }
    
    func removeFrendRequest(requestId: String) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "delete from \(frendRequestTableName) where RequestId = ?"
            if dataBase.executeUpdate(sql, withArgumentsInArray: [requestId]) {
                debug_print("执行 deleteAllContactsFromDB 语句 成功")
            } else {
                debug_print("执行 deleteAllContactsFromDB 语句 失败")
                
            }
        }
    }
    
    func changeFrendRequestStatus(requestId: String, status: TZFrendRequest) {
        databaseQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "update \(frendRequestTableName) set Status = ? where RequestId = ?"
            debug_print("执行 sql 语句：\(sql)")
            let array = [status.rawValue, requestId]
            dataBase.executeUpdate(sql, withArgumentsInArray: array as [AnyObject])
        }
    }
    
    //MARK: private methods
    private func fillFrendRequestModelWithFMResultSet(rs: FMResultSet) -> FrendRequest {
        let frend = FrendRequest()
        frend.requestId = rs.stringForColumn("RequestId")
        frend.userId = Int(rs.intForColumn("UserId"))
        frend.nickName = rs.stringForColumn("NickName")
        frend.avatar = rs.stringForColumn("Avatar")
        frend.gender = UserGender(rawValue: Int(rs.intForColumn("Sex")))!
        frend.status = TZFrendRequest(rawValue: Int(rs.intForColumn("Status")))!
        frend.attachMsg = rs.stringForColumn("Message")
        return frend
    }
}




