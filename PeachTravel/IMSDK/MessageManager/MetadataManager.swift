//
//  MetadataManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/27/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit

private let metadataOperationQueue = dispatch_queue_create("MetadataDownloadQueue", nil)

class MetaDataManager: NSObject {
    
    /**
    将二进制文件移动到某个路径下
    
    :param: fileData 需要移动的数据
    :param: toPath   将要移动到的路径
    */
    class func moveMetadata2Path(metadata: NSData, toPath: String) {
        let fileManager =  NSFileManager()
        fileManager.createFileAtPath(toPath, contents: metadata, attributes: nil)
    }
    
    /**
    将某个路径下的二进制文件移动到某个路径下
    
    :param: fileData 需要移动的数据
    :param: toPath   将要移动到的路径
    */

    class func moveMetadataFromOnePath2AnotherPath(fromPath: String, toPath: String) {
        if let metadata = NSData(contentsOfFile: fromPath) {
            MetaDataManager.moveMetadata2Path(metadata, toPath: toPath)
        }
    }
}

enum QiniuGetTokeAction: Int {
    case uploadChatMetadata = 1
}

class MetadataUploadManager: NSObject {
    
    /**
    异步获取上传的 token 和 key
    
    :param: completionBlock 获取完后的回调
    */
    class func asyncRequestUploadToken2SendMessage(messageType: IMMessageType, completionBlock: (isSuccess: Bool, key: String?, token: String?) -> ()) {
        let manager = AFHTTPRequestOperationManager()
        
        let requestSerializer = AFJSONRequestSerializer()
        
        manager.requestSerializer = requestSerializer
        
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Accept")
        manager.requestSerializer.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        manager.POST(requestQiniuTokenToUploadMetadata, parameters: ["msgType": messageType.rawValue], success:
            {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                if let reslutDic = responseObject.objectForKey("result") as? NSDictionary {
                    let key: String? = (reslutDic.objectForKey("key") as! String)
                    let token: String? = (reslutDic.objectForKey("token") as! String)
                    completionBlock(isSuccess: true, key: key, token: token)
                    
                } else {
                    completionBlock(isSuccess: false, key: nil, token: nil)
                }
            })
            {
                (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                
                completionBlock(isSuccess: false, key: nil, token: nil)
                debug_print(error)
        }
    }
   
    /**
    上传二进制文件到七牛服务器
    
    :param: metadataMessage 二进制消息
    :param: metadata        二进制文件实体
    :param: progress        上传进度回调
    :param: completion      完成回调
    */
    class func uploadMetadata2Qiniu(metadataMessage: BaseMessage, token: String, key: String, metadata: NSData, chatType: IMChatType, conversationId: String?, progress: (progressValue: Float) -> (), completion:(isSuccess: Bool, errorCode: Int, retMessage: NSDictionary?) -> ()) {
        let uploadManager = QNUploadManager()
        
        let params = NSMutableDictionary()
        params.setObject("\(IMClientManager.shareInstance().accountId)", forKey: "x:sender")
        params.setObject("\(metadataMessage.messageType.rawValue)", forKey: "x:msgType")
        
        if let conversationId = conversationId {
            params.setValue(conversationId, forKey: "x:conversation")
        }
        params.setValue("\(metadataMessage.chatterId)", forKey: "x:receiver")
        
        if chatType == IMChatType.IMChatSingleType {
            params.setValue("single", forKey: "x:chatType")
            
        } else {
            params.setValue("group", forKey: "x:chatType")
        }
        
        if metadataMessage.messageType == IMMessageType.LocationMessageType {
            params.setValue("\((metadataMessage as! LocationMessage).address)", forKey: "x:address")
            params.setValue("\((metadataMessage as! LocationMessage).latitude)", forKey: "x:lat")
            params.setValue("\((metadataMessage as! LocationMessage).longitude)", forKey: "x:lng")
        }
        
        let opt = QNUploadOption(mime: "text/plain", progressHandler: { (key: String!, progressValue: Float) -> Void in
            progress(progressValue: progressValue)
            }, params: params as [NSObject : AnyObject], checkCrc: true, cancellationSignal: nil)
    
        uploadManager.putData(metadata, key: key, token: token, complete: { (info: QNResponseInfo!, key: String!, resp:Dictionary!) -> Void in
            debug_print("resp: \(resp)")
            if let error = info.error {
                debug_print("上传二进制文件出错： \(error)")
                completion(isSuccess: false, errorCode:0, retMessage: nil)
            } else {
                completion(isSuccess: true, errorCode:0, retMessage: resp["result"] as? NSDictionary)
            }
        }, option: opt)
    }
}

class MetadataDownloadManager:NSObject{
    
    /**
    异步下载图片的预览图片信息
    :param: url        图片的 url
    :param: completion 下载的回掉
    */
    class func asyncDownloadThumbImage(imageUrl: String, completion:(isSuccess:Bool, metadata:NSData?) -> ()) {
        
        debug_print("开始下载图片缩略图")
        let currentSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
       
        if let url = NSURL(string: imageUrl) {
            let request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 30)
            
            let downloadTask = currentSession.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if error != nil {
                    NSLog("下载图片预览图失败 失败原因是: \(error)")
                    completion(isSuccess: false, metadata: nil)
                } else {
                    
                    completion(isSuccess: true, metadata: data)
                }
            })
            
            downloadTask.resume()
            
        } else {
            completion(isSuccess: false, metadata: nil)
        }
    }
    
    /**
    异步下载语音消息信息
    :param: url        语音的 url
    :param: completion 下载的回掉
    */
    class func asyncDownloadAudioData(audioMessage: AudioMessage, completion:(isSuccess:Bool, retMessage:AudioMessage) -> ()) {
        
        debug_print("开始下载语音")
        let currentSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        if audioMessage.remoteUrl == nil {
            return
        }
        if let url = NSURL(string: audioMessage.remoteUrl!) {
            let request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 30)
            
            let downloadTask = currentSession.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                if error != nil {
                    NSLog("下载语音失败 失败原因是: \(error)")
                    completion(isSuccess: false, retMessage: audioMessage)
                } else {
                    
                    dispatch_async(metadataOperationQueue, { () -> Void in
                        let audioWavPath = IMClientManager.shareInstance().userChatAudioPath.stringByAppendingString("\(audioMessage.metadataId!).wav")
                        
                        let tempAmrPath = IMClientManager.shareInstance().userChatTempPath.stringByAppendingString("\(audioMessage.metadataId!).amr")
                        
                        if let audioData = data {
                            let fileManager =  NSFileManager()
                            fileManager.createFileAtPath(tempAmrPath, contents: audioData, attributes: nil)
                            
                            VoiceConverter.amrToWav(tempAmrPath, wavSavePath: audioWavPath)
                            NSLog("下载语音成功 保存后的地址为: \(audioWavPath)")
                            
                            do {
                                try fileManager.removeItemAtPath(tempAmrPath)
                            } catch {
                                
                            }
                            
                            audioMessage.localPath = audioWavPath
                            audioMessage.updateMessageContent()
                            let daoHelper = DaoHelper.shareInstance()
                            daoHelper.updateMessageContents("chat_\(audioMessage.chatterId)", message: audioMessage)
                        }
                        completion(isSuccess: true, retMessage: audioMessage)
                    })
                    
                }
            })
            
            downloadTask.resume()
            
        } else {
            completion(isSuccess: false, retMessage: audioMessage)
        }
    }

    
    
}
































