//
//  IMRestaurantMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 5/15/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class IMRestaurantMessage: BaseMessage {
    
    var restaurantId: String!
    var poiName: String?
    var image: String?
    var rating: String?
    var address: String?
    var price: String?
    var poiModel: IMPoiModel!
    
    override init() {
        super.init()
        messageType = IMMessageType.RestaurantMessageType
    }
    
    override func fillContentWithContent(contents: String) {
        var imageDic = super.jsonObjcWithString(contents)
        self.fillContentWithContentDic(imageDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        poiModel = IMPoiModel()
        if let id = contentsDic.objectForKey("id") as? String {
            restaurantId = id
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
        if let price = contentsDic.objectForKey("price") as? String {
            self.price = price
            poiModel.price = price
        }
        if let rating = contentsDic.objectForKey("rating") as? String {
            self.rating = rating
            poiModel.rating = rating
        }
        if let address = contentsDic.objectForKey("address") as? String {
            self.address = address
            poiModel.address = address
        }
    }

   
}
