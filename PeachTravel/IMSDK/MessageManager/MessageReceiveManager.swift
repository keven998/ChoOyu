//
//  MessageReceiveManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/17/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//
   
import UIKit

@objc enum MessageReceiveDelegateRoutingKey: Int {
    case normal = 1
    case cmd = 2
}

@objc protocol MessageReceiveManagerDelegate {
    /**
    收到新消息
    :param: message 消息内容
    */
    optional func receiveNewMessage(message: BaseMessage)
}

class MessageReceiveManager: NSObject, PushMessageDelegate, MessageReceivePoolDelegate, MessageManagerDelegate {
    
    private let messageReceiveQueue = dispatch_queue_create("messageReceiveQueue", nil)
    
    //是否正在fetch
    var isFetching = false
    
    /// 收到消息的监听队列，不同的消息有不同的监听者，由 routingkey 区分
    private var receiveDelegateList: Array<[MessageReceiveDelegateRoutingKey: MessageReceiveManagerDelegate]> = Array()
    
    let pushSDKManager = PushSDKManager.shareInstance()
    let messagePool = MessageReceivePool()
    let messageManager = MessageManager.shareInsatance()
    
    private var receiveMessageList: NSDictionary?
    
    override init() {
        super.init()
        messagePool.delegate = self
        messageManager.delegate = self
    }
    
    /**
    注册消息的监听
    
    :param: monitor        监听的对象
    :param: withRoutingKey 需要监听消息的key
    */
    func addMessageReceiveListener(listener: MessageReceiveManagerDelegate, withRoutingKey routingKey: MessageReceiveDelegateRoutingKey) {
        receiveDelegateList.append([routingKey: listener])
    }
    
    /**
    移除消息的监听者
    
    :param: listener   监听对象
    :param: routingKey 监听消息的 key
    */
    func removeMessageReceiveListener(listener: MessageReceiveManagerDelegate, withRoutingKey routingKey: MessageReceiveDelegateRoutingKey) {
        for (index, value) in receiveDelegateList.enumerate() {
            if value[routingKey] === listener {
                receiveDelegateList.removeAtIndex(index)
                return
            }
        }
    }
    
    /**
    添加一天消息（例如 同意好友请求的时候手动插一条消息）
    
    :param: message
    */
    func addMessage2Distribute(message: BaseMessage) {
        self.distributionMessage([message])
    }
    
    /**
    fetch 消息
    
    :param: receivedMessages 已经收到的消息
    */
    func asyncACKMessageWithReceivedMessages(receivedMessages: NSArray?, completion: ((isSucess: Bool) -> ())?) {
        isFetching = true
        
        NetworkTransportAPI.asyncACKMessage(IMClientManager.shareInstance().accountId, lastFetchTime:messageManager.lastFetchTime, completionBlock: { (isSuccess: Bool, errorCode: Int, timestamp: Int?, retMessage: NSArray?) -> () in
            self.isFetching = false
            if (isSuccess) {
                self.messageManager.lastFetchTime = timestamp
                if let retMessageArray = retMessage {
                    dispatch_async(self.messageReceiveQueue, { () -> Void in
                        if (retMessageArray.count>0 || receivedMessages?.count>0) {
                            self.dealwithFetchResult(receivedMessages, fetchMessages: retMessageArray)
                        }
                    })
                }
            } else {
                dispatch_async(self.messageReceiveQueue, { () -> Void in
                    self.dealwithFetchResult(receivedMessages, fetchMessages: nil)
                })
            }
            completion?(isSucess: isSuccess)
        })
    }
    
//MARK: private method
    
    /**
    检查属于一组消息是否合法
    :param: messageList 待检查的消息
    */
    private func checkMessages(messageList: NSArray) {

        let messagePrepate2Distribute = NSMutableArray()
        let messagePrepare2Fetch = NSMutableArray()
        var needFetchMessage = false
        
        debug_print("checkMessages queue: \(NSThread.currentThread())")
        
        let allLastMessageList = messageManager.allLastMessageList

        for message in (messageList as! NSMutableArray) {
            if let message = message as? BaseMessage {
                
                if let lastMessageServerId: AnyObject = allLastMessageList.objectForKey(message.chatterId) {
                    
                    //如果消息不连续了，则带着未处理的消息跳出循环去 fetch 消息
                    if (message.serverId - (lastMessageServerId as! Int)) > 1 {
                        let index = messageList.indexOfObject(message)
                        for var i = index; i < messageList.count; i++ {
                            messagePrepare2Fetch.addObject(messageList.objectAtIndex(i))
                        }

                        needFetchMessage = true
                        break
                    
                    //如果消息是连续的
                    } else if (message.serverId - (lastMessageServerId as! Int)) == 1 {
                        allLastMessageList.setObject(message.serverId, forKey: message.chatterId)
                        messagePrepate2Distribute.addObject(message)
                        
                    //如果消息是一条旧的消息，则判断一下数据库里有没有这条消息，如果没有的话则加入
                    } else {
                        if oldMessageShould2Distribution(message) {
                            messagePrepate2Distribute.addObject(message)
                        }
                    }
                    
                } else {
                    debug_print("这是一条数据库不存在的消息: 带插入的 serverId: \(message.serverId))")
                    allLastMessageList.setObject(message.serverId, forKey: message.chatterId)
                    messagePrepate2Distribute.addObject(message)
                }
            }
        }

        debug_print("进行插入的消息一共有\(messagePrepate2Distribute.count) 条")
        
        if needFetchMessage {
            debug_print("存在不合法的消息, 需要 fetch")
            self.asyncACKMessageWithReceivedMessages(messagePrepare2Fetch, completion: nil)
        }
        let array = messagePrepate2Distribute as AnyObject as! [BaseMessage]
        distributionMessage(array)
    }
    
