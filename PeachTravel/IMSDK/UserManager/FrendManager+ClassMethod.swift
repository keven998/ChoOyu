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
        
        if(AccountManager.shareAccountManager().isLogin())
        {
            manager.requestSerializer.setValue("\(AccountManager.shareAccountManager().account.userId)", forHTTPHeaderField: "UserId")
        }
        let url = "\(API_USERS)\(userId)"
        
        debug_print("\(url)")
        
        manager.GET(url, parameters: nil, success: {
            (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in    
                if (responseObject.objectForKey("code") as! Int) == 0 {
                    let resultDic = responseObject.objectForKey("result") as! NSDictionary
                    debug_print("\(resultDic)");
                    let frend = FrendModel(json: resultDic)
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
    
    /// 从服务器加载达人信息
    class func loadExpertInfoFromServer(userId: Int, completion: (isSuccess: Bool, errorCode: Int, frendInfo: ExpertModel?) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        let requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer = requestSerializer
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        if(AccountManager.shareAccountManager().isLogin())
        {
            manager.requestSerializer.setValue("\(AccountManager.shareAccountManager().account.userId)", forHTTPHeaderField: "UserId")
        }
        let url = "\(API_USERS)\(userId)"
        
        manager.GET(url, parameters: nil, success: {
            (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            if (responseObject.objectForKey("code") as! Int) == 0 {
                let resultDic = responseObject.objectForKey("result") as! NSDictionary
                debug_print("\(resultDic)");
                let frend = ExpertModel(json: resultDic)
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
    
    /**
    从服务器上加载用户相册
    
    :param: userId     用户Id
    :param: completion 回调block
    :param: errorCode  错误码
    :param: frendModel 好友模型
    */
    class func loadUserAlbumFromServer(userId: Int,completion: (isSuccess: Bool, errorCode: Int, albumArray: NSArray) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        let requestSerializer = AFJSONRequestSerializer()
        manager.requestSerializer = requestSerializer
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        if(AccountManager.shareAccountManager().isLogin())
        {
            manager.requestSerializer.setValue("\(AccountManager.shareAccountManager().account.userId)", forHTTPHeaderField: "UserId")
        }

        let url = "\(API_USERS)\(userId)/albums"
        
        let albumArray : NSMutableArray = NSMutableArray()
        
        manager.GET(url, parameters: nil, success: {
            (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            if (responseObject.objectForKey("code") as! Int) == 0 {
                let resultArray = responseObject.objectForKey("result") as! NSArray
                debug_print("\(resultArray)");
                
                for album in resultArray {
                    let albumImage: AlbumImage = AlbumImage(json: album)
                    albumArray.addObject(albumImage)
                }
                
                completion(isSuccess: true, errorCode: 0, albumArray: albumArray)
            } else {
                completion(isSuccess: false, errorCode: 0, albumArray: albumArray)
            }
            }){
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                completion(isSuccess: false, errorCode: 0, albumArray: albumArray)
                debug_print(error)
        }
    }
}

