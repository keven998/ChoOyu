//
//  IMDiscussionGroupManager.swift
//  TZIM
//
//  Created by liangpengshuai on 5/12/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

let discussionGroupUrl = "\(BASE_URL)chatgroups"

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
    func asyncCreateDiscussionGroup(subject: String, invitees: Array<FrendModel>, completionBlock: (isSuccess: Bool, errorCode: Int, discussionGroup: IMDiscussionGroup?) -> ()) {
        
        var array = Array<Int>()
        for frendModel in invitees {
            array.append(frendModel.userId)
        }
        var params = NSMutableDictionary()
        params.setObject(array, forKey: "members")
        params.setObject(subject, forKey: "name")
        
        NetworkTransportAPI.asyncPOST(requstUrl: discussionGroupUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            if isSuccess {
                var group = IMDiscussionGroup(jsonData: retMessage!)
                group.subject = subject
                group.members = invitees
                var frendManager = IMClientManager.shareInstance().frendManager
                frendManager.addFrend2DB(self.convertDiscussionGroupModel2FrendModel(group))
                completionBlock(isSuccess: true, errorCode: errorCode, discussionGroup: group)
            } else {
                completionBlock(isSuccess: isSuccess, errorCode: errorCode, discussionGroup: nil)
            }
        }
    }
    


    /**
    异步删除一个讨论组
    
    :param: subject         讨论组ID
    :param: invitees        群组成员
    :param: completionBlock 删除成功进入block
    :param: errorCode       错误码,留着备用
    */
    func asyncDeleteDiscussionGroup(groupId: Int, completionBlock: (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> ()) {
        // 1.发送删除操作给服务器,删除ID位subject的讨论组,同时清空数据库中该讨论组的相关信息
        var params = NSMutableDictionary()
        let deleteDiscussionGroupUrl = "\(BASE_URL)chatgroups/\(groupId)"
        NetworkTransportAPI.asyncDELETE(requstUrl: deleteDiscussionGroupUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            completionBlock(isSuccess: isSuccess, errorCode: errorCode, retMessage: retMessage)
        }
    }
    
    /**
    获取我所有的讨论组
    
    :param: completionBlock 
    */
    func asyncLoadAllMyDiscussionGroupsFromServer(completionBlock: (isSuccess: Bool, errorCode: Int, groupList: Array<IMDiscussionGroup>) -> ()) {
        let groupListUrl = "\(HedyUserUrl)/\(IMClientManager.shareInstance().accountId)/groups"
        NetworkTransportAPI.asyncGET(requestUrl: groupListUrl, parameters: nil) { (isSuccess, errorCode, retMessage) -> () in
            var groupList = Array<IMDiscussionGroup>()
            if let retData = retMessage as? NSArray {
                for groupData in retData  {
                    var group = IMDiscussionGroup(jsonData: groupData as! NSDictionary)
                    groupList.append(group)
                    var frendManager = IMClientManager.shareInstance().frendManager
                    frendManager.insertOrUpdateFrendInfoInDB(self.convertDiscussionGroupModel2FrendModel(group))
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
        var requestAddGroupUrl = "\(discussionGroupUrl)/\(groupId)/request"
        NetworkTransportAPI.asyncPOST(requstUrl: requestAddGroupUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            
        }
    }

    /**
    修改讨论组title
    
    :param: groupId
    :param: title
    */
    func asyncChangeDiscussionGroupTitle(#group: IMDiscussionGroup, title: String, completion:(isSuccess: Bool, errorCode: Int) -> ()) {
        var params = NSMutableDictionary()
        params.setObject(title, forKey: "name")
        let changeDiscussionGroupSubjectUrl = "\(discussionGroupUrl)/\(group.groupId)"
        NetworkTransportAPI.asyncPATCH(requstUrl: changeDiscussionGroupSubjectUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            if isSuccess {
                group.subject = title
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
    :param: members
    :param: completion 
    */
    func asyncAddNumbers(#group: IMDiscussionGroup, members: Array<FrendModel>, completion:(isSuccess: Bool, errorCode: Int) -> ()) {
        var array = Array<Int>()
        for frend in members {
            array.append(frend.userId)
        }
        var params = NSMutableDictionary()
        params.setObject(array, forKey: "members")
        params.setObject(1, forKey: "action")
        let addNumberUrl = "\(discussionGroupUrl)/\(group.groupId)/members"
        NetworkTransportAPI.asyncPATCH(requstUrl: addNumberUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            if isSuccess {
                self.addNumbers2Group(members: members, group: group)
                
                completion(isSuccess: true, errorCode: 0)
            } else {
                completion(isSuccess: false, errorCode: 0)
            }
        }
    }
    
    /**
    删除群组里的成员
    
    :param: groupId
    :param: members
    :param: completion
    */
    func asyncDeleteNumbers(#group: IMDiscussionGroup, members: Array<Int>, completion:(isSuccess: Bool, errorCode: Int) -> ()) {
        var array = Array<Int>()
    
        var params = NSMutableDictionary()
        params.setObject(members, forKey: "members")
        params.setObject(2, forKey: "action")
        let addNumberUrl = "\(discussionGroupUrl)/\(group.groupId)/members"
        NetworkTransportAPI.asyncPATCH(requstUrl: addNumberUrl, parameters: params) { (isSuccess, errorCode, retMessage) -> () in
            if isSuccess {
                var isQuitGroup = false
                for userId in members {
                    if userId == IMClientManager.shareInstance().accountId {
                        isQuitGroup = true
                        break
                    }
                }
                if isQuitGroup {
                    var frendManager = IMClientManager.shareInstance().frendManager
                    frendManager.deleteFrendFromDB(group.groupId)
                } else {
                    self.deleteNumbersFromGroup(members: members, group: group)

                }
                completion(isSuccess: true, errorCode: 0)
            } else {
                completion(isSuccess: false, errorCode: 0)
            }
        }
    }
    
    /**
    更新数据库里群组信息
    
    :param: group
    */
    func updateGroupNumbersInDB(group: IMDiscussionGroup) {
        var frend = self.convertDiscussionGroupModel2FrendModel(group)
        var frendManager = IMClientManager.shareInstance().frendManager
        frendManager.updateExtDataInDB(frend.extData as String, userId: frend.userId)
    }

    /**
    更新数据库里相关群组的信息
    
    :param: group
    */
    func updateGroupInfoInDB(group: IMDiscussionGroup) {
        var frend = self.convertDiscussionGroupModel2FrendModel(group)
        var frendManager = IMClientManager.shareInstance().frendManager
        let exitFrend = frendManager.getFrendInfoFromDB(userId: frend.userId, frendType: IMFrendWeightType.DiscussionGroup)
        if frend.extData == "" {
            frend.extData = exitFrend?.extData ?? ""
        }
        frendManager.insertOrUpdateFrendInfoInDB(frend)
    }
    
    /**
    将一个群组转换成一个frendmodel
    
    :param: group
    
    :returns:
    */
    func convertDiscussionGroupModel2FrendModel(group: IMDiscussionGroup) -> FrendModel {
        var frendModel = FrendModel()
        frendModel.userId = group.groupId
        frendModel.nickName = group.subject ?? ""
        frendModel.type = IMFrendType.DiscussionGroup
        var numberDic = NSMutableDictionary()
        if group.members.count > 0 {
            var array = Array<NSDictionary>()
            for frend in group.members {
                let dic = ["userId": frend.userId, "nickName": frend.nickName, "avatar": frend.avatar]
                array.append(dic)

            }
            numberDic.setObject(array, forKey: "members")
        }
        numberDic.setObject(group.owner, forKey: "creator")
        frendModel.extData = JSONConvertMethod.contentsStrWithJsonObjc(numberDic)!

        
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
        
        if let membersData = extData.objectForKey("members") as? Array<NSDictionary> {
            for userDic in membersData {
                let frend = FrendModel(json: userDic)
                discussionGroup.members.append(frend)
            }
        }
        if let owner = extData.objectForKey("creator") as? Int {
            discussionGroup.owner = owner
        }
        return discussionGroup
    }
    
    func getBasicDiscussionGroupInfo(#frendModel: FrendModel) -> IMDiscussionGroup {
        var discussionGroup = IMDiscussionGroup()
        discussionGroup.groupId = frendModel.userId
        discussionGroup.subject = frendModel.nickName
        return discussionGroup
    }
    
    
 //MARK: private function
    
    /**
    添加一组成员到群组的用户列表里。自动幂等，已有不添加
    
    :param: members
    :param: group
    */
    private func addNumbers2Group(#members: Array<FrendModel>, group: IMDiscussionGroup) {
        for frend in members {
            var find = false
            for oldFrend in group.members {
                if oldFrend.userId == frend.userId {
                    find = true
                    break
                }
            }
            if !find {
                group.members.append(frend)
            }
        }
        self.updateGroupNumbersInDB(group)
    }
    
    /**
    删除群组里的某一些成员
    
    :param: members
    :param: group
    */
    private func deleteNumbersFromGroup(#members: Array<Int>, group: IMDiscussionGroup) {
        var leftMembers = Array<FrendModel>()
        for userId in members {
            var find = false
            for oldFrend in group.members {
                if oldFrend.userId != userId {
                    leftMembers.append(oldFrend)
                }
            }
        }
        group.members = leftMembers
        self.updateGroupNumbersInDB(group)
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
            var frendManager = IMClientManager.shareInstance().frendManager
            frendManager.addFrend2DB(frendModel)
        }
    }
    
    //MARK: CMDMessageManagerDelegate
    
    func receiveDiscussiongGroupCMDMessage(cmdMessage: IMCMDMessage) {
        self.dispatchCMDMessage(cmdMessage)
    }
}



