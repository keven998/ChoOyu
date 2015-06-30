//
//  IMCMDMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 5/19/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

enum CMDActionCode: String {
    
    case F_REQUEST  =   "F_REQUEST"          //添加好友
    case F_AGREE    =   "F_AGREE"        //同意添加好友

    
    case D_INVITE   =   "D_INVITE"       //邀请加入讨论组
    
    
    case G_APPLY    =   "G_APPLY"         //申请加入群组
    case G_AGREE    =   "G_AGREE"         //同意加入群组
    case G_INVITE   =   "G_INVITE"        //邀请加入群组
    case G_QUIT     =   "G_QUIT"          //退出群组
    case G_REMOVE   =   "G_REMOVE"        //踢出群组
    case G_DESTROY  =   "G_DESTROY"       //解散群组

}

class IMCMDMessage: BaseMessage {
    var actionCode: CMDActionCode!
    var actionContent: NSDictionary!

    override func fillContentWithContent(contents: String) {
        var imageDic = JSONConvertMethod.jsonObjcWithString(contents)
        self.fillContentWithContentDic(imageDic)
    }
    
    override func fillContentWithContentDic(contentsDic: NSDictionary) {
        if let action = contentsDic.objectForKey("action") as? String {
            actionCode = CMDActionCode(rawValue: action)
        }
        actionContent = contentsDic
    }
}

