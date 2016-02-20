//
//  UserCouponMessage.swift
//  PeachTravel
//
//  Created by liangpengshuai on 2/20/16.
//  Copyright © 2016 com.aizou.www. All rights reserved.
//

import UIKit

class UserCouponMessage: BaseMessage {
    
    var title: String?
    
    override init() {
        super.init()
        messageType = IMMessageType.UserCouponMessageType
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        title = contentsDic.objectForKey("title") as? String
    }
    
    override func fillContentWithContent(contents: String) {
        let imageDic = JSONConvertMethod.jsonObjcWithString(contents)
        self.fillContentWithContentDic(imageDic)
    }

}
