//
//  MessageSendManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/18/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol MessageSendManagerDelegate {
    
    /**
    发送新消息
    :param: message
    */
    optional func sendNewMessage(message: BaseMessage)
    
    /**
    发送的消息已经发送成功
    :param: message 发送成功的消息
    */
    optional func messageHasSended(message: BaseMessage)
}

class MessageSendManager: NSObject {
    
    private var sendDelegateList: Array<MessageSendManagerDelegate> = Array()
    
    private let sendingMessageList: NSMutableArray = NSMutableArray()
    
    /**
    注册消息的监听
    
    :param: monitor        监听的对象
    :param: withRoutingKey 需要监听消息的key
    */
    func addMessageSendDelegate(listener: MessageSendManagerDelegate) {
        sendDelegateList.append(listener)
    }
    
    /**
    移除消息的监听者
    
    :param: listener   监听对象
    :param: routingKey 监听消息的 key
    */
    func removeMessageSendDelegate(listener: MessageSendManagerDelegate) {
        for (index, value) in enumerate(sendDelegateList) {
            if value === listener {
                sendDelegateList.removeAtIndex(index)
                return
            }
        }
    }
    
//MARK: private methods
    
    private func sendMessage(message: BaseMessage, receiver: Int, chatType:IMChatType, conversationId: String?) {
        sendingMessageList.addObject(message)
        
        var daoHelper = DaoHelper.shareInstance()
        var accountManager = AccountManager.shareAccountManager()
        NetworkTransportAPI.asyncSendMessage(MessageManager.prepareMessage2Send(receiverId: receiver, senderId: accountManager.account.userId, conversationId: conversationId, chatType: chatType, message: message), completionBlock: { (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> () in
            self.sendingMessageList.removeObject(message)
            if isSuccess {
                message.status = IMMessageStatus.IMMessageSuccessful
                if let retMessage = retMessage {
                    if let serverId = retMessage.objectForKey("msgId") as? Int {
                        message.serverId = serverId
                        MessageManager.shareInsatance().updateLastServerMessage(message)
                    }
                }
            } else {
                message.status = IMMessageStatus.IMMessageFailed
            }
            daoHelper.updateMessageInDB("chat_\(receiver)", message: message)
            for messageManagerDelegate in self.sendDelegateList {
                messageManagerDelegate.messageHasSended?(message)
            }
        })
    }
    
//MARK: Internal methods
    /**
    判断一条消息是不是确实正在发送，判断的方法是： 检查这条消息是不是在发送中的队列里
    
    :param: message
    
    :returns:
    */
    func messageIsReallySending(message: BaseMessage) -> Bool {
        for sendingMsg in sendingMessageList {
            if message.localId == (sendingMsg as! BaseMessage).localId {
                if message.chatterId == (sendingMsg as! BaseMessage).chatterId {
                    return true
                }
            }
        }
        return false
    }
    
    /**
    发送一条文本消息
    :param: chatterId   接收人 id
    :param: isChatGroup 是否是群组
    :param: message     消息的内容
    :returns: 被发送的 message
    */
    func sendTextMessage(message: String, receiver: Int, chatType:IMChatType, conversationId: String?) -> BaseMessage {
        var textMessage = TextMessage()
        textMessage.createTime = Int(NSDate().timeIntervalSince1970)
        textMessage.status = IMMessageStatus.IMMessageSending
        textMessage.message = message
        textMessage.chatterId = receiver
        textMessage.sendType = IMMessageSendType.MessageSendMine
        textMessage.conversationId = conversationId
        
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.insertChatMessage("chat_\(receiver)", message: textMessage)
        for messageManagerDelegate in self.sendDelegateList {
            messageManagerDelegate.sendNewMessage?(textMessage)
        }
        sendMessage(textMessage, receiver: receiver, chatType: chatType, conversationId: conversationId)
        return textMessage
    }
    
    /**
    发送一条位置信息
    
    :param: location       位置 model，包括 lat，lng，address
    :param: receiver       接收者
    :param: chatType       聊天类型
    :param: conversationId
    
    :returns: 发送前的消息
    */
    func sendLocationMessage(location: LocationModel, receiver: Int, chatType: IMChatType, conversationId: String?) -> BaseMessage {
        var locationMessage = LocationMessage()
        locationMessage.createTime = Int(NSDate().timeIntervalSince1970)
        locationMessage.latitude = location.latitude
        locationMessage.longitude = location.longitude
        locationMessage.address = location.address
        locationMessage.chatterId = receiver
        locationMessage.sendType = IMMessageSendType.MessageSendMine
        locationMessage.conversationId = conversationId
        var locationDic = ["lat": location.latitude, "lng": location.longitude, "name": location.address];
        locationMessage.message = JSONConvertMethod.contentsStrWithJsonObjc(locationDic) as! String

        var daoHelper = DaoHelper.shareInstance()
        daoHelper.insertChatMessage("chat_\(receiver)", message: locationMessage)
        for messageManagerDelegate in self.sendDelegateList {
            messageManagerDelegate.sendNewMessage?(locationMessage)
        }
        sendMessage(locationMessage, receiver: receiver, chatType: chatType, conversationId: conversationId)

        return locationMessage
    }
    
    /**
    发送一条位置信息
    
    :param: location       位置 model，包括 lat，lng，address
    :param: receiver       接收者
    :param: chatType       聊天类型
    :param: conversationId
    
    :returns: 发送前的消息
    */
    func sendLocationMessage(location: LocationModel, receiver: Int, mapImage: UIImage, chatType: IMChatType, conversationId: String?) -> BaseMessage {
        var locationMessage = LocationMessage()
        locationMessage.createTime = Int(NSDate().timeIntervalSince1970)
        locationMessage.latitude = location.latitude
        locationMessage.longitude = location.longitude
        locationMessage.address = location.address
        locationMessage.chatterId = receiver
        locationMessage.status = .IMMessageSending
        var metadataId = NSUUID().UUIDString
        var imageData = UIImageJPEGRepresentation(mapImage, 1)

        let path = IMClientManager.shareInstance().userChatImagePath.stringByAppendingPathComponent("\(metadataId)")
        locationMessage.localPath = path
        MetaDataManager.moveMetadata2Path(imageData, toPath: path)

        locationMessage.sendType = IMMessageSendType.MessageSendMine
        locationMessage.conversationId = conversationId
        var locationDic = ["lat": location.latitude, "lng": location.longitude, "address": location.address, "metadataId": metadataId];
        locationMessage.message = JSONConvertMethod.contentsStrWithJsonObjc(locationDic) as! String
        
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.insertChatMessage("chat_\(receiver)", message: locationMessage)
        for messageManagerDelegate in self.sendDelegateList {
            messageManagerDelegate.sendNewMessage?(locationMessage)
        }

        self.sendMetadataMessage(locationMessage, metadata: imageData, chatType: chatType, conversationId: conversationId, progress: nil) { (isSuccess) -> () in
            
        }
        return locationMessage
    }

    /**
    发送 poi 信息
    
    :param: poiModel       poimodel
    :param: receiver       接收者
    :param: chatType       聊天类型
    :param: conversationId
    
    :returns:
    */
    func sendPoiMessage(poiModel: IMPoiModel, receiver: Int, chatType: IMChatType, conversationId: String?) -> BaseMessage {
        let message = MessageManager.messageModelWithPoiModel(poiModel)
        message.createTime = Int(NSDate().timeIntervalSince1970)
        message.chatterId = receiver
        message.status = .IMMessageSending
        message.sendType = IMMessageSendType.MessageSendMine
        message.conversationId = conversationId
        switch poiModel.poiType {
        case .City :
            message.messageType = IMMessageType.CityPoiMessageType
        case .Spot :
            message.messageType = IMMessageType.SpotMessageType
        case .Restaurant :
            message.messageType = IMMessageType.RestaurantMessageType
        case .Guide :
            message.messageType = IMMessageType.GuideMessageType
        case .TravelNote :
            message.messageType = IMMessageType.TravelNoteMessageType
        case .Shopping :
            message.messageType = IMMessageType.ShoppingMessageType
        case .Hotel :
            message.messageType = IMMessageType.HotelMessageType
            
        default:
            break
            
        }
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.insertChatMessage("chat_\(receiver)", message: message)
        for messageManagerDelegate in self.sendDelegateList {
            messageManagerDelegate.sendNewMessage?(message)
        }
        sendMessage(message, receiver: receiver, chatType: chatType, conversationId: conversationId)
        
        return message
    }
    
    /**
    发送一条图片消息
    
    :param: chatterId
    :param: isChatGroup
    :param: image   发送的图片，必选
    :returns:
    */
    func sendImageMessage(chatterId: Int, conversationId: String?, imageData: NSData, chatType: IMChatType, progress:(progressValue: Float) -> ()) -> BaseMessage {
        var imageMessage = ImageMessage()
        imageMessage.chatterId = chatterId
        imageMessage.sendType = IMMessageSendType.MessageSendMine
        imageMessage.createTime = Int(NSDate().timeIntervalSince1970)
        imageMessage.status = IMMessageStatus.IMMessageSending

        debug_println("imageDataLength: \(imageData.length)")
        
        var metadataId = NSUUID().UUIDString
        var imagePath = IMClientManager.shareInstance().userChatImagePath.stringByAppendingPathComponent("\(metadataId)")
        MetaDataManager.moveMetadata2Path(imageData, toPath: imagePath)
        
        imageMessage.localPath = imagePath
        
        var imageContentDic = NSMutableDictionary()
        imageContentDic.setObject(metadataId, forKey: "metadataId")
        imageMessage.message = JSONConvertMethod.contentsStrWithJsonObjc(imageContentDic) as! String
        
        var daoHelper = DaoHelper.shareInstance()
        daoHelper.insertChatMessage("chat_\(chatterId)", message: imageMessage)
        
        for messageManagerDelegate in self.sendDelegateList {
            messageManagerDelegate.sendNewMessage?(imageMessage)
        }
        
        self.sendMetadataMessage(imageMessage, metadata: imageData, chatType: chatType, conversationId: conversationId, progress: { (progressValue) -> () in
            progress(progressValue: progressValue)
            
        }) { (isSuccess) -> () in
            
        }
        return imageMessage
    }
    
    /**
    发送 wav 格式的音频
    :param: chatterId
    :param: isChatGroup
    :param: wavAudioPath 音频的本地路径
    :param: progress     发送进度的回调
    :returns:
    */
    func sendAudioMessageWithWavFormat(chatterId: Int, conversationId: String?, wavAudioPath: String, chatType:IMChatType, progress:(progressValue: Float) -> ()) -> BaseMessage? {
        var audioMessage = AudioMessage()
        audioMessage.chatterId = chatterId
        audioMessage.sendType = IMMessageSendType.MessageSendMine
        audioMessage.createTime = Int(NSDate().timeIntervalSince1970)
        audioMessage.status = IMMessageStatus.IMMessageSending
        
        var metadataId = NSUUID().UUIDString
        
        var tempAmrPath = IMClientManager.shareInstance().userChatTempPath.stringByAppendingPathComponent("\(metadataId).amr")

        var audioWavPath = IMClientManager.shareInstance().userChatAudioPath.stringByAppendingPathComponent("\(metadataId).wav")
        MetaDataManager.moveMetadataFromOnePath2AnotherPath(wavAudioPath, toPath: audioWavPath)
        
        VoiceConverter.wavToAmr(wavAudioPath, amrSavePath: tempAmrPath)
        
        var audioContentDic = NSMutableDictionary()
        audioContentDic.setObject(metadataId, forKey: "metadataId")

        if let url = NSURL(string: tempAmrPath) {
            if let play = AVAudioPlayer(contentsOfURL: url, error: nil) {
                audioContentDic.setObject(play.duration, forKey: "duration")
                audioMessage.audioLength = Float(play.duration)
                
            } else {
                return nil
            }
        }
        
        audioMessage.localPath = audioWavPath
        audioMessage.message = JSONConvertMethod.contentsStrWithJsonObjc(audioContentDic) as! String
        
        debug_println("开始发送语音消息： 消息内容为： \(audioMessage.message)")
        var daoHelper = DaoHelper.shareInstance()

        daoHelper.insertChatMessage("chat_\(chatterId)", message: audioMessage)
        
        for messageManagerDelegate in self.sendDelegateList {
            messageManagerDelegate.sendNewMessage?(audioMessage)
        }
        
        var audioData = NSData(contentsOfFile: tempAmrPath)
        
        if let audioData = audioData {
            self.sendMetadataMessage(audioMessage, metadata: audioData, chatType: chatType, conversationId: conversationId, progress: progress, completionBlock: { (isSuccess) -> () in
                var fileManager =  NSFileManager()
                var error: NSError?
                fileManager.removeItemAtPath(tempAmrPath, error: &error)
                if error != nil {
                    debug_println("移除发送完成后的临时文件出错 error\(error)")
                }
            })
        }
        return audioMessage
    }
    
    /**
    发送二进制文件
    
    :param: metadataMessage
    :param: metadata
    :param: chatType
    :param: conversationId
    :param: completionBlock
    */
    private func sendMetadataMessage(metadataMessage: BaseMessage, metadata: NSData, chatType: IMChatType, conversationId: String?, progress:((progressValue: Float) -> ())?, completionBlock:(isSuccess: Bool)->()) {
        sendingMessageList.addObject(metadataMessage)
        MetadataUploadManager.asyncRequestUploadToken2SendMessage(metadataMessage.messageType, completionBlock: { (isSuccess, key, token) -> () in
            if isSuccess {
                MetadataUploadManager.uploadMetadata2Qiniu(metadataMessage, token: token!, key: key!, metadata: metadata, chatType:chatType, conversationId:conversationId, progress: { (progressValue) -> () in
                        if let progressBlock = progress {
                            progressBlock(progressValue: progressValue)
                        }
                    })
                    { (isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> () in
                        completionBlock(isSuccess: isSuccess)
                        self.sendingMessageList.removeObject(metadataMessage)
                        if isSuccess {
                            metadataMessage.status = IMMessageStatus.IMMessageSuccessful
                            if let retMessage = retMessage {
                                if let serverId = retMessage.objectForKey("msgId") as? Int {
                                    metadataMessage.serverId = serverId
                                    MessageManager.shareInsatance().updateLastServerMessage(metadataMessage)
                                }
                            }
                            
                        } else {
                            metadataMessage.status = IMMessageStatus.IMMessageFailed
                        }
                        let daoHelper = DaoHelper.shareInstance()
                        daoHelper.updateMessageInDB("chat_\(metadataMessage.chatterId)", message: metadataMessage)
                        for messageManagerDelegate in self.sendDelegateList {
                            messageManagerDelegate.messageHasSended?(metadataMessage)
                        }
                        
                }
            } else {
                self.sendingMessageList.removeObject(metadataMessage)

                metadataMessage.status = IMMessageStatus.IMMessageFailed
                let daoHelper = DaoHelper.shareInstance()
                daoHelper.updateMessageInDB("chat_\(metadataMessage.chatterId)", message: metadataMessage)
                for messageManagerDelegate in self.sendDelegateList {
                    messageManagerDelegate.messageHasSended?(metadataMessage)
                }
            }
        })
    }
    
    /**
    重新发送 message
    */
    func resendMessage(message: BaseMessage, receiver: Int, chatType:IMChatType, conversationId: String?) {
        //如果需要重发的消息已经在发送队列里了，那么不需要重新发送
        if self.messageIsReallySending(message) {
            message.status = IMMessageStatus.IMMessageSending
            let daoHelper = DaoHelper.shareInstance()
            daoHelper.updateMessageInDB("chat_\(message.chatterId)", message: message)
            return
        }
        
        message.status = IMMessageStatus.IMMessageSending
        let daoHelper = DaoHelper.shareInstance()
        daoHelper.updateMessageInDB("chat_\(message.chatterId)", message: message)
        if message.messageType == IMMessageType.AudioMessageType {
            var tempAmrPath = IMClientManager.shareInstance().userChatTempPath.stringByAppendingPathComponent("\((message as! AudioMessage).metadataId).amr")
            VoiceConverter.wavToAmr((message as! AudioMessage).localPath, amrSavePath: tempAmrPath)
            if let audioData = NSData(contentsOfFile: tempAmrPath) {
                self.sendMetadataMessage(message, metadata: audioData, chatType: chatType, conversationId: conversationId, progress: nil, completionBlock: { (isSuccess) -> () in
                    
                })
            }
            
        } else if message.messageType == IMMessageType.ImageMessageType {
            if let imageData = NSData(contentsOfFile: (message as! ImageMessage).localPath!) {
                self.sendMetadataMessage(message, metadata: imageData, chatType: chatType, conversationId: conversationId, progress: nil, completionBlock: { (isSuccess) -> () in
                    
                })
            }
            
        } else if message.messageType == IMMessageType.LocationMessageType {
            if let imageData = NSData(contentsOfFile: (message as! LocationMessage).localPath!) {
                self.sendMetadataMessage(message, metadata: imageData, chatType: chatType, conversationId: conversationId, progress: nil, completionBlock: { (isSuccess) -> () in
                    
                })
            }
        } else {
            self.sendMessage(message, receiver: receiver, chatType: chatType, conversationId: conversationId)
        }
    }
}












