//
//  OrderTipsMessage.swift
//  PeachTravel
//
//  Created by liangpengshuai on 12/7/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

import UIKit

class OrderTipsMessage: BaseMessage {
    var title: String?
    var content: String?
    var orderId: Int = 0
    var goodsName: String?
    
    override init() {
        super.init()
        messageType = IMMessageType.OrderTipsMessageType
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        title = contentsDic.objectForKey("title") as? String
        content = contentsDic.objectForKey("text") as? String
        orderId = contentsDic.objectForKey("orderId") as! Int
        goodsName = contentsDic.objectForKey("title") as? String
    }
    
    override func fillContentWithContent(contents: String) {
        let imageDic = JSONConvertMethod.jsonObjcWithString(contents)
        self.fillContentWithContentDic(imageDic)
    }
}
