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
    var subject: String!
    var type: IMFrendType = .DiscussionGroup
    var numbers: Array<FrendModel> = Array()
    
    init(jsonData: NSDictionary) {
        groupId = jsonData.objectForKey("groupId") as! Int
        subject = jsonData.objectForKey("name") as! String
    }
    
    func updateNumbersInGroup(jsonData: Array<NSDictionary>) {
        for frendDic in jsonData {
            let frend = FrendModel(json: frendDic)
            let frendManager = FrendManager(userId: AccountManager.shareAccountManager().account.userId)
            frendManager.addFrend2DB(frend)
            numbers.append(frend)
        }
    }
    
    override init() {
        super.init()
    }

}
