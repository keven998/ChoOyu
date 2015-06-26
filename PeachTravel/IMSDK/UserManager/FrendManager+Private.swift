//
//  FrendManager+Private.swift
//  PeachTravel
//
//  Created by liangpengshuai on 5/26/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import Foundation

let API_USERINFO = "\(BASE_URL)users/"


extension FrendManager {
    
    func loadUserInfoFromServer(userId: Int, completion: (isSuccess: Bool, errorCode: Int, frendInfo: FrendModel?) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        let requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer = requestSerializer
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue("\(AccountManager.shareAccountManager().account.userId)", forHTTPHeaderField: "UserId")

        var url = "\(API_USERINFO)\(userId)"
        manager.GET(url, parameters: nil, success:
            { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                
                if (responseObject.objectForKey("code") as! Int) == 0 {
                    let resultDic = responseObject.objectForKey("result") as! NSDictionary
                    var frend = FrendModel(json: resultDic)
                    self.addFrend2DB(frend);
                    completion(isSuccess: true, errorCode: 0, frendInfo: frend)
                } else {
                    completion(isSuccess: false, errorCode: 0, frendInfo: nil)
                }
            }){
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(isSuccess: false, errorCode: 0, frendInfo: nil)
                print(error)
        }
    
    }
}