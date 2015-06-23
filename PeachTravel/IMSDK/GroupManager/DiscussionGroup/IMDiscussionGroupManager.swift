//
//  IMDiscussionGroupManager.swift
//  TZIM
//
//  Created by liangpengshuai on 5/12/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

@objc protocol DiscusssionGroupManagerDelegate {
    
    
    /**
    邀请加入讨论组
    
    :param: inviteContent 邀请的内容
    */
    optional func inviteAddDiscussionGroup(inviteContent: NSDictionary)
    
    /**
    某人退出了讨论组
    
    :param: content
    */
    optional func someoneQuiteDiscussionGroup(content: NSDictionary)

    
}

let discussionGroupManager = IMDiscussionGroupManager()

class IMDiscussionGroupManager: NSObject, CMDMessageManagerDelegate {
    
    private var delegateQueue: Array<DiscusssionGroupManagerDelegate> = Array()
    
    class func shareInstance() -> IMDiscussionGroupManager {
        return discussionGroupManager
    }
    
    override init() {
        super.init()
    }
    
    /**
    添加一个讨论组的 delegate
    
    :param: delegate
    */
    func addDelegate(delegate: DiscusssionGroupManagerDelegate) {
        delegateQueue.append(delegate)
    }
    
    /**
    删除一个讨论组的 delegate
    
    :param: delegate
    */
    func removeDelegate(delegate: DiscusssionGroupManagerDelegate) {
        for (index, value) in enumerate(delegateQueue) {
            if value === delegate {
                delegateQueue.removeAtIndex(index)
                return
            }
        }
    }
    
    /**
    异步创建一个讨论组
    :returns:
    */
    func asyncCreateDiscussionGroup(invitees: Array<FrendModel>, completionBlock: (isSuccess: Bool, errorCode: Int, discussionGroup: IMDiscussionGroup?) -> ()) {
        
        var array = Array<Int>()
        var groupName = AccountManager.shareAccountManager().account.nickName as String
        for frend in invitees {
            array.append(frend.userId)
            groupName += ", \(frend.nickName)"
        }
        var params = NSMutableDictionary()
        params.setObject(array, forKey: "participants")
        params.setObject(groupName, forKey: "name")
        
        NetworkTransportAPI.asyncPOST(requstUrl: groupUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            if isSuccess {
                var group = IMDiscussionGroup(jsonData: retMessage!)
                group.subject = groupName
                group.numbers = invitees
                var frendManager = FrendManager.shareInstance()
                frendManager.addFrend2DB(self.convertDiscussionGroupModel2FrendModel(group))
                completionBlock(isSuccess: true, errorCode: errorCode, discussionGroup: group)
            } else {
                completionBlock(isSuccess: isSuccess, errorCode: errorCode, discussionGroup: nil)
            }
        }
    }
    
    /**
    获取我所有的讨论组
    
    :param: completionBlock 
    */
    func asyncLoadAllMyDiscussionGroupsFromServer(completionBlock: (isSuccess: Bool, errorCode: Int, groupList: Array<IMDiscussionGroup>) -> ()) {
        let groupListUrl = "\(userUrl)/\(AccountManager.shareAccountManager().account.userId)/groups"
        NetworkTransportAPI.asyncGET(requestUrl: groupListUrl, parameters: nil) { (isSuccess, errorCode, retMessage) -> () in
            var groupList = Array<IMDiscussionGroup>()
            if let retData = retMessage as? NSArray {
                for groupData in retData  {
                    var group = IMDiscussionGroup(jsonData: groupData as! NSDictionary)
                    groupList.append(group)
                    var frendManager = FrendManager.shareInstance()
                    frendManager.addFrend2DB(self.convertDiscussionGroupModel2FrendModel(group))
                }
            }
            completionBlock(isSuccess: isSuccess, errorCode: errorCode, groupList: groupList)
        }
    }
    
    /**
    申请加入讨论组
    
    :param: groupId
    :param: request
    :param: completionBlock     
    */
    func asyncRequestJoinDiscussionGroup(#groupId: Int, request: String?, completionBlock: (isSuccess: Bool, errorCode: Int) -> ()) {
        var params = NSMutableDictionary()
        params.setObject("join", forKey: "action")
        params.setObject("\(request)", forKey: "message")
        var requestAddGroupUrl = "\(groupUrl)/\(groupId)/request"
        NetworkTransportAPI.asyncPOST(requstUrl: requestAddGroupUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            
        }
    }
    
