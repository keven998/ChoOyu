//
//  GoodsLinkMessage.swift
//  PeachTravel
//
//  Created by liangpengshuai on 12/7/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

import UIKit

class GoodsLinkMessage: BaseMessage {
    var goodsName: String?
    var price: Float = 0.0
    var goodsId: Int = 0
    var imageUrl: String?
    
    override init() {
        super.init()
        messageType = IMMessageType.GoodsLinkMessageType
    }

    override func fillContentWithContentDic(contentsDic: NSDictionary) {

    }
    
    override func fillContentWithContent(contents: String) {
    }
}
