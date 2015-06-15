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
        var daoHelper = DaoHelper.shareInstance()
        var frendModel = daoHelper.selectFrend(userId: groupId)
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
        var daoHelper = DaoHelper.shareInstance()
        var frendModel = daoHelper.selectFrend(userId: groupId)
        var retGroup: IMDiscussionGroup?
        
        if let frend = frendModel {
            retGroup = self.getFullDiscussionGroupInfo(frendModel: frend)
        }
        return retGroup
    }
    
}