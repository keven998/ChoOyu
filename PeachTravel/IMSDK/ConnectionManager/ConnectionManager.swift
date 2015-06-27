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
        pushSDKManager.pushConnectionDelegate = self
    }
    
    /**
    登录
    :param: userId   用户名
    :param: password 密码
    */
    func createPushConnection() {
        pushSDKManager.createPushConnection()
    }
    
    //MARK:PushConnectionDelegate
    func getuiDidConnection(clientId: String) {
        registionId = clientId
        NSNotificationCenter.defaultCenter().postNotificationName(getuiDidConnectionNoti, object: nil)
    }
}