    /**
    离开一个讨论组
    
    :param: completion
    */
    func asyncLeaveDiscussionGroup(completion:(isSuccess: Bool, errorCode: Int) -> ()) {
    }
    
    
    
    func asyncChangeDiscussionGroupTitle(#group: IMDiscussionGroup, title: String, completion:(isSuccess: Bool, errorCode: Int) -> ()) {
        var params = NSMutableDictionary()
        params.setObject(title, forKey: "name")
        
        let changeDiscussionGroupSubjectUrl = "\(groupUrl)/\(group.groupId)"
        NetworkTransportAPI.asyncPUT(requestUrl: changeDiscussionGroupSubjectUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            if isSuccess {
                self.updateGroupInfoInDB(group)
                completion(isSuccess: true, errorCode: 0)
            }
            else {
                completion(isSuccess: false, errorCode: 0)
            }
        }

    }
    
    /**
    向群里添加新用户
    
    :param: groupId
    :param: numbers
    :param: completion 
    */
    func asyncAddNumbers(#group: IMDiscussionGroup, numbers: Array<FrendModel>, completion:(isSuccess: Bool, errorCode: Int) -> ()) {
        var array = Array<Int>()
        for frend in numbers {
            array.append(frend.userId)
        }
        var params = NSMutableDictionary()
        params.setObject(array, forKey: "participants")
        params.setObject("addMembers", forKey: "action")
        params.setObject(group.groupId, forKey: "id")
        let addNumberUrl = "\(groupUrl)/\(group.groupId)"
        NetworkTransportAPI.asyncPOST(requstUrl: addNumberUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            if isSuccess {
                self.addNumbers2Group(numbers: numbers, group: group)
                
                completion(isSuccess: true, errorCode: 0)
            } else {
                completion(isSuccess: false, errorCode: 0)
            }
        }
    }
    
    /**
    删除群组里的成员
    
    :param: groupId
    :param: numbers
    :param: completion
    */
    func asyncDeleteNumbers(#group: IMDiscussionGroup, numbers: Array<FrendModel>, completion:(isSuccess: Bool, errorCode: Int) -> ()) {
        var array = Array<Int>()
        for frend in numbers {
            array.append(frend.userId)
        }
        var params = NSMutableDictionary()
        params.setObject(array, forKey: "participants")
        params.setObject("delMembers", forKey: "action")
        params.setObject(group.groupId, forKey: "id")
        let addNumberUrl = "\(groupUrl)/\(group.groupId)"
        NetworkTransportAPI.asyncPOST(requstUrl: addNumberUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            if isSuccess {
                self.deleteNumbersFromGroup(numbers: numbers, group: group)
                
                completion(isSuccess: true, errorCode: 0)
            } else {
                completion(isSuccess: false, errorCode: 0)
            }
        }
    }
    
