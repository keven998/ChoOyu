//
//  ImageMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 4/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class ImageMessage: BaseMessage {
    var imageHeight: Int = 0
    var imageWidth: Int = 0
    var imageRatio: Float = 0
    var localPath: String?
    var originUrl: String?
    var thumbUrl: String?
    var fullUrl: String?
    
    override init() {
        super.init()
        messageType = .ImageMessageType
    }

    override func fillContentWithContent(contents: String) {
        var imageDic = super.jsonObjcWithString(contents)
        self.fillContentWithContentDic(imageDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        if let height = contentsDic.objectForKey("height") as? Int {
            imageHeight = height;
        }
        if let width = contentsDic.objectForKey("width") as? Int {
            imageWidth = width;
        }
        originUrl = contentsDic.objectForKey("origin") as? String
        thumbUrl = contentsDic.objectForKey("thumb") as? String
        fullUrl = contentsDic.objectForKey("full") as? String
        if let imageId = contentsDic.objectForKey("metadataId") as? String {
            localPath = AccountManager.shareAccountManager().userChatImagePath.stringByAppendingPathComponent("\(imageId).jpeg")
        }
    }
    
    /**
    更新消息的主体内容，一般是下载附件完成后填入新的 metadataId
    */
    func updateMessageContent() {
        var imageDic: NSMutableDictionary = super.jsonObjcWithString(message).mutableCopy() as! NSMutableDictionary
        if let metadataId = metadataId {
            imageDic.setObject(metadataId, forKey: "metadataId")
            if let content = super.contentsStrWithJsonObjc(imageDic) {
                message = content as String
            }
        }
    }
    

}
