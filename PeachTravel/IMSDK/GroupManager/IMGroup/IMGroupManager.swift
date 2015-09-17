//
//  IMGroupManager.swift
//  TZIM
//
//  Created by liangpengshuai on 5/9/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

let groupUrl = "http://api-dev.lvxingpai.com/groups"

let groupManager = IMGroupManager()

@objc protocol IMGroupManagerDelegate {
    /**
    邀请加入群组
    
    :param: inviteContent 邀请的内容
    */
    optional func inviteAddGroup(inviteContent: NSDictionary)
    
    /**
    某人退出了群组
    
    :param: content
    */
    optional func someoneQuiteGroup(content: NSDictionary)
    
    /**
    群组被销毁
    
    :param: content
    */
    optional func groupDestroyed(content: NSDictionary)

}

class IMGroupManager: NSObject {
    private var delegateQueue: Array<IMGroupManager> = Array()
    
//MARK: public function
    
    class func shareInstance() -> IMGroupManager {
        return groupManager
    }
    
    /**
    添加一个讨论组的 delegate
    
    :param: delegate
    */
    func addDelegate(delegate: IMGroupManager) {
        delegateQueue.append(delegate)
    }
    
    /**
    删除一个讨论组的 delegate
    
    :param: delegate
    */
    func removeDelegate(delegate: IMGroupManager) {
        for (index, value) in delegateQueue.enumerate() {
            if value === delegate {
                delegateQueue.removeAtIndex(index)
                return
            }
        }
    }
    
    func asyncLoadAllMyGroupsFromServer(completionBlock: (isSuccess: Bool, errorCode: Int, groupList: Array<IMGroupModel>) -> ()) {
        let groupListUrl = "\(HedyUserUrl)/\(AccountManager.shareAccountManager().account.userId)/groups"
        NetworkTransportAPI.asyncGET(requestUrl: groupListUrl, parameters: nil) { (isSuccess, errorCode, retMessage) -> () in
            var groupList = Array<IMGroupModel>()
            if let retData = retMessage as? NSArray {
                for groupData in retData  {
                    let group = IMGroupModel(jsonData: groupData as! NSDictionary)
                    groupList.append(group)
                    let frendManager = IMClientManager.shareInstance().frendManager
                    frendManager.addFrend2DB(self.convertGroupModel2FrendModel(group))
                }
            }
            completionBlock(isSuccess: isSuccess, errorCode: errorCode, groupList: groupList)
        }
    }
    
    func loadAllMyGroupsFromDB() -> Array<IMGroupModel> {
        let frendManager = IMClientManager.shareInstance().frendManager
        return frendManager.selectAllGroup()
    }
    
    func asyncCreateGroup(subject subject: NSString, description: String?, isPublic: Bool, invitees: Array<Int>, welcomeMessage: String?, completionBlock: (isSuccess: Bool, errorCode: Int, retGroup: IMGroupModel?) -> ()) {
        let params = NSMutableDictionary()
        params.setObject(subject, forKey: "name")
        params.setObject(isPublic, forKey: "isPublic")
        params.setObject("common", forKey: "groupType")
        params.setObject(invitees, forKey: "participants")

        NetworkTransportAPI.asyncPOST(requstUrl: groupUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            if isSuccess {
                let group = IMGroupModel(jsonData: retMessage!)
                let frendManager = IMClientManager.shareInstance().frendManager
                frendManager.addFrend2DB(self.convertGroupModel2FrendModel(group))
                completionBlock(isSuccess: isSuccess, errorCode: errorCode, retGroup: group)
            } else {
                completionBlock(isSuccess: isSuccess, errorCode: errorCode, retGroup: nil)
            }
        }
    }
    
    func asyncRequestJoinGroup(groupId groupId: Int, request: String?, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        let params = NSMutableDictionary()
        params.setObject("join", forKey: "action")
        params.setObject("\(request)", forKey: "message")
        let requestAddGroupUrl = "\(groupUrl)/\(groupId)/request"
        NetworkTransportAPI.asyncPOST(requstUrl: requestAddGroupUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            
        }
        
    }
    
    func asyncLeaveGroup(groupId groupId: Int, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        let params = NSMutableDictionary()
        params.setObject("exit", forKey: "action")
        let exitGroupUrl = "\(groupUrl)/\(groupId)/request"
        NetworkTransportAPI.asyncPOST(requstUrl: exitGroupUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            
        }
    }
    
    func asyncDestroyGroup(groupId groupId: Int, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }
    
    func asyncAddNumbers2Group(groupId groupId: Int, numbers: Array<Int>, welcomeMessage: String?, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        let params = NSMutableDictionary()
        params.setObject("addMembers", forKey: "action")
        params.setObject(groupId, forKey: "id")
        params.setObject(numbers, forKey: "participants")
        let addNumberUrl = "\(groupUrl)/\(groupId)/request"
        NetworkTransportAPI.asyncPOST(requstUrl: addNumberUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            
        }
    }
    
    func asyncRemoveNumbersFromGroup(groupId groupId: Int, numbers: Array<Int>, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        let params = NSMutableDictionary()
        params.setObject("delMembers", forKey: "action")
        params.setObject(groupId, forKey: "id")
        params.setObject(numbers, forKey: "participants")
        let addNumberUrl = "\(groupUrl)/\(groupId)/request"
        NetworkTransportAPI.asyncPOST(requstUrl: addNumberUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            
        }
    }
    
    func asyncBlockNumbers(groupId groupId: Int, numbers: Array<Int>, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        let params = NSMutableDictionary()
        params.setObject("silence", forKey: "action")
        params.setObject(groupId, forKey: "id")
        params.setObject(numbers, forKey: "participants")
        let addNumberUrl = "\(groupUrl)/\(groupId)/request"
        NetworkTransportAPI.asyncPOST(requstUrl: addNumberUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            
        }
    }

    func asyncUnBlockNumbers(groupId groupId: Int, numbers: Array<Int>, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }
    
    func asyncChangeGroupSubject(groupId groupId: Int, subject: String, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }
    
    func asyncChangeGroupDescription(groupId groupId: Int, description: String, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        
    }
    
    
//MARK: private function
    /**
    将一个群组转换成一个frendmodel
    
    :param: group
    
    :returns:
    */
    func convertGroupModel2FrendModel(group: IMGroupModel) -> FrendModel {
        let frendModel = FrendModel()
        frendModel.userId = group.groupId
        frendModel.nickName = group.subject
        frendModel.type = IMFrendType.Group
        return frendModel
    }


}
