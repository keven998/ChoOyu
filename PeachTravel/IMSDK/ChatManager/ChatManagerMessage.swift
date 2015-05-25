//
//  ChatManagerMessage.swift
//  TZIM
//
//  Created by liangpengshuai on 4/22/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit
protocol ChatManagerMessageProtocol {
    func selectChatMessageList(chatterId:Int, untilLocalId localId: Int, messageCount: Int) -> NSArray

}

class ChatManagerMessage: NSObject, ChatManagerMessageProtocol {
    
    //MARK: ChatManagerMessageProtocol
    func selectChatMessageList(chatterId:Int, untilLocalId localId: Int, messageCount: Int) -> NSArray {
        var daoHelper = DaoHelper.shareInstance()
        var retArray = NSArray()
        retArray = daoHelper.selectChatMessageList(chatterId, untilLocalId: localId, messageCount: messageCount)
        return retArray
    }
}
