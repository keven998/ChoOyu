//
//  QuestionModel.swift
//  PeachTravel
//
//  Created by liangpengshuai on 7/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class QuestionModel: NSObject {
    
    var title: String?
    var subtitle: String?
    var imageUrl: String?
    var url: String?
    
    init(json: NSDictionary) {
        title = json.objectForKey("title") as? String
        subtitle = json.objectForKey("desc") as? String
        imageUrl = json.objectForKey("image") as? String
        url = json.objectForKey("url") as? String
    }
   
}
