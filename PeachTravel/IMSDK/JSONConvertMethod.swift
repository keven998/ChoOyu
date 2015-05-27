//
//  JSONConvertMethod.swift
//  PeachTravel
//
//  Created by liangpengshuai on 5/27/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//


class JSONConvertMethod: NSObject {

    class func jsonObjcWithString(messageStr: String) -> NSDictionary {
        var mseesageData = messageStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        var messageJson: AnyObject? = NSJSONSerialization.JSONObjectWithData(mseesageData!, options:.AllowFragments, error: nil)
        if messageJson is NSDictionary {
            return messageJson as! NSDictionary
        } else {
            return NSDictionary()
        }
    }
    
    class func contentsStrWithJsonObjc(messageDic: NSDictionary) -> NSString? {
        var jsonData = NSJSONSerialization.dataWithJSONObject(messageDic, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        var retStr = NSString(data:jsonData!, encoding: NSUTF8StringEncoding)
        return retStr
    }
    
}



