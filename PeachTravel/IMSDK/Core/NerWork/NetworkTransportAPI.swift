//
//  NetworkTransportManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/20/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class NetworkTransportAPI: NSObject {
    
    /**
    向服务器发送一条消息
    
    :param: message         消息的格式
    :param: completionBlock 完成后的回掉
    */
    class func asyncSendMessage(message: NSDictionary, completionBlock: (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> ()) {
        debug_print("发送消息接口\(message)")
        debug_print("链接\(sendMessageURL)")
        LXPNetworking.POST(sendMessageURL, parameters: message, success:
            {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                if let code = responseObject.objectForKey("code") as? Int {
                    if code == 0 {
                        completionBlock(isSuccess: true, errorCode: 0, retMessage: responseObject.objectForKey("result") as? NSDictionary)
                    } else {
                        completionBlock(isSuccess: false, errorCode: 0, retMessage: nil)
                    }
                }
            })
            {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                debug_print(error)
                completionBlock(isSuccess: false, errorCode: 0, retMessage: operation.responseObject as? NSDictionary)
        }
    }
    
    /**
    发送一个 post 请求
    
    :param: url             请求的 url
    :param: parameters      post 参数
    :param: completionBlock 请求的回掉
    */
    class func asyncPOST(requstUrl requstUrl: String, parameters: NSDictionary, completionBlock: (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> ()) {
        LXPNetworking.POST(requstUrl, parameters: parameters, success:
            {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                
                debug_print("responseObject: \(responseObject)")
                if let code = responseObject.objectForKey("code") as? Int {
                    if code == 0 {
                        completionBlock(isSuccess: true, errorCode: 0, retMessage: responseObject.objectForKey("result") as? NSDictionary)
                    } else {
                        completionBlock(isSuccess: false, errorCode: 0, retMessage: nil)
                    }
                }
            })
            {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                debug_print(error)
                completionBlock(isSuccess: false, errorCode: 0, retMessage: nil)
        }
    }
    
    /**
    发送一个 delete 请求
    
    :param: url             请求的 url
    :param: parameters      post 参数
    :param: completionBlock 请求的回掉
    */
    class func asyncDELETE(requstUrl requstUrl: String, parameters: NSDictionary, completionBlock: (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> ()){
        
        LXPNetworking.DELETE(requstUrl, parameters: parameters, success: { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            if let code = responseObject.objectForKey("code") as? Int {
                if code == 0 {
                    completionBlock(isSuccess: true, errorCode: 0, retMessage: responseObject.objectForKey("result") as? NSDictionary)
                } else {
                    completionBlock(isSuccess: false, errorCode: 0, retMessage: nil)
                }
            }

        }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            completionBlock(isSuccess: false, errorCode: 0, retMessage: nil)
        }
    }
    
    class func asyncPATCH(requstUrl requstUrl: String, parameters: NSDictionary, completionBlock: (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> ()) {
        
        LXPNetworking.PATCH(requstUrl, parameters: parameters, success:
            {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                
                debug_print("responseObject: \(responseObject)")
                if let code = responseObject.objectForKey("code") as? Int {
                    if code == 0 {
                        completionBlock(isSuccess: true, errorCode: 0, retMessage: responseObject.objectForKey("result") as? NSDictionary)
                    } else {
                        completionBlock(isSuccess: false, errorCode: 0, retMessage: nil)
                    }
                }
            })
            {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                debug_print(error)
                completionBlock(isSuccess: false, errorCode: 0, retMessage: nil)
        }
    }
    
    /**
    发送一个 GET 请求
    
    :param: url             请求的 url
    :param: parameters      post 参数
    :param: completionBlock 请求的回掉
    */
    class func asyncGET(requestUrl requestUrl: String, parameters: NSDictionary?, completionBlock: (isSuccess: Bool, errorCode: Int, retMessage: AnyObject?) -> ()) {

        LXPNetworking.GET(requestUrl, parameters: parameters, success:
            {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                
                if let code = responseObject.objectForKey("code") as? Int {
                    if code == 0 {
                        completionBlock(isSuccess: true, errorCode: 0, retMessage: responseObject.objectForKey("result"))
                    } else {
                        completionBlock(isSuccess: false, errorCode: 0, retMessage: nil)
                    }
                }
            })
            {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                debug_print(error)
                completionBlock(isSuccess: false, errorCode: 0, retMessage: nil)
        }
    }
    
    /**
    发送一个 PUT 请求
    
    :param: url             请求的 url
    :param: parameters      post 参数
    :param: completionBlock 请求的回掉
    */
    class func asyncPUT(requestUrl requestUrl: String, parameters: NSDictionary, completionBlock: (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> ()) {
        
        LXPNetworking.PUT(requestUrl, parameters: parameters, success:
            {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                
                debug_print("responseObject: \(responseObject)")
                if let code = responseObject.objectForKey("code") as? Int {
                    if code == 0 {
                        completionBlock(isSuccess: true, errorCode: 0, retMessage: responseObject.objectForKey("result") as? NSDictionary)
                    } else {
                        completionBlock(isSuccess: false, errorCode: 0, retMessage: nil)
                    }
                }
            })
            {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                debug_print(error)
                completionBlock(isSuccess: false, errorCode: 0, retMessage: nil)
        }
    }
    
    /**
    fetch 消息
    
    :param: userId          fetch谁的消息
    :param: completionBlock fetch 后的回掉
    */
    class func asyncACKMessage(userId: Int, lastFetchTime: Int?, completionBlock: (isSuccess: Bool, errorCode: Int, timestamp: Int?, retMessage: NSArray?) -> ()) {
        let params = ["purgeBefore": lastFetchTime ?? 0]
        
        debug_print("ACK接口,收取用户\(userId) 的未读消息")
        
        let url = HedyUserUrl+"/\(userId)"+"/messages"
        
        LXPNetworking.POST(url, parameters: params, success:
        {
        (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            if let reslutDic = responseObject.objectForKey("result") as? NSArray {
                completionBlock(isSuccess: true, errorCode: 0, timestamp: responseObject.objectForKey("timestamp") as? Int, retMessage: reslutDic)
                
            } else {
                completionBlock(isSuccess: false, errorCode: 0, timestamp: nil, retMessage: nil)
            }
        })
        {
        (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
        debug_print(error)
            completionBlock(isSuccess: false, errorCode: 0, timestamp: nil, retMessage: nil)
        }
    }
}







