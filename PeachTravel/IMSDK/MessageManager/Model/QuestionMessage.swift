//
//  QuestionMessage.swift
//  PeachTravel
//
//  Created by liangpengshuai on 7/21/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

class QuestionMessage: BaseMessage {
    
    var questionList: Array<QuestionModel> = Array()
    
    override func fillContentWithContent(contents: String) {
        var messageDic = JSONConvertMethod.jsonObjcWithString(contents)
        self.fillContentWithContentDic(messageDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        var tempArray = Array<QuestionModel>()
        if let questionArray = contentsDic.objectForKey("questions") as? Array<NSDictionary> {
            for dic in questionArray {
                let questionModel = QuestionModel(json: dic)
                tempArray.append(questionModel)
            }
        }
    }
   
}
