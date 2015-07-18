//
//  IMDiscussionGroup.swift
//  TZIM
//
//  Created by liangpengshuai on 5/12/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class IMDiscussionGroup: NSObject {
    
    var groupId: Int = -1
    var subject: String?
    var owner: Int = -1
    var type: IMFrendType = .DiscussionGroup
    var members: Array<FrendModel> = Array()
    
    init(jsonData: NSDictionary) {
        owner = jsonData.objectForKey("creator") as? Int ?? -1
        groupId = jsonData.objectForKey("groupId") as! Int
        subject = jsonData.objectForKey("name") as? String
    }
    
    func updateNumbersInGroup(jsonData: Array<NSDictionary>) {
        for frendDic in jsonData {
            let frend = FrendModel(json: frendDic)
            let frendManager = IMClientManager.shareInstance().frendManager
            frendManager.addFrend2DB(frend)
            members.append(frend)
        }
    }
    
    override init() {
        super.init()
    
    }

}
