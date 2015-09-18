//
//  AccountDaoHelper.swift
//  PeachTravel
//
//  Created by liangpengshuai on 6/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//  这个文件主要是账户数据库的初始化以及创表,获取登录账号,创建账号,添加账号,删除用户记录等

import UIKit

let AccountDB = "AccountDB"
let AccountTableName = "Account"

let accountDaoHelper = AccountDaoHelper()

class AccountDaoHelper: NSObject {
    
    private let db : FMDatabase!
    private let dbQueue: FMDatabaseQueue!
    
    /**
    FMDB初始化创建数据库
    */
    override init() {
        let dbPath: String = documentPath.stringByAppendingString("/\(AccountTableName).sqlite")
        db = FMDatabase(path: dbPath)
        dbQueue = FMDatabaseQueue(path: dbPath)
        super.init()
        if !self.tableIsExit(AccountTableName) {
            self.createAccountDB()
        }
    }
    
    // 单例,初始化创建过程
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
            let sql = "select * from \(AccountTableName)"
            let rs = dataBase.executeQuery(sql, withArgumentsInArray: nil)
            if (rs != nil) {
                while rs.next() {
                    account = self.fillAccountWithFMResultSet(rs)
                }
            }
        }
        return account
    }
    
    /**
    传入表名,判断是否存在
    
    :param: tableName 表名
    
    :returns: 存在返回true
    */
    func tableIsExit(tableName: String) -> Bool {
        
        var retResult = false
        
        dbQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "select count(*) as 'count' from sqlite_master where type ='table' and name = ?"
            let rs = dataBase.executeQuery(sql, withArgumentsInArray: [tableName])
            if (rs != nil) {
                while (rs.next())
                {
                    let count: Int32 = rs.intForColumn("count")
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
    
    /**
    创建账号表
    */
    func createAccountDB() {
        if db.open() {
            let sql = "create table '\(AccountTableName)' (UserId INTEGER PRIMARY KEY NOT NULL, NickName TEXT, Avatar Text, AvatarSmall Text, Signature Text, Sex Text, tel Text, secToke Text, ExtData Text)"
            if (db.executeUpdate(sql, withArgumentsInArray: nil)) {
                debug_print("执行 sql 语句：\(sql)")
            }
            db.close()
        }
    }
    
    /**
    添加一个账户到数据库表中
    
    :param: account 账户
    */
    func addAccount2DB(account: AccountModel) {
        dbQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "insert or replace into \(AccountTableName) (UserId, NickName, Avatar, AvatarSmall, Signature, Sex, tel, secToke) values (?,?,?,?,?,?,?,?)"
            debug_print("执行 sql 语句：\(sql)")
            let array = [account.userId, account.nickName, account.avatar, account.avatarSmall, account.signature, account.gender.rawValue, account.tel, account.secToken]
            dataBase.executeUpdate(sql, withArgumentsInArray: array as [AnyObject])
        }
    }
    
    /**
    删除 account 表中的用户记录
    */
    func deleteAccountInfoInDB() {
        dbQueue.inDatabase { (dataBase: FMDatabase!) -> Void in
            let sql = "delete from \(AccountTableName)"
            debug_print("执行 sql 语句：\(sql)")
            dataBase.executeUpdate(sql, withArgumentsInArray: nil)
        }

    }
    
    //MARK: private methods
    private func fillAccountWithFMResultSet(rs: FMResultSet) -> AccountModel {
        let account = AccountModel()
        account.userId = Int(rs.intForColumn("UserId"))
        account.nickName = rs.stringForColumn("NickName")
        account.avatar = rs.stringForColumn("Avatar")
        account.avatarSmall = rs.stringForColumn("AvatarSmall")
        account.signature = rs.stringForColumn("Signature")
        account.gender = UserGender(rawValue: Int(rs.intForColumn("Sex")))!
        return account
    }

    
   
}