    /**
    处理 fetch 后的数据,当判断不合理的消息不再 fetch
    :param: receivedMessages
    :param: fetchMessages
    */
    private func dealwithFetchResult(receivedMessages: NSArray?, fetchMessages: NSArray?) {
        
        NSLog("dealwithFetchResult*** currentThread   fetchMessagesCount %@, %d", NSThread.currentThread(), fetchMessages?.count ?? 0)
        var messagesPrepare2DistributeArray = NSMutableArray()
        
        let allLastMessageList = messageManager.allLastMessageList

        if let receivedMessageArray = receivedMessages {
            messagesPrepare2DistributeArray = receivedMessageArray.mutableCopy() as! NSMutableArray
        } else {
            messagesPrepare2DistributeArray = NSMutableArray()
        }

        if let fetchMessages = fetchMessages {
            for messageDic in fetchMessages {
                if let message = MessageManager.messageModelWithMessage(messageDic) {
                    if message.senderId == IMClientManager.shareInstance().accountId {
                        message.sendType = IMMessageSendType.MessageSendMine
                    } else {
                        message.sendType = IMMessageSendType.MessageSendSomeoneElse
                    }
                    
                    if let lastMessageServerId: AnyObject = allLastMessageList.objectForKey(message.chatterId) {
                        if (message.serverId - (lastMessageServerId as! Int)) >= 1 {
                            allLastMessageList.setObject(message.serverId, forKey: message.chatterId)
                            
                            var haveAdded = false
                            for var i = messagesPrepare2DistributeArray.count-1; i>=0; i-- {
                                let oldMessage = messagesPrepare2DistributeArray.objectAtIndex(i) as! BaseMessage
                                if (message.serverId == oldMessage.serverId && message.chatterId == oldMessage.chatterId) {
                                    haveAdded = true
                                    break
                                    
                                } else if (message.serverId < oldMessage.serverId && message.chatterId == oldMessage.chatterId) {
                                    continue
                                    
                                } else if (message.serverId > oldMessage.serverId && message.chatterId == oldMessage.chatterId) {
                                    messagesPrepare2DistributeArray.insertObject(message, atIndex: i+1)
                                    haveAdded = true
                                    break
                                }
                            }
                            if !haveAdded {
                                messagesPrepare2DistributeArray.insertObject(message, atIndex: 0)
                            }
                            
                            
                        } else {
                            if oldMessageShould2Distribution(message) {
                                messagesPrepare2DistributeArray.addObject(message)
                            }
                        }
                        
                    } else {
                        messagesPrepare2DistributeArray.addObject(message)
                        allLastMessageList.setObject(message.serverId, forKey: message.chatterId)
                    }
                }
            }
        }
        let array = messagesPrepare2DistributeArray as AnyObject as! [BaseMessage]
        distributionMessage(array)
    }
    
    /**
    判断一旧消息是否应该被分发出去，如果应该的话将旧消息的时间戳改为当前的时间
    
    :param: message 需要被判断的消息
    :true: 应该
    */
    private func oldMessageShould2Distribution(message: BaseMessage) -> Bool {
        let daoHelper = DaoHelper.shareInstance()
        let chatTableName = "chat_\(message.chatterId)"
        if daoHelper.messageIsExitInTable(chatTableName, message: message) {
            return false
        } else {
            return true
        }
    }
    
