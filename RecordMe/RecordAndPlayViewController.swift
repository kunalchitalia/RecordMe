//
//  RecordAndPlayViewController.swift
//  RecordMe
//
//  Created by Kunal Chitalia on 2/7/15.
//  Copyright (c) 2015 RecordMe. All rights reserved.
//

import UIKit
import AVFoundation

class RecordAndPlayViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    @IBOutlet var recordButton: UIButton!
    
    
    @IBOutlet var stopButton: UIButton!
    
    
    @IBOutlet var playButton: UIButton!
    
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playButton.enabled = false
        stopButton.enabled = false
        
        let dirPaths =
        NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)
        let docsDir = dirPaths[0] as String
        let soundFilePath =
        docsDir.stringByAppendingPathComponent("sound.caf")
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        let recordSettings =
        [AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0]
        
        var error: NSError?
        
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord,
            error: &error)
        
        if let err = error {
            println("audioSession error: \(err.localizedDescription)")
        }
        
        audioRecorder = AVAudioRecorder(URL: soundFileURL,
            settings: recordSettings, error: &error)
        
        if let err = error {
            println("audioSession error: \(err.localizedDescription)")
        } else {
            audioRecorder?.prepareToRecord()
        }
        
    }
    
    @IBAction func recordVoice(sender: UIButton) {
        if audioRecorder?.recording == false {
            playButton.enabled = false
            stopButton.enabled = true
            audioRecorder?.record()
        }
        
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        stopButton.enabled = false
        playButton.enabled = true
        recordButton.enabled = true
        
        if audioRecorder?.recording == true {
            audioRecorder?.stop()
        } else {
            audioPlayer?.stop()
        }
    }

    @IBAction func playAudio(sender: UIButton) {
        if audioRecorder?.recording == false {
            stopButton.enabled = true
            recordButton.enabled = false
            
            var error: NSError?
            
            audioPlayer = AVAudioPlayer(contentsOfURL: audioRecorder?.url,
                error: &error)
            
            audioPlayer?.delegate = self
            
            if let err = error {
                println("audioPlayer error: \(err.localizedDescription)")
            } else {
                //audioPlayer?.play()
                var audioPlayerNode = AVAudioPlayerNode()
                audioEngine = AVAudioEngine()
                audioFile = AVAudioFile(forReading: audioRecorder?.url, error: nil)
                audioEngine.attachNode(audioPlayerNode)
                
                var changePitchEffect = AVAudioUnitTimePitch()
                changePitchEffect.pitch = -1000
                audioEngine.attachNode(changePitchEffect)
                
                audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
                audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
                
                audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
                audioEngine.startAndReturnError(nil)
                
                audioPlayerNode.play()

            }
        }
        
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        recordButton.enabled = true
        stopButton.enabled = false
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        println("Audio Play Decode Error")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        println("Audio Record Encode Error")
    }
    
    /*func playAudioWithVariablePitch(pitch: Float) {
        audioPlayer?.stop()
        audioEngine.stop()
        audioEngine.reset()
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        
        audioPlayerNode.play()
    }*/
}

