//
//  FrendRequestManager.swift
//  PeachTravel
//
//  Created by liangpengshuai on 6/30/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

@objc protocol FriendRequestManagerDelegate {
    
    optional func friendRequestNumberNeedUpdate()

}


class FrendRequestManager: NSObject {
    
    var frendRequestList: Array<FrendRequest> = Array()
    let frendRequestDaoHelper: FrendRequestDaoHelper
    var delegateArray: Array<FriendRequestManagerDelegate> = Array()
    let accountId: Int
    var unReadFrendRequestCount: Int {
        get {
            return self.frendRequestList.filter({$0.status == TZFrendRequest.Default}).count
        }
    }
    
    /**
    初始化
    
    :param: userId 用户ID
    
    :returns: 管理对象
    */
    init(userId: Int) {
        accountId = userId
        let dbPath: String = documentPath.stringByAppendingPathComponent("\(accountId)/user.sqlite")
        let db = FMDatabase(path: dbPath)
        let dbQueue = FMDatabaseQueue(path: dbPath)
        frendRequestDaoHelper = FrendRequestDaoHelper(db: db, dbQueue: dbQueue)
        frendRequestList = frendRequestDaoHelper.getAllFrendRequest()
    }
    
    func addFrendRequestDelegate(delegate: FriendRequestManagerDelegate) {
        delegateArray.append(delegate)
    }
    
    // 移除代理
    func removeFrendRequestDelegate(delegate: FriendRequestManagerDelegate) {
        delegateArray = delegateArray.filter({$0 === delegate})
    }
    
    
    /**
    添加一个好友请求
    
    :param: request
    */
    func addFrendRequest(request: AnyObject) {
        var frendRequest: FrendRequest
        if request.isKindOfClass(FrendRequest) {
            frendRequest = request as! FrendRequest
        } else {
            frendRequest = FrendRequest(json: request)
        }
        
        var index = 0
        for temp in self.frendRequestList {
            if temp.requestId == frendRequest.requestId {
                if temp.status != TZFrendRequest.Default {
                    self.frendRequestList.removeAtIndex(index)
                    self.frendRequestDaoHelper.removeFrendRequest(frendRequest.requestId)
                    break
                    
                } else {
                    debug_println("已经有相同的好友请求了，不需要再次添加了")
                    return
                }
            }
            index++
        }
        self.frendRequestDaoHelper.addFrendRequestion2DB(frendRequest)
        self.frendRequestList.append(frendRequest)
        for delegate in delegateArray {
            delegate.friendRequestNumberNeedUpdate?()
        }
        let key = "\(kShouldShowUnreadFrendRequestNoti)_\(accountId)"

        NSUserDefaults.standardUserDefaults().setBool(true, forKey: key)
    }
    
    /**
    移除一个好友请求
    
    :param: requestId
    */
    func removeFrendRequest(requestId: String) {
        frendRequestList = frendRequestList.filter({$0.requestId != requestId}
        )
        frendRequestDaoHelper.removeFrendRequest(requestId)
        for delegate in delegateArray {
            delegate.friendRequestNumberNeedUpdate?()
        }
    }
    
    /**
    修改好友请求的状态
    
    :param: requestId
    :param: status
    */
    func changeStatus(requestId: String, status: TZFrendRequest) {
        frendRequestList.map({(var request) -> FrendRequest in
            if request.requestId == requestId {
                request.status = status 
            }
            return request
        })
        frendRequestDaoHelper.changeFrendRequestStatus(requestId, status: status)
        for delegate in delegateArray {
            delegate.friendRequestNumberNeedUpdate?()
        }
    }

}









