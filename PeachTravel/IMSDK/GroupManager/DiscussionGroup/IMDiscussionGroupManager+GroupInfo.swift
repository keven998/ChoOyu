//
//  IMDiscussionGroupManager+groupInfo.swift
//  PeachTravel
//
//  Created by liangpengshuai on 5/27/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import Foundation

extension IMDiscussionGroupManager {
    
    /**
    获取简单的讨论组详情,不包括群组的用户列表
    
    :param: groupId
    
    :returns:
    */
    func getBasicDiscussionGroupInfoFromDB(#groupId: Int) -> IMDiscussionGroup? {
        let frendManager = IMClientManager.shareInstance().frendManager
        var frendModel = frendManager.getFrendInfoFromDB(userId: groupId)
        var retGroup: IMDiscussionGroup?
        
        if let frend = frendModel {
            retGroup = self.getBasicDiscussionGroupInfo(frendModel: frend)
        }
        return retGroup
    }
    
    /**
    获取群组的全部详情
    
    :param: groupId
    
    :returns:
    */
    func getFullDiscussionGroupInfoFromDB(#groupId: Int) -> IMDiscussionGroup? {
        let frendManager = IMClientManager.shareInstance().frendManager
        var frendModel = frendManager.getFrendInfoFromDB(userId: groupId)
        var retGroup: IMDiscussionGroup?
        
        if let frend = frendModel {
            retGroup = self.getFullDiscussionGroupInfo(frendModel: frend)
        }
        return retGroup
    }
    
    /**
    从网上获取讨论组信息
    
    :param: groupId
    :param: completion
    */
    func asyncGetDiscussionGroupInfoFromServer(groupId: Int, completion: (isSuccess: Bool, errorCode: Int, discussionGroup: IMDiscussionGroup?) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        let requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer = requestSerializer
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue("\(AccountManager.shareAccountManager().account.userId)", forHTTPHeaderField: "UserId")
        
        var url = "\(discussionGroupUrl)/\(groupId)"
        manager.GET(url, parameters: nil, success: {
            (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            if (responseObject.objectForKey("code") as! Int) == 0 {
                let resultDic = responseObject.objectForKey("result") as! NSDictionary
                let group = IMDiscussionGroup(jsonData: resultDic)
                self.updateGroupInfoInDB(group)
                completion(isSuccess: true, errorCode: 0, discussionGroup: group)
                
            } else {
                completion(isSuccess: false, errorCode: 0, discussionGroup: nil)
            }
        }) {
            (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            completion(isSuccess: false, errorCode: 0, discussionGroup: nil)
            debug_print(error)
        }
    }

    /**
    从网上获取讨论组的成员信息
    
    :param: groupId
    :param: completion 
    */
    func asyncGetMembersInDiscussionGroupInfoFromServer(group: IMDiscussionGroup, completion: (isSuccess: Bool, errorCode: Int, discussionGroup: IMDiscussionGroup?) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        let requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer = requestSerializer
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue("\(AccountManager.shareAccountManager().account.userId)", forHTTPHeaderField: "UserId")
        
        var url = "\(discussionGroupUrl)/\(group.groupId)/members"
        manager.GET(url, parameters: nil, success: {
            (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            if (responseObject.objectForKey("code") as! Int) == 0 {
                if let result = responseObject.objectForKey("result") as? Array<NSDictionary> {
                    group.updateNumbersInGroup(result)
                    self.updateGroupNumbersInDB(group)
                }
                completion(isSuccess: true, errorCode: 0, discussionGroup: group)
            } else {
                completion(isSuccess: false, errorCode: 0, discussionGroup: nil)
            }
            }) {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(isSuccess: false, errorCode: 0, discussionGroup: nil)
                debug_print(error)
        }
    }

    
    
    
    
    
    

    
}