    func asyncChangeDiscussionGroupSubject(#group: IMDiscussionGroup, subjectName: String,completion: (isSuccess: Bool, errorCode: Int) -> ())
    {
            }

    
 //MARK: private function
    
    /**
    添加一组成员到群组的用户列表里。自动幂等，已有不添加
    
    :param: numbers
    :param: group
    */
    private func addNumbers2Group(#numbers: Array<FrendModel>, group: IMDiscussionGroup) {
        for frend in numbers {
            var find = false
            for oldFrend in group.numbers {
                if oldFrend.userId == frend.userId {
                    find = true
                    break
                }
            }
            if !find {
                group.numbers.append(frend)
            }
        }
        self.updateGroupInfoInDB(group)
    }
    
    /**
    删除群组里的某一些成员
    
    :param: numbers
    :param: group
    */
    private func deleteNumbersFromGroup(#numbers: Array<FrendModel>, group: IMDiscussionGroup) {
        var leftNumbers = Array<FrendModel>()
        for frend in numbers {
            var find = false
            for oldFrend in group.numbers {
                if oldFrend.userId != frend.userId {
                    leftNumbers.append(oldFrend)
                }
            }
        }
        group.numbers = leftNumbers
        self.updateGroupInfoInDB(group)
    }

    /**
    更新数据库里相关群组的信息
    
    :param: group
    */
    func updateGroupInfoInDB(group: IMDiscussionGroup) {
        var frend = self.convertDiscussionGroupModel2FrendModel(group)
        var frendManager = FrendManager.shareInstance()
        frendManager.addFrend2DB(frend)
    }
    
    private func dispatchCMDMessage(message: IMCMDMessage) {
        switch message.actionCode! {
        case .D_INVITE :
           self.someInviteYouAddDiscussionGroup(message)
            
        default :
            break
        }
       
    }
    
    /**
    某人邀请你加入群组
    :param: message
    */
    private func someInviteYouAddDiscussionGroup(message: IMCMDMessage) {
        self.addDiscussionGroupInfo2DB(message: message)
        for delegate in delegateQueue {
            delegate.inviteAddDiscussionGroup?(message.actionContent)
        }
    }
    
    /**
    从 cmd 消息里提取群组信息，并将群组信息插入到 frend 表中
    
    :param: message
    */
    private func addDiscussionGroupInfo2DB(#message: IMCMDMessage) {
        var frendModel = FrendModel()
        if let content = message.actionContent {
            frendModel.userId = content.objectForKey("groupId") as! Int
            if let nickName = content.objectForKey("groupName") as? String {
                frendModel.nickName = nickName
            }
            if let avatar = content.objectForKey("groupAvatar") as? String {
                frendModel.avatar = avatar
                frendModel.avatarSmall = avatar
            }
            frendModel.fullPY = ConvertMethods.chineseToPinyin(frendModel.nickName)
            frendModel.type = IMFrendType.DiscussionGroup
            var frendManager = FrendManager.shareInstance()
            frendManager.addFrend2DB(frendModel)
        }
    }
    
    /**
    将一个群组转换成一个frendmodel
    
    :param: group
    
    :returns:
    */
    func convertDiscussionGroupModel2FrendModel(group: IMDiscussionGroup) -> FrendModel {
        var frendModel = FrendModel()
        frendModel.userId = group.groupId
        frendModel.nickName = group.subject
        frendModel.type = IMFrendType.DiscussionGroup
        if group.numbers.count > 0 {
            var numberDic = NSMutableDictionary()
            var array = Array<Int>()
            
            for frend in group.numbers {
                array.append(frend.userId)
            }
            numberDic.setObject(array, forKey: "numbers")
            frendModel.extData = JSONConvertMethod.contentsStrWithJsonObjc(numberDic)!
        }

        return frendModel
    }
    
    /**
    将一个 frendmodel 类型转换为IMDiscussionGroup类型
    
    :param: frendModel 
    
    :returns:
    */
    func getFullDiscussionGroupInfo(#frendModel: FrendModel) -> IMDiscussionGroup {
        var discussionGroup = IMDiscussionGroup()
        discussionGroup.groupId = frendModel.userId
        discussionGroup.subject = frendModel.nickName
        var extData = JSONConvertMethod.jsonObjcWithString(frendModel.extData as String)
        
        if let numbersId = extData.objectForKey("numbers") as? Array<Int> {
            var daohelper = DaoHelper.shareInstance()
            for userId in numbersId {
                if let frend = daohelper.selectFrend(userId: userId) {
                    discussionGroup.numbers.append(frend)
                } else {
                    var frendModel = FrendModel()
                    frendModel.userId = userId
                    discussionGroup.numbers.append(frendModel)
                }
            }
        }
        return discussionGroup
    }
    
    func getBasicDiscussionGroupInfo(#frendModel: FrendModel) -> IMDiscussionGroup {
        var discussionGroup = IMDiscussionGroup()
        discussionGroup.groupId = frendModel.userId
        discussionGroup.subject = frendModel.nickName
        return discussionGroup
    }
    
    
    //MARK: CMDMessageManagerDelegate
    
    func receiveDiscussiongGroupCMDMessage(cmdMessage: IMCMDMessage) {
        self.dispatchCMDMessage(cmdMessage)
    }
}



