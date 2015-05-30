//
//  FrendManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

@objc protocol FrendManagerDelegate {
    /**
    请求添加好友
    
    :param: requestContent 请求的信息
    */
    optional func requestAddFrend(requestContent: NSDictionary)

}

private let frendManager = FrendManager()

class FrendManager: NSObject, CMDMessageManagerDelegate {
    
    private var delegateQueue: Array<FrendManagerDelegate> = Array()
    
    class func shareInstance() -> FrendManager {
        return frendManager
    }
    
    override init() {
        super.init()
    }
    
    /**
    添加一个frend的 delegate
    :param: delegate
    */
    func addDelegate(delegate: FrendManagerDelegate) {
        delegateQueue.append(delegate)
    }
    
    /**
    删除一个frend的 delegate
    :param: delegate
    */
    func removeDelegate(delegate: FrendManagerDelegate) {
        for (index, value) in enumerate(delegateQueue) {
            if value === delegate {
                delegateQueue.removeAtIndex(index)
                return
            }
        }
    }
    
    /**
    添加一个好友到数据库里
    :param: frend
    */
    func addFrend2DB(frend: FrendModel) {
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.addFrend2DB(frend)
    }
    
    /**
    获取所有的好友列表
    :returns:
    */
    func getAllMyContacts() -> NSArray {
        var retArray = NSArray()
        var daoHelper = DaoHelper.shareInstance()
        retArray = daoHelper.selectAllContacts()
        return retArray
    }
    
    func deleteAllContacts() {
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.deleteAllContactsFromDB()
    }
    
    /**
    用户是否在本地数据里存在
    :param: userId 查询的用户 id
    :returns:
    */
    func frendIsExitInDB(userId: Int) -> Bool {
        var daoHelper = DaoHelper.shareInstance()
        return daoHelper.frendIsExitInDB(userId)
    }
    
    /**
    异步通过 userid 从服务器获取用户信息
    
    :param: userId
    */
    func asyncGetFrendInfoFromServer(userId: Int, completion: (isSuccess: Bool, errorCode: Int, frendInfo: FrendModel?) -> ()) {
        self.loadUserInfoFromServer(userId, completion: completion)
    }
    
    /**
    从数据库里通过 userid 获取用户信息
    
    :param: userId
    
    :returns:
    */
    func getFrendInfoFromDB(#userId: Int) -> FrendModel? {
        var daoHelper = DaoHelper.shareInstance()
        return daoHelper.selectFrend(userId: userId)
    }
    
    //MARK: CMDMessageManagerDelegate
    
    func receiveFrendCMDMessage(cmdMessage: IMCMDMessage) {
        
    }
    
}


















