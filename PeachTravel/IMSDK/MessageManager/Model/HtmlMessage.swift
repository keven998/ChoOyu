//
//  HtmlMessage.swift
//  PeachTravel
//
//  Created by liangpengshuai on 7/31/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class HtmlMessage: BaseMessage {
   
    var title: String?
    var subtitle: String?
    var imageUrl: String?
    var url: String?

    override init() {
        super.init()
        messageType = IMMessageType.Html5MessageType
    }
    
    override func fillContentWithContent(contents: String) {
        var messageDic = JSONConvertMethod.jsonObjcWithString(contents)
        self.fillContentWithContentDic(messageDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        title = contentsDic.objectForKey("title") as? String
        subtitle = contentsDic.objectForKey("desc") as? String
        imageUrl = contentsDic.objectForKey("image") as? String
        url = contentsDic.objectForKey("url") as? String
    }

}

