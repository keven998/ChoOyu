//
//  PushSDK.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

@objc protocol PushMessageDelegate {
    func receivePushMessage(messageStr: NSDictionary)
}

@objc protocol PushConnectionDelegate {
    func getuiDidConnection(clientId: String)
}


private let pushSDKManager = PushSDKManager()

class PushSDKManager: NSObject, GexinSdkDelegate {
    
    private var gexinSdk: GexinSdk?
    private var pushSdkIsConnected: Bool = false
    
    var msgId:Int = 200

    
    private var listenerQueue: NSMutableArray = NSMutableArray()
    
    weak var pushConnectionDelegate: PushConnectionDelegate?
    
    var timer: NSTimer?
    
    var allMessage = NSMutableArray()

    class func shareInstance() -> PushSDKManager {
        return pushSDKManager
    }
    
    override init() {
        super.init()
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("checkoutSDKStatus"), userInfo: nil, repeats: true)
    }
    
    deinit {
        println("PushSDKManager deinit")
    }
    
    func registerDeviceToken(token: String) {
        gexinSdk?.registerDeviceToken(token)
    }
    
    /**
    检查 push sdk 长链接的状态
    */
    func checkoutSDKStatus() {
        if !pushSdkIsConnected {
            println("***** 个推 sdk 长链接未建立， 尝试重新建立中。******")
            gexinSdk?.destroy()
            self.createPushConnection()
        }
    }
    
    /**
    注册消息的监听
    
    :param: monitor        监听的对象
    :param: withRoutingKey 需要监听消息的key
    */
    func addPushMessageListener(listener: PushMessageDelegate, withRoutingKey routingKey: String) {
        listenerQueue.addObject([routingKey: listener])
    }
    
    /**
    移除消息的监听者
    
    :param: listener   监听对象
    :param: routingKey 监听消息的 key
    */
    func removePushMessageListener(listener: PushMessageDelegate, withRoutingKey routingKey: String) {
        for value in listenerQueue {
            var listenerDic = value as! Dictionary<String, PushMessageDelegate>
            if let oldListener = listenerDic[routingKey] {
                if oldListener === listener {
                    listenerQueue.removeObject(value)
                    return
                }
            }
        }
    }
    
    /**
    登录
    */
    func createPushConnection() {
        println("正在建立 push 长链接。。。。。")
        gexinSdk = GetuiPush.login()
    }
    
    //MARK: 个推 delegate
    /**
    个推sdk 出现问题
    :param: error
    */
    func GexinSdkDidOccurError(error: NSError!) {
        pushSdkIsConnected = false
        println("*****  GexinSdkDidOccurError  ******")
    }
    
    /**
    收到透传消息
    :param: payloadId 透传消息内容
    :param: appId     来自的 id
    */
    func GexinSdkDidReceivePayload(payloadId: String!, fromApplication appId: String!) {
        var payload = gexinSdk?.retrivePayloadById(payloadId)
        var length = payload?.length
        var bytes = payload?.bytes
        var payloadMsg = NSString(bytes:bytes! , length: length!, encoding: NSUTF8StringEncoding)
        
        
        let questionDic = ["questions": [["title":"北京有哪些好吃的","image": "","url": "www.baidu.com", "test" : 123],
        ["title":"北京有哪些好吃的","image": "","url": "www.baidu.com", "test" : 123],
        ["title":"北京有哪些好吃的","image": "","url": "www.baidu.com", "test" : 123],
        ["title":"北京有哪些好吃的","image": "","url": "www.baidu.com", "test" : 123],
        ["title":"北京有哪些好吃的","image": "","url": "www.baidu.com", "test" : 123]
        ]]
        let str: NSString = JSONConvertMethod.contentsStrWithJsonObjc(questionDic)!
        
        let messageDic =  [ "id" : "55addff01ae2400001cde012", "chatType" : "single","msgId" : msgId,"msgType" : 17,"conversation" : "557fb20c5f15030001b38480", "contents" : str,"senderId" : 100068,"abbrev" : "煎蛋小哈哈: 看到觉得基督教", "timestamp" : 1437458416707, "receiverId" : 100044 ]
        
        msgId++
        
        let dic: NSDictionary =
        [
            "routingKey" : "IM", "message" : messageDic
        ]
        
        if let message = payloadMsg {
            dispatchPushMessage(JSONConvertMethod.contentsStrWithJsonObjc(dic)!)
        }
    }
    
    /**
    分发给不同监听者不同的消息
    
    :param: message 需要分发的消息
    */
    func dispatchPushMessage(message: NSString) {
        
        println("dispatchPushMessage: \(message)")
        let dispatchMessageDic: NSDictionary
        var mseesageData = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        var messageJson: AnyObject? = NSJSONSerialization.JSONObjectWithData(mseesageData!, options:.AllowFragments, error: nil)
        if messageJson is NSDictionary {
            dispatchMessageDic = messageJson?.objectForKey("message") as! NSDictionary
        } else {
            dispatchMessageDic = NSDictionary()
        }

        if let routingkey = messageJson?.objectForKey("routingKey") as? String {
            for value in listenerQueue {
                var listenerDic = value as! Dictionary<String, PushMessageDelegate>
                if let pushMessageDelegate = listenerDic[routingkey] {
                    pushMessageDelegate.receivePushMessage(dispatchMessageDic)
                }
            }
        }
    }
    
    /**
    个推注册成功,相当于 client 登录成功
    :param: clientId 注册成功后的 id
    */
    func GexinSdkDidRegisterClient(clientId: String!) {
        println("push 长链接建立成功")
        pushSdkIsConnected = true
        pushConnectionDelegate?.getuiDidConnection(clientId)
    }
}

class GetuiPush: GexinSdk {
    
    class func login() -> GexinSdk {
        let kAppKey = "O2ooToqPrsAGJYy3iZ54d7"
        let kAppId = "aGqQz4HiLg70iOUXheRSZ3"
        let kAppSecret = "HBD1EqFmJF78PnWEy5KEM5"
        
        var pushSDKManager = PushSDKManager.shareInstance()
        var err: NSErrorPointer = NSErrorPointer()
        return GexinSdk.createSdkWithAppId(kAppId, appKey: kAppKey, appSecret: kAppSecret, appVersion: "1.0.0", delegate:pushSDKManager, error: err)
    }
    
    deinit {
        println("GetuiPush deinit")
    }
}








