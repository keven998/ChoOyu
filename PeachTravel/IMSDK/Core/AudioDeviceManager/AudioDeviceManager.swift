//
//  AudioDeviceManager.swift
//  TZIM
//
//  Created by liangpengshuai on 4/22/15.
//  Copyright (c) 2015 com.aizou.www. All rights reserved.
//

import UIKit
import AVFoundation

private let audioRecordDeviceManager = AudioRecordDeviceManager()
protocol AudioManagerDelegate {
    
    /**
    录音开始回调
    */
    func audioRecordBegin()
    
    /**
    录音结束回掉
    */
    func audioRecordEnd()
    
    /**
    录音被打断
    */
    func audioRecordInterrupt()
    
    /**
    录音打断后恢复
    */
    func audioRecordResume()
}

class AudioRecordDeviceManager: NSObject, AVAudioRecorderDelegate {
    var audioManagerDelegate: AudioManagerDelegate?
    var recorder: AVAudioRecorder!
    var isRecording: Bool = false
    
    class func shareInstance() -> AudioRecordDeviceManager {
        return audioRecordDeviceManager
    }
    
    override init() {
        super.init()
    }
    
    //MARK: public method
    /**
    开始录音
    */
    
    func beginRecordAudio(audioUrl: NSURL, prepareBlock: ((canRecord: Bool) ->())) {
        if isRecording {
            prepareBlock(canRecord: false);
            return
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateRecordState:" , name:
            AVAudioSessionInterruptionNotification, object: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
            AVAudioSession.sharedInstance().requestRecordPermission { (isPermission: Bool) -> Void in
                if isPermission {
                    do {
                        self.recorder = try AVAudioRecorder(URL: audioUrl, settings: AudioRecordDeviceManager.getAudioRecorderSettingDict() as! [String : AnyObject])
                        self.recorder.delegate = self
                        self.recorder.meteringEnabled = true
                        self.recorder.prepareToRecord()
                        self.isRecording = true
                        self.recorder.record()
                        prepareBlock(canRecord: true);
                    } catch {
                        
                    }
                } else {
                    prepareBlock(canRecord: false);
                    let alertView = UIAlertView(title: nil, message: "去隐私里打开语音访问", delegate: nil, cancelButtonTitle: "取消")
                    alertView.show()
                }
            }
        } catch {
            
        }
    }

    /**
    结束录音
    */
    func stopRecordAudio() {
        if recorder != nil {
            recorder.stop()
        }
        self.isRecording = false
    }
    
    /**
    更新音频峰值
    
    :returns: 返回声道0 的分贝
    */
    func updateMeters() -> Float {
        recorder.updateMeters()
        return recorder.averagePowerForChannel(0)
    }
    
    /**
    获取录音设置
    @returns 录音设置
    */
    private class func getAudioRecorderSettingDict() -> NSDictionary {
        let retDic = [
            AVSampleRateKey: 8000.0,
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVLinearPCMBitDepthKey: 16,
            AVNumberOfChannelsKey: 1
        ]
        return retDic
    }
    
    //MARK:****AVAudioRecorderDelegate  && AVAudioRecorderNoti****
    func updateRecordState(noti: NSNotification) {
        let audioInterruptionType : AnyObject? = noti.userInfo?[AVAudioSessionInterruptionTypeKey]
        if let why = audioInterruptionType as? UInt {
            if let type = AVAudioSessionInterruptionType(rawValue: why) {
                if type == .Began {
                    debug_print("AudioInterruptionType Began")
                    audioManagerDelegate?.audioRecordInterrupt()
                    
                } else {
                    let audioInterruptionOption: AnyObject? = noti.userInfo![AVAudioSessionInterruptionOptionKey]
                    if let opt = audioInterruptionOption as? UInt {
                        let opts = AVAudioSessionInterruptionOptions(rawValue: opt)
                        if opts == .ShouldResume {
                            debug_print("should resume")
                            audioManagerDelegate?.audioRecordResume()
                        } else {
                            debug_print("not should resume")
                        }
                    }
                }
            }
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        debug_print("录音结束")
        audioManagerDelegate?.audioRecordEnd()
    }
    
}








