//
//  FrendManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

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
        self.setUpDefaultFrend()
    }
    
    /**
    默认设置问问的资料
    */
    private func setUpDefaultFrend() {
        let wenwen = FrendModel()
        wenwen.userId = 10001
        wenwen.nickName = "旅行问问"
        self.addFrend2DB(wenwen)
        
        let  paipai = FrendModel()
        paipai.userId = 10000
        paipai.nickName = "派派"
        self.addFrend2DB(paipai)
    }
    
    /**
    添加一个好友到数据库里,如果已经存在则不添加
    :param: frend
    */
    func addFrend2DB(frend: FrendModel) {
        self.frendDaoHelper.addFrend2DB(frend)
    }
    
    /**
    添加一个好友到数据库，如果已经存在，则更新
    
    :param: frend
    */
    func insertOrUpdateFrendInfoInDB(frend: FrendModel) {
        self.frendDaoHelper.insertOrUpdateFrendInfoInDB(frend)
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
    func getAllMyContactsInDB() -> NSArray {
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
        FrendManager.loadUserInfoFromServer(userId, completion: { (isSuccess: Bool, errorCode: Int, frendInfo: FrendModel?) -> () in
            if isSuccess {
                self.addFrend2DB(frendInfo!);
            }
            completion(isSuccess: isSuccess, errorCode: errorCode, frendInfo: frendInfo)
        })
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
    同意添加好友
    
    :param: frendRequest
    :param: completion
    :param: errorCode
    */
    func asyncAgreeAddContact(#requestId: String, completion: (isSuccess: Bool, errorCode: Int) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        let requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer = requestSerializer
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue("\(AccountManager.shareAccountManager().account.userId)", forHTTPHeaderField: "UserId")
        let params = ["action": 1];
        var url = "\(API_USERS)\(accountId)/contact-requests/\(requestId)"
        
        manager.PATCH(url, parameters: params, success:
            { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                if (responseObject.objectForKey("code") as! Int) == 0 {
                    IMClientManager.shareInstance().frendRequestManager.changeStatus(requestId, status: TZFrendRequest.Agree)
                    completion(isSuccess: true, errorCode: 0)
                } else {
                    completion(isSuccess: false, errorCode: 0)
                }
            }){
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(isSuccess: false, errorCode: 0)
                debug_print(error)
        }
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
        let accountId = AccountManager.shareAccountManager().account.userId
        manager.requestSerializer.setValue("\(accountId)", forHTTPHeaderField: "UserId")
        let params = ["contactId": userId, "message": helloStr]
        var url = "\(API_USERS)\(accountId)/contact-requests"
        manager.POST(url, parameters: params, success:
            {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                if (responseObject.objectForKey("code") as! Int) == 0 {
                    
                    completion(isSuccess: true, errorCode: 0)
                } else {
                    completion(isSuccess: false, errorCode: 0)
                }
            }){
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(isSuccess: false, errorCode: 0)
                debug_print(error)
        }
    }
    
    /**
    删除好友
    :param: userId
    :param: helloStr
    :param: completion
    */
    func asyncRemoveContact(#userId: Int, completion: (isSuccess: Bool, errorCode: Int) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        let requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer = requestSerializer
        manager.requestSerializer.setValue("\(accountId)", forHTTPHeaderField: "UserId")
        let url = "\(API_USERS)\(accountId)/contacts/\(userId)"
        manager.DELETE(url, parameters: nil, success:
            { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                if (responseObject.objectForKey("code") as! Int) == 0 {
                    self .updateFrendType(userId: userId, frendType: IMFrendType.Frend)
                    let daoHelper = DaoHelper.shareInstance()
                    IMClientManager.shareInstance().conversationManager.removeConversation(chatterId: userId, deleteMessage: true)
                    completion(isSuccess: true, errorCode: 0)
                } else {
                    completion(isSuccess: false, errorCode: 0)
                }
            }){
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(isSuccess: false, errorCode: 0)
                debug_print(error)
        }
    }
    
    
    private func insertMessageWhenFrendRequestAgreed(frend: FrendModel) {
        let textMsg = TextMessage()
        textMsg.senderId = frend.userId
        textMsg.message = "我已经同意了你的请求，现在我们可以开始聊天了"
        textMsg.createTime = Int(NSDate().timeIntervalSince1970)
        textMsg.chatType = IMChatType.IMChatSingleType
        textMsg.sendType = IMMessageSendType.MessageSendSomeoneElse
        textMsg.senderName = frend.nickName
        textMsg.chatterId = frend.userId

        IMClientManager.shareInstance().messageReceiveManager.addMessage2Distribute(textMsg)
    }
    
    //MARK: CMDMessageManagerDelegate
    func receiveFrendCMDMessage(cmdMessage: IMCMDMessage) {
        switch cmdMessage.actionCode! {
        case CMDActionCode.F_REQUEST:
            let frendRequest = FrendRequest(json: cmdMessage.message)
            IMClientManager.shareInstance().frendRequestManager.addFrendRequest(frendRequest)
            
        case CMDActionCode.F_AGREE:
            let contentDic = JSONConvertMethod.jsonObjcWithString(cmdMessage.message)
            let frendModel = FrendModel(json: contentDic)
            frendModel.type = IMFrendType.Frend
            self.insertOrUpdateFrendInfoInDB(frendModel)
            let daoHelper = DaoHelper.shareInstance()
            if daoHelper.selectLastLocalMessageInChatTable("chat_\(frendModel.userId)") == nil {
                self.insertMessageWhenFrendRequestAgreed(frendModel)
            }
            
        default:
            break
        }
        
    }
    
}


















