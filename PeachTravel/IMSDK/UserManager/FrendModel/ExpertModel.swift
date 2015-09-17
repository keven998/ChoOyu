//
//  ExpertModel.swift
//  PeachTravel
//
//  Created by liangpengshuai on 8/31/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class ExpertModel: FrendModel {
    
    // 个人点评和tags数组
    var profile: NSString = ""
    var allZone: NSArray = NSArray()
    
    override init(json: NSDictionary) {
        super.init(json: json)
        
        // 达人信息
        if let expertInfo = json.objectForKey("expertInfo") as? NSDictionary {
            if let pro = expertInfo.objectForKey("profile") as? String {
                profile = pro
            }
            if let zone = expertInfo.objectForKey("zone") as? NSArray {
                allZone = zone
            }
        }

    }
   
}
