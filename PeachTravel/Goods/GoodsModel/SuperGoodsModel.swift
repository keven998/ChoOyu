//
//  SuperGoodsModel.swift
//  PeachTravel
//
//  Created by liangpengshuai on 10/17/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

import UIKit

class SuperGoodsModel: NSObject {
    
    var goodsId: String?
    var zhName: String?
    var enName: String?
    var desc: String?
    var originalPrice: Int?
    var minPrice: Int?
    var userInfo: FrendModel?
    var rating: Float?
    var sales: Int?
    var tags: Array<String>?
    var images: Array<TaoziImage>?

    override init() {
        super.init()
        zhName = "泰国人妖展"
        desc = "大家好，我是一段自我介绍，请忽略我，哈哈哈，我就是测试测试，请大家忽略我，哈哈哈哈哈说两句付款说两句"
        let user = FrendModel()
        user.nickName = "hehceo"
        userInfo = user;
        tags = ["免费体验", "免费体验","免费体验"]
        rating = 0.9
        minPrice = 1000
        originalPrice = 1500
    }
    
    init(json: NSDictionary) {
        zhName = "泰国人妖展"
        desc = "大家好，我是一段自我介绍，请忽略我，哈哈哈，我就是测试测试，请大家忽略我，哈哈哈哈哈说两句付款说两句"
        let user = FrendModel()
        user.nickName = "hehceo"
        userInfo = user;
        tags = ["免费体验"]
        rating = 0.9
        minPrice = 1000
        originalPrice = 1500
        
        super.init()
    }
}
