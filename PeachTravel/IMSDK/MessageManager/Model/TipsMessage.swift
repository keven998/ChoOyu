//
//  TipsMessage.swift
//  PeachTravel
//
//  Created by liangpengshuai on 7/7/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

enum TipsMessageType: Int {
    case Add_GroupMember                     = 2001       //
    case Remove_GroupMember                  = 2002       //讨论组相关的 cmd 消息
    case Modify_GroupInfo                    = 2003      //群组相关的 cmd 消息
}

class TipsMessage: BaseMessage {
    var tipsMessageType: TipsMessageType?
    var tipsContent: String = ""
    
    override init() {
        super.init()
        messageType = .TipsMessageType
    }
    
    override func fillContentWithContent(contents: String) {
        var tipsDic = JSONConvertMethod.jsonObjcWithString(contents)
        self.fillContentWithContentDic(tipsDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        NSLog("Tips contentsDic", contentsDic)
        if let typeValue = contentsDic.objectForKey("tipType") as? Int {
            tipsMessageType = TipsMessageType(rawValue: typeValue)
            tipsContent = self.getTipsContentWithMessage(contentsDic)
        }
    }
    
    private func getTipsContentWithMessage(content: NSDictionary) -> String {
        var retString: String = ""
        switch tipsMessageType! {
        case .Add_GroupMember:
            let operatorNickName: String = (content.objectForKey("operator")?.objectForKey("nickName") ?? "") as! String
            retString += "\(operatorNickName)邀请 "
            if let contenArray = content.objectForKey("targets") as? NSArray {
                for userInfo in contenArray {
                    let userId: Int = userInfo.objectForKey("userId") as! Int
                    if userId == IMClientManager.shareInstance().accountId {
                        retString += "我, "
                    } else {
                        let nickName = userInfo.objectForKey("nickName") as! String
                        retString += "\(nickName), "
                    }
                }
            }
            
            retString += "加入群组"
            break
            
        case .Remove_GroupMember:
            break
        case .Modify_GroupInfo:
            break
        }
        return retString
    }
   
}
