//
//  GoodsChatMessage.swift
//  PeachTravel
//
//  Created by liangpengshuai on 12/8/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

import UIKit

class GoodsChatMessage: BaseMessage {
    
    var goodsName: String?
    var price: Float = 0.0
    var goodsId: Int = 0
    var imageUrl: String?
    
    override init() {
        super.init()
        messageType = IMMessageType.GoodsMessageType
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        goodsId = contentsDic.objectForKey("commodityId") as! Int
        goodsName = contentsDic.objectForKey("title") as? String
        imageUrl = contentsDic.objectForKey("image") as? String
        price = (contentsDic.objectForKey("price") as? Float)!

        
    }
    
    override func fillContentWithContent(contents: String) {
        let messageDic = JSONConvertMethod.jsonObjcWithString(contents)
        self.fillContentWithContentDic(messageDic)
    }
}
