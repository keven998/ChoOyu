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
    func beginRecordAudio()
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

@objc protocol ChatManagerAudioDelegate {
    
    optional func audioRecordEnd(audioPath: String)
    
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
    
    weak var delegate: ChatManagerAudioDelegate?
    
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

    func updateMeters() {
        timeCounter += 0.1
        averagePower = audioRecordDeviceManager.updateMeters()
        println("正在录音，已经录制：\(timeCounter) 声音分贝为：\(averagePower)")
    }
    
    //MARK: ChatManagerAudioProtocol
    func beginRecordAudio() {
        audioRecordDeviceManager.audioManagerDelegate = self
        audioPath = documentPath.stringByAppendingPathComponent("temp.wav")
        var audioUrl = NSURL(string: audioPath)
        audioRecordDeviceManager.beginRecordAudio(audioUrl!)
        startTimer()
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
            delegate?.playAudioEnded?(currentMessageId)
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
        timeCounter = 0
        stopTimer()
        if audioIsValid {
            delegate?.audioRecordEnd?(audioPath)
        } else {
            // TODO: 删除录音文件
        }
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
        delegate?.playAudioEnded?(currentMessageId)
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer!) {
        NSLog("播放被打断");
        audioPlayer = nil
        delegate?.playAudioEnded?(currentMessageId)

    }
}







