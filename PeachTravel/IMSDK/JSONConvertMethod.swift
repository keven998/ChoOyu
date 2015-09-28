//
//  JSONConvertMethod.swift
//  PeachTravel
//
//  Created by liangpengshuai on 5/27/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//


class JSONConvertMethod: NSObject {

    // 将字符串转换成字典
    class func jsonObjcWithString(messageStr: String) -> NSDictionary {
        let messageData = messageStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        do {
            let messageJson: AnyObject? = try NSJSONSerialization.JSONObjectWithData(messageData!, options: .AllowFragments)
            if messageJson is NSDictionary {
                return messageJson as! NSDictionary
            } else {
                return NSDictionary()
            }
        } catch {
            return NSDictionary()
        }
    }
    
    class func contentsStrWithJsonObjc(messageDic: NSDictionary) -> NSString? {
        
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(messageDic, options: NSJSONWritingOptions.PrettyPrinted)
            let retStr = NSString(data:jsonData, encoding: NSUTF8StringEncoding)
            return retStr

        } catch {
            return nil
            
        }
    }
    
}



