//
//  AccountDaoHelper.swift
//  PeachTravel
//
//  Created by liangpengshuai on 6/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

let AccountDB = "AccountDB"
let AccountTableName = "Account"


//let acountDBPath: String = "\(NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as! String)/\(AccountDB).sqlite"

let accountDaoHelper = AccountDaoHelper()

class AccountDaoHelper: NSObject {
    
    private let db : FMDatabase!
    private let dbQueue: FMDatabaseQueue!
    
    override init() {
//        var fileManager =  NSFileManager()
//        
//        if !fileManager.fileExistsAtPath(acountDBPath) {
//            fileManager.createDirectoryAtPath(acountDBPath, withIntermediateDirectories: true, attributes: nil, error: nil)
//        }
        var dbPath: String = documentPath.stringByAppendingPathComponent("\(AccountTableName).sqlite")
        db = FMDatabase(path: dbPath)
        dbQueue = FMDatabaseQueue(path: dbPath)
        super.init()
        if !self.tableIsExit(AccountTableName) {
            self.createAccountDB()
        }
    }
    
    class func shareInstance() -> AccountDaoHelper {
        return accountDaoHelper
    }
    
    /**
    获取当前登录的帐号
    
    :returns: 
    */
    func selectCurrentAccount() -> AccountModel? {
        var account: AccountModel?
        dbQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "select * from \(accountTableName)"
            var rs = dataBase.executeQuery(sql, withArgumentsInArray: nil)
            if (rs != nil) {
                while rs.next() {
                    account = self.fillAccountWithFMResultSet(rs)
                }
            }
        }
        return account
    }
    
    func tableIsExit(tableName: String) -> Bool {
        
        var retResult = false
        
        dbQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "select count(*) as 'count' from sqlite_master where type ='table' and name = ?"
            var rs = dataBase.executeQuery(sql, withArgumentsInArray: [tableName])
            if (rs != nil) {
                while (rs.next())
                {
                    var count: Int32 = rs.intForColumn("count")
                    if (0 == count) {
                        retResult =  false;
                    } else {
                        retResult =  true;
                    }
                }
            }
        }
        return retResult;
    }
    
    func createAccountDB() {
        if db.open() {
            var sql = "create table '\(AccountTableName)' (UserId INTEGER PRIMARY KEY NOT NULL, NickName TEXT, Avatar Text, AvatarSmall Text, Signature Text, Sex Text, tel Text, secToke Text, ExtData Text)"
            if (db.executeUpdate(sql, withArgumentsInArray: nil)) {
                println("执行 sql 语句：\(sql)")
            }
            db.close()
        }
    }
    
    func addAccount2DB(account: AccountModel) {
        dbQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            var sql = "insert or replace into \(AccountTableName) (UserId, NickName, Avatar, AvatarSmall, Signature, Sex, tel, secToke) values (?,?,?,?,?,?,?,?)"
            println("执行 sql 语句：\(sql)")
            var array = [account.userId, account.nickName, account.avatar, account.avatarSmall, account.signature, account.gender, account.tel, account.secToken]
            dataBase.executeUpdate(sql, withArgumentsInArray: array as [AnyObject])
        }
    }
    
    //MARK: private methods
    private func fillAccountWithFMResultSet(rs: FMResultSet) -> AccountModel {
        var account = AccountModel()
        account.userId = Int(rs.intForColumn("UserId"))
        account.nickName = rs.stringForColumn("NickName")
        account.avatar = rs.stringForColumn("Avatar")
        account.avatarSmall = rs.stringForColumn("AvatarSmall")
        account.signature = rs.stringForColumn("Signature")
        account.gender = String(rs.intForColumn("Sex"))
        return account
    }

    
   
}
