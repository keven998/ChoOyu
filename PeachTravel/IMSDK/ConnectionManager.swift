//
//  ConnectionManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

@objc protocol ConnectionManagerDelegate {
    func connectionSetup(isSuccess: Bool, errorCode: Int);
}

class ConnectionManager: NSObject, PushConnectionDelegate {
    
    let pushSDKManager = PushSDKManager.shareInstance()
    weak var connectionManagerDelegate: ConnectionManagerDelegate?
    
    private var userId: Int?
    
    override init() {
        super.init()
        pushSDKManager.pushConnectionDelegate = self
    }
    
    /**
    登录
    :param: userId   用户名
    :param: password 密码
    */
    func login(userId:Int, password:String) {
        self.userId = userId
        pushSDKManager.login(userId, password: password)
    }

    //MARK:PushConnectionDelegate
    func getuiDidConnection(clientId: String) {
        println("GexinSdkDidRegisterClient： \(clientId)")
        var accountManager = AccountManager.shareAccountManager()
        NetworkUserAPI.asyncLogin(userId: self.userId!, registionId: clientId) { (isSuccess: Bool, errorCode: Int, retJson: NSDictionary?) -> () in
            self.connectionManagerDelegate?.connectionSetup(isSuccess, errorCode: 0)
           
        }
    }
}






