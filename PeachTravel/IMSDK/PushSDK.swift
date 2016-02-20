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

class PushSDKManager: NSObject, GeTuiSdkDelegate {
    
    private var pushSdkIsConnected: Bool = false
    
    var msgId:Int = 400

    var deviceToke:String?
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "networkChanged:", name: networkConnectionStatusChangeNoti, object: nil)
    }
    
    deinit {
        debug_print("PushSDKManager deinit")
    }
    
    func registerDeviceToken(token: String) {
        self.deviceToke = token
        GeTuiSdk.registerDeviceToken(token)
    }
    
    func networkChanged(noti:NSNotification) {
        if let userInfo = noti.userInfo {
            if let status = userInfo["status"] as? Int {
                if status == NetworkStatus.NotReachable.rawValue {
                    pushSdkIsConnected = false
                }
            }
        }
    }
    
    /**
    检查 push sdk 长链接的状态
    */
    @objc private func checkoutSDKStatus() {
        if !pushSdkIsConnected {
            debug_print("***** 个推 sdk 长链接未建立， 尝试重新建立中。******")
//            gexinSdk?.destroy()
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
        debug_print("正在建立 push 长链接。。。。。")
        GetuiPush.login()
    }
    
    //MARK: 个推 delegate
    /**
    个推sdk 出现问题
    :param: error
    */
    func GeTuiSdkDidOccurError(error: NSError!) {
        pushSdkIsConnected = false
        debug_print("*****  GeTuiSdkDidOccurError  ******")
    }
    
    func GeTuiSDkDidNotifySdkState(aStatus: SdkStatus) {
        debug_print("*****GeTuiSDkDidNotifySdkState \(aStatus)")
    }
    
    /**
    收到透传消息
    :param: payloadId 透传消息内容
    :param: appId     来自的 id
    */
    
    func GeTuiSdkDidReceivePayload(payloadId: String!, andTaskId taskId: String!, andMessageId aMsgId: String!, fromApplication appId: String!) {
        let payload = GeTuiSdk.retrivePayloadById(payloadId)
        let length = payload?.length
        let bytes = payload?.bytes
        let payloadMsg = NSString(bytes:bytes! , length: length!, encoding: NSUTF8StringEncoding)
        
        // 收到消息后分发出去
        if let message = payloadMsg {
            dispatchPushMessage(message)

            
//            let content = ["title":"卖家已取消订单", "text":"卖家已经取消订单，如有疑问请与卖家联系,我这没有票了，实在不要意思了" ,"commodityName":"军都山滑雪【全天】", "orderId":2015123412834123]
//            let str: NSString = JSONConvertMethod.contentsStrWithJsonObjc(content)!
//            
//            let messageDic =  [ "id" : "55addff01ae2400001cde012", "chatType" : "single","msgId" : msgId, "msgType" : 20,"conversation" : "55f8d952d11489000126adbd", "contents" : str,"senderId" : 201032,"abbrev" : "煎蛋小哈哈: 看到觉得基督教", "timestamp" : 1449142842951, "receiverId" : 202847 ]
//            
//            let dic: NSDictionary =
//            [
//                "routingKey" : "IM", "message" : messageDic
//            ]
//            let totalStr: NSString = JSONConvertMethod.contentsStrWithJsonObjc(dic)!
//            
//            dispatchPushMessage(totalStr)
            
//            let content = ["title":"恭喜你获得1000元优惠券"]
//            let str: NSString = JSONConvertMethod.contentsStrWithJsonObjc(content)!
//            
//            let messageDic =  [ "id" : "55addff01ae2400001cde012", "chatType" : "single","msgId" : 200, "msgType" : 21,"conversation" : "55f8d952d11489000126adbd", "contents" : str,"senderId" : 100044,"abbrev" : "煎蛋小哈哈: 看到觉得基督教", "timestamp" : 1449142842951, "receiverId" : 201032 ]
//            
//            let dic: NSDictionary =
//            [
//                "routingKey" : "IM", "message" : messageDic
//            ]
//            let totalStr: NSString = JSONConvertMethod.contentsStrWithJsonObjc(dic)!
//            
//            dispatchPushMessage(totalStr)
//
//            msgId++
            
        }
    }
    
    /**
    分发给不同监听者不同的消息
    
    :param: message 需要分发的消息
    */
    func dispatchPushMessage(message: NSString) {
        
        debug_print("dispatchPushMessage: \(message)")
        let dispatchMessageDic: NSDictionary
        let mseesageData = message.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        do {
            let messageJson: AnyObject? = try NSJSONSerialization.JSONObjectWithData(mseesageData!, options: .AllowFragments)
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
            
        } catch {
            debug_print("消息解析失败")
        }
    }
    
    /**
    个推注册成功,相当于 client 登录成功
    :param: clientId 注册成功后的 id
    */
    func GeTuiSdkDidRegisterClient(clientId: String!) {
        debug_print("push 长链接建立成功")
        if let token = self.deviceToke {
            GeTuiSdk.registerDeviceToken(token)
        }
        pushSdkIsConnected = true
        pushConnectionDelegate?.getuiDidConnection(clientId)
    }
}

class GetuiPush: GeTuiSdk {
    
    class func login() {
        let kAppKey = "O2ooToqPrsAGJYy3iZ54d7"
        let kAppId = "aGqQz4HiLg70iOUXheRSZ3"
        let kAppSecret = "HBD1EqFmJF78PnWEy5KEM5"
        
        let pushSDKManager = PushSDKManager.shareInstance()
        let err: NSErrorPointer = NSErrorPointer()
        GeTuiSdk.startSdkWithAppId(kAppId, appKey: kAppKey, appSecret: kAppSecret, delegate: pushSDKManager, error: err)
    }
    
    deinit {
        debug_print("GetuiPush deinit")
    }
}








