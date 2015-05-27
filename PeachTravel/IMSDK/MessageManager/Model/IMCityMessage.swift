//
//  IMCityMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 5/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class IMCityMessage: BaseMessage {
    
    var poiId: String!
    var poiName: String?
    var image: String?
    var desc: String?
    var poiModel: IMPoiModel!
    
    override init() {
        super.init()
        messageType = IMMessageType.CityPoiMessageType
    }
    
    override func fillContentWithContent(contents: String) {
        var imageDic = JSONConvertMethod.jsonObjcWithString(contents)
        self.fillContentWithContentDic(imageDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        poiModel = IMPoiModel()
        if let id = contentsDic.objectForKey("id") as? String {
            poiId = id
            poiModel.poiId = id
        }
        if let name = contentsDic.objectForKey("name") as? String {
            poiName = name
            poiModel.poiName = name
        }
        if let image = contentsDic.objectForKey("image") as? String {
            self.image = image
            poiModel.image = image
        }
        if let desc = contentsDic.objectForKey("desc") as? String {
            self.desc = desc
            poiModel.desc = desc
        }
    }
   
}
