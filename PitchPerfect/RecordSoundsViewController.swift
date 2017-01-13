//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by 장진영 on 2016. 12. 28..
//  Copyright © 2016년 Udaticy. All rights reserved.
//

import UIKit
import AVFoundation


class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!
    var recordTimer: Timer!

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    // MARK: RecordingState
    
    enum RecordingState { case recording, notRecording }
    

    // MARK: Record Functions

    @IBAction func recordAudio(_ sender: AnyObject) {
    
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoic.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator:"/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        
        
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
        recordConfigureUI(.recording)
        
        // schedule a record timer for display record time
        self.recordTimer = Timer(timeInterval: 1, target: self, selector: #selector(RecordSoundsViewController.updateRecordTime), userInfo: nil, repeats: true)
        RunLoop.main.add(self.recordTimer!, forMode: RunLoopMode.defaultRunLoopMode)

    }
    
    // set time format and update label text
    func updateRecordTime() {
        let min = Int(audioRecorder.currentTime/60)
        let sec = Int(audioRecorder.currentTime)%60
        recordingLabel.text = NSString(format: "%02d : %02d", min, sec) as String
    }
    
    
    @IBAction func stopRecording(_ sender: AnyObject) {
        recordConfigureUI(.notRecording)
        audioRecorder.stop()
        
        if let recordTimer = recordTimer {
            recordTimer.invalidate()
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag{
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("recording was not successful")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundVC.recordedAudioURL = recordedAudioURL
        }
    }

    
     // MARK: UI Functions
    
    func recordConfigureUI(_ recordState: RecordingState) {
        switch(recordState) {
        case .recording:
            stopRecordingButton.isEnabled = true
            recordButton.isEnabled = false
            
        case .notRecording:
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
            recordingLabel.text = "Tap to Record"
            
            
        }
    }
}

