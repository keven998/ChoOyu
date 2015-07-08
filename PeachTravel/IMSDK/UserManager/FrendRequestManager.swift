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
    let accountId: Int
    var delegate: FriendRequestManagerDelegate?
    var unReadFrendRequestCount: Int {
        get {
            return self.frendRequestList.filter({$0.status == TZFrendRequest.Default}).count
        }
    }
    
    init(userId: Int) {
        accountId = userId
        let dbPath: String = documentPath.stringByAppendingPathComponent("\(accountId)/user.sqlite")
        let db = FMDatabase(path: dbPath)
        let dbQueue = FMDatabaseQueue(path: dbPath)
        frendRequestDaoHelper = FrendRequestDaoHelper(db: db, dbQueue: dbQueue)
        frendRequestList = frendRequestDaoHelper.getAllFrendRequest()
    }
    
    /**
    添加一个好友请求
    
    :param: request
    */
    func addFrendRequest(request: AnyObject) {
        let frendRequest: FrendRequest
        if request.isKindOfClass(FrendRequest) {
            frendRequest = request as! FrendRequest
        } else {
            frendRequest = FrendRequest(json: request)
        }
        
        for temp in self.frendRequestList {
            if temp.requestId == frendRequest.requestId {
                println("已经有相同的好友请求了，不需要再次添加了")
                return
            }
        }
        self.frendRequestDaoHelper.addFrendRequestion2DB(request as! FrendRequest)
        self.frendRequestList.append(request as! FrendRequest)
        self.delegate?.friendRequestNumberNeedUpdate?()
    }
    
    /**
    移除一个好友请求
    
    :param: requestId
    */
    func removeFrendRequest(requestId: String) {
        frendRequestList = frendRequestList.filter({$0.requestId != requestId}
        )
        frendRequestDaoHelper.removeFrendRequest(requestId)
        self.delegate?.friendRequestNumberNeedUpdate?()
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
        self.delegate?.friendRequestNumberNeedUpdate?()
    }
}









