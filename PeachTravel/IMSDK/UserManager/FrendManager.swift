//
//  FrendManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

private let API_REQUEST_ADD_CONTACT = "\(BASE_URL)users/request-contacts"  //请求添加好友
private let API_FREND = "\(BASE_URL)users/contacts"

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
    
    func updateFrendInfoInDB(frend: FrendModel) {
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.updateFrendInfoInDB(frend)
    }
    
    /**
    更新
    
    :param: name
    :param: userId
    */
    func updateNickNameInDB(name: String, userId: Int) {
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.updateNickNameInDB(name, userId: userId)

    }
    
    /**
    更新
    
    :param: avatar
    :param: userId
    */
    func updateAvatarInDB(avatar: String, userId: Int) {
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.updateAvatarInDB(avatar, userId: userId)
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
    *  更新好友备注
    */
    func updateContactMemo(momo: String, userId: Int) {
        
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
    
    /**
     请求添加好友
    
    :param: userId
    :param: completion
    */
    func asyncRequestAddContact(#userId: Int, helloStr: String, completion: (isSuccess: Bool, errorCode: Int) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        let requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer = requestSerializer
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue("\(AccountManager.shareAccountManager().account.userId)", forHTTPHeaderField: "UserId")
        let params = ["userId": userId, "message": helloStr]
        var url = "\(API_USERINFO)\(userId)"
        manager.POST(API_REQUEST_ADD_CONTACT, parameters: params, success:
            { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                if (responseObject.objectForKey("code") as! Int) == 0 {
                    completion(isSuccess: true, errorCode: 0)
                } else {
                    completion(isSuccess: false, errorCode: 0)
                }
            }){
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(isSuccess: false, errorCode: 0)
                print(error)
        }
    }
    
    /**
    删除好友
    :param: userId
    :param: helloStr
    :param: completion
    */
    func asyncRemoveContact(#frend: FrendModel, completion: (isSuccess: Bool, errorCode: Int) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        let requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer = requestSerializer
        manager.requestSerializer.setValue("\(AccountManager.shareAccountManager().account.userId)", forHTTPHeaderField: "UserId")
        let url = "\(API_FREND)/\(frend.userId)"
        manager.DELETE(url, parameters: nil, success:
            { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                if (responseObject.objectForKey("code") as! Int) == 0 {
                    completion(isSuccess: true, errorCode: 0)
                } else {
                    completion(isSuccess: false, errorCode: 0)
                }
            }){
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(isSuccess: false, errorCode: 0)
                print(error)
        }
    }
    
    //MARK: CMDMessageManagerDelegate
    func receiveFrendCMDMessage(cmdMessage: IMCMDMessage) {
        
    }
    
}


















