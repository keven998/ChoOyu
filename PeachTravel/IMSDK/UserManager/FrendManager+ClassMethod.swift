//
//  FrendManager+Private.swift
//  PeachTravel
//
//  Created by liangpengshuai on 5/26/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import Foundation

let API_USERS = "\(BASE_URL)users/"

extension FrendManager {
    
    /// 从服务器加载用户信息
    class func loadUserInfoFromServer(userId: Int, completion: (isSuccess: Bool, errorCode: Int, frendInfo: FrendModel?) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        let requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer = requestSerializer
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue("\(AccountManager.shareAccountManager().account.userId)", forHTTPHeaderField: "UserId")


        var url = "\(API_USERS)\(userId)"
        
        println("\(url)")
        manager.GET(url, parameters: nil, success:
            { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                
                println("\(url)")
                if (responseObject.objectForKey("code") as! Int) == 0 {
                    let resultDic = responseObject.objectForKey("result") as! NSDictionary
                    debug_println("\(resultDic)");
                    var frend = FrendModel(json: resultDic)
                    completion(isSuccess: true, errorCode: 0, frendInfo: frend)
                } else {
                    completion(isSuccess: false, errorCode: 0, frendInfo: nil)
                }
            }){
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(isSuccess: false, errorCode: 0, frendInfo: nil)
                debug_print(error)
        }
    
    }
}