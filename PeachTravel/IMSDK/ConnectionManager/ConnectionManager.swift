//
//  ConnectionManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

let getuiDidConnectionNoti = "getuiDidConnectionNoti"

@objc protocol ConnectionManagerDelegate {
    func connectionSetup(isSuccess: Bool, errorCode: Int);
}

private let connectionManager = ConnectionManager()

class ConnectionManager: NSObject, PushConnectionDelegate {
    
    let pushSDKManager = PushSDKManager.shareInstance()
    weak var connectionManagerDelegate: ConnectionManagerDelegate?
    var registionId: String?
    
    private var userId: Int?
    
    class func shareInstance() -> ConnectionManager {
        return connectionManager
    }
    
    override init() {
        super.init()

        if let cacheId = NSUserDefaults.standardUserDefaults().objectForKey("registionId") as? String {
            registionId = cacheId;
        }
        pushSDKManager.pushConnectionDelegate = self
    }
    
    /**
    建立个推连接
    */
    func createPushConnection() {
        pushSDKManager.createPushConnection()
    }
    
    func bindUserIdWithRegistionId(userId: Int) {
        if (self.registionId != nil) {
            let manager = AFHTTPRequestOperationManager()
            let requestSerializer = AFJSONRequestSerializer()
            manager.requestSerializer = requestSerializer
            var accountManager = AccountManager.shareAccountManager()
            manager.requestSerializer.setValue("\(accountManager.account.userId)", forHTTPHeaderField: "UserId")
            manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
            manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            let params: NSDictionary = ["userId": userId, "regId": self.registionId!]
            
            manager.POST(HedyLoginUrl, parameters: params, success:
                {
                    (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                   
                })
                {
                    (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                   
            }

        }

    }
    
    //MARK:PushConnectionDelegate
    func getuiDidConnection(clientId: String) {
        registionId = clientId
        NSUserDefaults.standardUserDefaults().setObject(registionId, forKey: "registionId")
        NSNotificationCenter.defaultCenter().postNotificationName(getuiDidConnectionNoti, object: nil)
    }
    
}






