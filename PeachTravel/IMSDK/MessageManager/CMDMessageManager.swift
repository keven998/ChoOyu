//
//  CMDMessageManager.swift
//  TZIM
//
//  Created by liangpengshuai on 5/19/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

enum CMDMessageRoutingKey: Int {
    case Frend_CMD              = 1       //好友相关的 cmd 消息
    case DiscussionGroup_CMD    = 2       //讨论组相关的 cmd 消息
    case Group_CMD              = 3       //群组相关的 cmd 消息
}

@objc protocol CMDMessageManagerDelegate {
    
    //MARK: 好友
    
    optional func receiveFrendCMDMessage(cmdMessage: IMCMDMessage);
    //MARK: 讨论组
    
    optional func receiveDiscussiongGroupCMDMessage(cmdMessage: IMCMDMessage);
    
    //MARK: 群组
    optional func receiveGroupCMDMessage(cmdMessage: IMCMDMessage);
    
}


class CMDMessageManager: NSObject, MessageReceiveManagerDelegate {
    
    private var listenerQueue: Array<[CMDMessageRoutingKey: CMDMessageManagerDelegate]> = Array()
    
    /**
    注册消息的监听
    
    :param: monitor        监听的对象
    :param: withRoutingKey 需要监听消息的key
    */
    func addCMDMessageListener(listener: CMDMessageManagerDelegate, withRoutingKey routingKey: CMDMessageRoutingKey) {
        
        listenerQueue.append([routingKey: listener])
    }
    
    /**
    移除消息的监听者
    
    :param: listener   监听对象
    :param: routingKey 监听消息的 key
    */
    func removeCMDMessageListener(listener: CMDMessageManager, withRoutingKey routingKey: CMDMessageRoutingKey) {
        for (index, value) in enumerate(listenerQueue) {
            if value[routingKey] === listener {
                listenerQueue.removeAtIndex(index)
                return
            }
        }
    }
    
    private func getDelegateWithRoutingKey(routingKey: CMDMessageRoutingKey) -> CMDMessageManagerDelegate? {
        for value in listenerQueue {
            var listenerDic = value as Dictionary<CMDMessageRoutingKey, CMDMessageManagerDelegate>
            if let oldListener = listenerDic[routingKey] {
                return oldListener
            }
        }
        return nil
    }
    
    //MARK: MessageTransferManagerDelegate
    
    func receiveNewMessage(message: BaseMessage) {
        if let cmdMessage = message as? IMCMDMessage {
            self.dispatchCMDMessage(cmdMessage)
        }
    }
    
    /**
    分发 cmd 消息
    :param: message
    */
    private func dispatchCMDMessage(message: IMCMDMessage) {
        if let actionCode = message.actionCode {
            switch message.actionCode! {
                
            case .D_INVITE :
                if let delegate = self.getDelegateWithRoutingKey(CMDMessageRoutingKey.DiscussionGroup_CMD) {
                    delegate.receiveDiscussiongGroupCMDMessage?(message)
                }
                
            case .G_INVITE :
                if let delegate = self.getDelegateWithRoutingKey(CMDMessageRoutingKey.Group_CMD) {
                    delegate.receiveDiscussiongGroupCMDMessage?(message)
                }
                
            case .F_REQUEST:
                if let delegate = self.getDelegateWithRoutingKey(CMDMessageRoutingKey.Frend_CMD) {
                    delegate.receiveFrendCMDMessage?(message)
                }
                
            default:
                break
            }
        }
    }
    
   
    

 
    
    
    
    
    
    
    
    
    
    
    
    
    
}
