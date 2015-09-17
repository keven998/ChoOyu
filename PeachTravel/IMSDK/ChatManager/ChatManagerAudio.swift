//
//  ChatManagerAudio.swift
//  TZIM
//
//  Created by liangpengshuai on 4/22/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit
import AVFoundation

protocol ChatManagerAudioProtocol {
    /**
    开始录音
    */
    func beginRecordAudio(prepareBlock: (canRecord: Bool) ->())
    /**
    结束录音
    */
    func stopRecordAudio()
    
    /**
    取消录音
    */
    func cancelRecordAudio()
    
    /**
    删除录音文件
    */
    func deleteRecordAudio()
    
    /**
    删除指定录音文件
    :param: audioPath
    */
    func deleteRecordAudio(audioPath: String)
    
    /**
    播放声音
    
    :param: audioPath
    */
    func playAudio(audioPath: String, messageLocalId: Int)

    func stopPlayAudio()
}

@objc protocol ChatManagerAudioRecordDelegate {
    
    optional func audioRecordEnd(audioPath: String, audioLength: Float)

}

@objc protocol ChatManagerAudioPlayDelegate {
    
    optional func playAudioEnded(messageId: Int)
    
}

private let audioManager = ChatManagerAudio()

class ChatManagerAudio: NSObject, ChatManagerAudioProtocol, AudioManagerDelegate, AVAudioPlayerDelegate {
    
    private var audioRecordDeviceManager: AudioRecordDeviceManager!
    private var audioPath : String = ""
    var averagePower: Float = 0.0
    var currentMessageId = 0
    
    //录制的语音是否有效，如果是正常结束录制那么有效，如果是取消录制那么无效
    private var audioIsValid = true
    
    private var audioPlayer: AVAudioPlayer!
    
    weak var chatManagerAudioRecordDelegate: ChatManagerAudioRecordDelegate?
    weak var chatManagerAudioPlayDelegate: ChatManagerAudioPlayDelegate?

    
    var timer: NSTimer!
    
    var timeCounter: Float = 0
    
    class func shareInstance() -> ChatManagerAudio {
        return audioManager;
    }

    override init() {
        audioRecordDeviceManager = AudioRecordDeviceManager.shareInstance()
        super.init()
    }
    
    //MARK: private methods
    
    private func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("updateMeters"), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        if (timer != nil && timer.valid) {
            timer.invalidate()
            timer = nil
        }
    }
    
    /**
    删除录音文件
    */
    private func removeTemtAudioFile() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            var fileManager =  NSFileManager.defaultManager()
            var error: NSError?
            fileManager.removeItemAtPath(self.audioPath, error: &error)
            if error != nil {
                debug_println("移除取消录音的文件文件出错 error\(error)")
            } else {
                debug_print("取消录音，删除录音文件成功")
            }
            
        })
    }

    @objc private func updateMeters() {
        timeCounter += 0.1
        averagePower = audioRecordDeviceManager.updateMeters()
        debug_println("正在录音，已经录制：\(timeCounter) 声音分贝为：\(averagePower)")
    }
    
    //MARK: ChatManagerAudioProtocol
    func beginRecordAudio(prepareBlock: ((canRecord: Bool) ->())) {
        audioRecordDeviceManager.audioManagerDelegate = self
        audioPath = documentPath.stringByAppendingPathComponent("temp.wav")
        var audioUrl = NSURL(string: audioPath)
        audioRecordDeviceManager.beginRecordAudio(audioUrl!, prepareBlock: { (canRecord) -> () in
            if canRecord {
                self.startTimer()
            }
            prepareBlock(canRecord: canRecord)
        })
    }
    
    func stopRecordAudio() {
        audioIsValid = true
        audioRecordDeviceManager.stopRecordAudio()
    }
    
    func cancelRecordAudio() {
        audioIsValid = false
        audioRecordDeviceManager.stopRecordAudio()
    }
    
    func deleteRecordAudio() {
        
    }
    
    func deleteRecordAudio(audioPath: String) {
        
    }
    
    func playAudio(audioPath: String, messageLocalId: Int) {
        if currentMessageId != 0 && currentMessageId != messageLocalId {
            chatManagerAudioPlayDelegate?.playAudioEnded?(currentMessageId)
        }
        if let audioData = NSData.dataWithContentsOfMappedFile(audioPath) as? NSData {
            self.audioPlayer = AVAudioPlayer(data: audioData, error: nil)
            audioPlayer.volume = 0.8;
            audioPlayer.currentTime = 0;
            audioPlayer.prepareToPlay()
            audioPlayer.delegate = self;
            audioPlayer.play()
            currentMessageId = messageLocalId
        }
    }
    
    func stopPlayAudio() {
        if audioPlayer != nil {
            audioPlayer.stop()
            audioPlayer = nil
        }
    }
    
    //MARK: AudioManagerDelegate
    func audioRecordBegin() {
        timeCounter = 0
        stopTimer()
    }
    
    func audioRecordEnd() {
        stopTimer()
        if audioIsValid {
            chatManagerAudioRecordDelegate?.audioRecordEnd?(audioPath, audioLength: timeCounter)
            if timeCounter < 0.8 {
                self.removeTemtAudioFile()
            }
        } else {
           self.removeTemtAudioFile()
        }
        timeCounter = 0
    }
    
    func audioRecordInterrupt() {
        stopTimer()
        
    }
    
    func audioRecordResume() {
        if timer == nil {
            startTimer()
        }
    }
    
    //MARK: AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        NSLog("播放完毕");
        audioPlayer = nil;
        chatManagerAudioPlayDelegate?.playAudioEnded?(currentMessageId)
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer!) {
        NSLog("播放被打断");
        audioPlayer = nil
        chatManagerAudioPlayDelegate?.playAudioEnded?(currentMessageId)

    }
}