    /**
    将合法的消息分发出去
    :param: message
    */
    private func distributionMessage(messageList: Array<BaseMessage>) {

        let daoHelper = DaoHelper.shareInstance()
        daoHelper.insertChatMessageList(messageList, completionBlock: { () -> () in
            for message in messageList {
                
                debug_print("distributionMessage: chatterId: \(message.chatterId)   serverId: \(message.serverId)")
                
                if message.messageType == .ImageMessageType {
                    self.downloadPreviewImageAndDistribution(message as! ImageMessage)
                    
                } else  if message.messageType == .LocationMessageType {
                    self.downloadSnapshotImageAndDistribution(message as! LocationMessage)
                    
                } else if message.messageType == .AudioMessageType {
                    self.downloadAudioDataAndDistribution(message as! AudioMessage)
                    
                } else  {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if message.messageType == IMMessageType.CMDMessageType {
                            for delegateDic in self.receiveDelegateList {
                                if let delegate = delegateDic[MessageReceiveDelegateRoutingKey.cmd] {
                                    delegate.receiveNewMessage?(message)
                                }
                            }
                        } else {
                            for delegateDic in self.receiveDelegateList {
                                if let delegate = delegateDic[MessageReceiveDelegateRoutingKey.normal] {
                                    delegate.receiveNewMessage?(message)
                                }
                            }
                        }
                    })
                }
            }
        })
    }
    
    /**
    在通知用户之前先将图片的二进制文件下载下来
    :param: message
    */
    private func downloadPreviewImageAndDistribution(imageMessage: ImageMessage) {
        MetadataDownloadManager.asyncDownloadThumbImage(imageMessage.thumbUrl ?? "", completion: { (isSuccess: Bool, metadata: NSData?) -> () in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                let imagePath = IMClientManager.shareInstance().userChatImagePath.stringByAppendingString("\(imageMessage.metadataId!)")
                
                if let imageData = metadata {
                    let fileManager =  NSFileManager()
                    fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil)
                    NSLog("下载图片预览图成功 保存后的地址为: \(imagePath)")
                    imageMessage.localPath = imagePath
                    imageMessage.updateMessageContent()
                    let daoHelper = DaoHelper.shareInstance()
                    daoHelper.updateMessageContents("chat_\(imageMessage.chatterId)", message: imageMessage)
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    for delegateDic in self.receiveDelegateList {
                        if let delegate = delegateDic[MessageReceiveDelegateRoutingKey.normal] {
                            delegate.receiveNewMessage?(imageMessage)
                        }
                    }
                })
            })
        })
    }
    
    /**
    将位置信息的预览图下载下载
    
    :param: message
    */
    private func downloadSnapshotImageAndDistribution(message: LocationMessage) {
        MetadataDownloadManager.asyncDownloadThumbImage(message.mapImageUrl!, completion: { (isSuccess: Bool, metadata: NSData?) -> () in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                let imagePath = IMClientManager.shareInstance().userChatImagePath.stringByAppendingString("\(message.metadataId!)")
                
                if let imageData = metadata {
                    let fileManager =  NSFileManager()
                    fileManager.createFileAtPath(imagePath, contents: imageData, attributes: nil)
                    NSLog("下载图片预览图成功 保存后的地址为: \(imagePath)")
                    message.localPath = imagePath
                    message.updateMessageContent()
                    let daoHelper = DaoHelper.shareInstance()
                    daoHelper.updateMessageContents("chat_\(message.chatterId)", message: message)
                }
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    for delegateDic in self.receiveDelegateList {
                        if let delegate = delegateDic[MessageReceiveDelegateRoutingKey.normal] {
                            delegate.receiveNewMessage?(message)
                        }
                    }
                })
            })
        })
    }
    
    /**
    在通知用户之前先将图片的二进制文件下载下来
    :param: message
    */
    private func downloadAudioDataAndDistribution(message: AudioMessage) {
        MetadataDownloadManager.asyncDownloadAudioData(message, completion: { (isSuccess: Bool, retMessage: AudioMessage) -> () in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                for delegateDic in self.receiveDelegateList {
                    if let delegate = delegateDic[MessageReceiveDelegateRoutingKey.normal] {
                        delegate.receiveNewMessage?(retMessage)
                    }
                }
            })
        })
    }
    
//MARK: PushMessageDelegate
    
    func receivePushMessage(message: NSDictionary) {
        NSLog("收到消息： 消息为：\(message)")
        if AccountManager.shareAccountManager().isLogin() {
            if let message = MessageManager.messageModelWithMessage(message) {
                
                // 收到消息有可能是从其他客户端登录发送的
                if message.senderId == IMClientManager.shareInstance().accountId {
                    message.sendType = IMMessageSendType.MessageSendMine
                    messagePool.addMessage4Reorder(message)
                } else {
                    if let receiverId = message.reveiverId {
                        //如果收到的消息中包含 receiverid，那么判断是不是发送给你的消息，如果不带 receiverid，则默认是发给你的消息
                        if receiverId == IMClientManager.shareInstance().accountId {
                            message.sendType = IMMessageSendType.MessageSendSomeoneElse
                            messagePool.addMessage4Reorder(message)
                        }
                    } else {
                        message.sendType = IMMessageSendType.MessageSendSomeoneElse
                        messagePool.addMessage4Reorder(message)

                    }

                }
            }
        }
    }
    
    
//MARK: MessageReceivePoolDelegate (排序结束后)
    
    func messgeReorderOver(messageList: NSDictionary) {
        receiveMessageList = messageList.copy() as? NSDictionary
        dispatch_async(messageReceiveQueue, { () -> Void in
            debug_print("messgeReorderOver queue: \(NSThread.currentThread())")
            for messageList in self.receiveMessageList!.allValues {
                self.checkMessages(messageList as! NSArray)
            }
        })
    }
    
    // MARK: MessageManagerDelegate
    func shouldACK() {
        if !isFetching {
            self.asyncACKMessageWithReceivedMessages(nil, completion: nil)
        }
    }
}






















