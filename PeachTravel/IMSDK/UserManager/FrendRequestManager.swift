//
//  FrendRequestManager.swift
//  PeachTravel
//
//  Created by liangpengshuai on 6/30/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class FrendRequestManager: NSObject {
    
    var frendRequestList: Array<FrendRequest> = Array()
    let frendRequestDaoHelper: FrendRequestDaoHelper
    let accountId: Int
    var unReadFrendRequestCount: Int {
        get {
            var count = 0
            for frendRequest in self.frendRequestList {
                if frendRequest.status == TZFrendRequest.Default {
                    count++
                }
            }
            return count
        }
    }
    
    init(userId: Int) {
        accountId = userId
        var dbPath: String = documentPath.stringByAppendingPathComponent("\(accountId)/user.sqlite")
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
        if request.isKindOfClass(FrendRequest) {
            self.frendRequestDaoHelper.addFrendRequestion2DB(request as! FrendRequest)
            self.frendRequestList.append(request as! FrendRequest)
            
        } else {
            let frendReuqest = FrendRequest(json: request)
            self.frendRequestDaoHelper.addFrendRequestion2DB(request as! FrendRequest)
            self.frendRequestList.append(request as! FrendRequest)

        }
    }
    
    /**
    添加一个好友请求
    
    :param: request
    */
    func addFrendRequestList(request: FrendRequest) {
        for tempRequest in frendRequestList {
            if tempRequest.requestId == (request).requestId {
                return
            }
        }
        frendRequestList.append(request)
        frendRequestDaoHelper.addFrendRequestion2DB(request)
    }
    
    /**
    移除一个好友请求
    
    :param: requestId
    */
    func removeFrendRequest(requestId: String) {
        frendRequestList.filter({$0.requestId != requestId}
        )
        frendRequestDaoHelper.removeFrendRequest(requestId)
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
    }
}









