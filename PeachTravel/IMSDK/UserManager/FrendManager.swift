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

@objc protocol FrendManagerManagerDelegate {
    
}

class FrendManager: NSObject, CMDMessageManagerDelegate {
    
    let accountId: Int
    
    var frendDaoHelper :FrendDaoHelper
    
    /**
    初始化
    
    :param: userId 系统中当前登录的账户的 userId
    
    :returns:
    */
    init(userId: Int) {
        accountId = userId
        var dbPath: String = documentPath.stringByAppendingPathComponent("\(accountId)/user.sqlite")
        let db = FMDatabase(path: dbPath)
        let dbQueue = FMDatabaseQueue(path: dbPath)
        frendDaoHelper = FrendDaoHelper(db: db, dbQueue: dbQueue)
        super.init()
    }
    
    /**
    添加一个好友到数据库里
    :param: frend
    */
    func addFrend2DB(frend: FrendModel) {
        self.frendDaoHelper.addFrend2DB(frend)
    }
    
    func updateFrendInfoInDB(frend: FrendModel) {
        self.frendDaoHelper.updateFrendInfoInDB(frend)
    }
    
    /**
    更新
    
    :param: name
    :param: userId
    */
    func updateNickNameInDB(name: String, userId: Int) {
        self.frendDaoHelper.updateNickNameInDB(name, userId: userId)
    }
    
    /**
    更新
    
    :param: avatar
    :param: userId
    */
    func updateAvatarInDB(avatar: String, userId: Int) {
        self.frendDaoHelper.updateAvatarInDB(avatar, userId: userId)
    }
    
    func updateExtDataInDB(extData: String, userId: Int) {
        self.frendDaoHelper.updateExtDataInDB(extData, userId: userId)
    }
    
    /**
    获取所有的好友列表
    :returns:
    */
    func getAllMyContacts() -> NSArray {
        var retArray = NSArray()
        retArray = self.frendDaoHelper.selectAllContacts()
        return retArray
    }
    
    func selectAllGroup() -> Array<IMGroupModel> {
        return frendDaoHelper.selectAllGroup()
    }
    
    func deleteAllContacts() {
        self.frendDaoHelper.deleteAllContactsFromDB()
    }
    
    /**
    用户是否在本地数据里存在
    :param: userId 查询的用户 id
    :returns:
    */
    func frendIsExitInDB(userId: Int) -> Bool {
        return self.frendDaoHelper.frendIsExitInDB(userId)
    }
    
    func updateFrendType(#userId: Int, frendType: IMFrendType) {
        self.frendDaoHelper.updateFrendType(userId: userId, type: frendType)
    }
    
    /**
    *  更新好友备注
    */
    func updateContactMemoInDB(momo: String, userId: Int) {
        self.frendDaoHelper.updateMemoInDB(momo, userId: userId)
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
    func getFrendInfoFromDB(#userId: Int, frendType: IMFrendWeightType?) -> FrendModel? {
        return self.frendDaoHelper.selectFrend(userId: userId, frendType: frendType)
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
        manager.requestSerializer.setValue("\(accountId)", forHTTPHeaderField: "UserId")
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
        switch cmdMessage.actionCode! {
        case CMDActionCode.F_REQUEST:
            let frendRequest = FrendRequestManager()
            frendRequest.addFrendRequest(cmdMessage.actionContent)
            
        case CMDActionCode.F_AGREE:
            let frendRequestManager = FrendRequestManager()
            let request = FrendRequest(json: cmdMessage.actionContent)
            frendRequestManager.changeStatus(request.userId, status: TZFrendRequest.Agree)
            
        default:
            break
        }
        
    }
    
}


















