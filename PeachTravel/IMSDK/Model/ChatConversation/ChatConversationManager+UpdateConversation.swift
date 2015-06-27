//
//  ChatConversationManager+UpdateConversation.swift
//  PeachTravel
//
//  Created by liangpengshuai on 6/24/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import Foundation

extension ChatConversationManager {
    
    /**
    更新会话的 chattername
    
    :param: name
    */
    func updateConversationName(name: String, chatterId: Int) {
        if let conversation = self.getExistConversationInConversationList(chatterId) {
            conversation.chatterName = name
        }
    }
    
    /**
    更新会话的 免打扰状态
    
    :param: name
    */
    func updateConversationStatus(isBlockMessage: Bool, chatterId: Int) {
        if let conversation = self.getExistConversationInConversationList(chatterId) {
            conversation.isBlockMessag = isBlockMessage
        }
    }
}