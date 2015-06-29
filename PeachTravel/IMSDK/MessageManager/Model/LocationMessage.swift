//
//  LocationMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 4/16/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class LocationMessage: BaseMessage {
    var longitude: Double = 0.0
    var latitude: Double = 0.0
    var address: String = ""
    var mapImageUrl: String?
    var localPath: String?

    
    override init() {
        super.init()
        messageType = .LocationMessageType
    }
    
    override func fillContentWithContent(contents: String) {
        var imageDic = JSONConvertMethod.jsonObjcWithString(contents)
        self.fillContentWithContentDic(imageDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        if let imageId = contentsDic.objectForKey("metadataId") as? String {
            localPath = IMClientManager.shareInstance().userChatImagePath.stringByAppendingPathComponent("\(imageId).jpeg")
        }
        if let lng = contentsDic.objectForKey("lng") as? Double {
            longitude = lng
        }
        if let lat = contentsDic.objectForKey("lat") as? Double {
            latitude = lat
        }
        if let addr = contentsDic.objectForKey("address") as? String {
            address = addr
        }
        if let url = contentsDic.objectForKey("snapshot") as? String {
            mapImageUrl = url
        }
    }
    
    /**
    更新消息的主体内容，一般是下载附件完成后填入新的 metadataId
    */
    func updateMessageContent() {
        var imageDic: NSMutableDictionary = JSONConvertMethod.jsonObjcWithString(message).mutableCopy() as! NSMutableDictionary
        if let metadataId = metadataId {
            imageDic.setObject(metadataId, forKey: "metadataId")
            if let url = mapImageUrl {
                imageDic.setObject(url, forKey: "snapshot")
            }
            imageDic.setObject(metadataId, forKey: "metadataId")
            
            if let content = JSONConvertMethod.contentsStrWithJsonObjc(imageDic) {
                message = content as String
            }
        }
    }

}

