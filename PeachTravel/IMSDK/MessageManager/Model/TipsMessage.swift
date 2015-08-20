//
//  TipsMessage.swift
//  PeachTravel
//
//  Created by liangpengshuai on 7/7/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

@objc enum TipsMessageType: Int {
    case Common_Tips                         = 0        //默认的 tips 消息
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
    
    convenience init (content: String, tipsType: TipsMessageType) {
        self.init()
        if tipsType == TipsMessageType.Common_Tips {
            tipsContent = content
            let contentDic = ["message": content, "tipType": 0]
            if let messageStr = JSONConvertMethod.contentsStrWithJsonObjc(contentDic) as? String {
                message = messageStr
            }
        }
    }
    
    override func fillContentWithContent(contents: String) {
        var tipsDic = JSONConvertMethod.jsonObjcWithString(contents)
        self.fillContentWithContentDic(tipsDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        if let typeValue = contentsDic.objectForKey("tipType") as? Int {
            tipsMessageType = TipsMessageType(rawValue: typeValue)
            tipsContent = self.getTipsContentWithMessage(contentsDic)
        }
    }
    
    private func getTipsContentWithMessage(content: NSDictionary) -> String {
        var retString: String = ""
        switch tipsMessageType! {
        case .Add_GroupMember:
            let operatorNickName: String
            let userId: Int = content.objectForKey("operator")?.objectForKey("userId") as! Int
            if userId == IMClientManager.shareInstance().accountId {
                operatorNickName = "我"
            } else {
                operatorNickName  = (content.objectForKey("operator")?.objectForKey("nickName") ?? "") as! String
            }
            retString += "\(operatorNickName)邀请 "
            if let contentArray = content.objectForKey("targets") as? NSArray {
                var index = 0
                for userInfo in contentArray {
                    let userId: Int = userInfo.objectForKey("userId") as! Int
                    if userId == IMClientManager.shareInstance().accountId {
                        if contentArray.count == 0 {
                            retString += "你"
                        } else {
                            retString += "你, "
                        }
                    } else {
                        let nickName = userInfo.objectForKey("nickName") as! String
                        if index == contentArray.count-1 {
                            retString += "\(nickName) "
                        } else {
                            retString += "\(nickName), "
                        }
                    }
                    index++
                }
            }
            
            retString += "加入讨论组"
            
        case .Remove_GroupMember:
            
            let operatorNickName: String = (content.objectForKey("operator")?.objectForKey("nickName") ?? "") as! String

            if let contentArray = content.objectForKey("targets") as? NSArray {
                if contentArray.count > 0 {
                    var index = 0
                    retString += "\(operatorNickName)把 "
                    for userInfo in contentArray {
                        let userId: Int = userInfo.objectForKey("userId") as! Int
                        if userId == IMClientManager.shareInstance().accountId {
                            if contentArray.count == 1 {
                                retString += "你"
                            } else {
                                retString += "你, "
                            }
                        } else {
                            let nickName = userInfo.objectForKey("nickName") as! String
                            if index == contentArray.count-1 {
                                retString += "\(nickName) "
                                
                            } else {
                                retString += "\(nickName), "
                            }
                        }
                        index++
                    }
                    retString += "移除讨论组"
                    
                } else {
                    retString = "\(operatorNickName)退出了讨论组"
                }
                
            }
            

        case .Modify_GroupInfo:
            break
            
        case .Common_Tips:
            return (content.objectForKey("message") as? String)!
            
        }
        
        return retString
    }
   
}
