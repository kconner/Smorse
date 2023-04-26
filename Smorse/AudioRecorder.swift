//
//  AudioRecorder.swift
//  Smorse
//
//  Created by Kevin Conner on 2023-04-25.
//

import AVFoundation

class AudioRecorder: NSObject {
    
    let backgroundQueue = DispatchQueue(label: "com.yourappname.loudsounddetector", qos: .background)
    
    let semaphore = DispatchSemaphore(value: 0)
    
    var audioRecorder: AVAudioRecorder?
    
    func setUpAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
        
        let recordingSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: getAudioFileURL(), settings: recordingSettings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
        } catch {
            print("Error setting up audio recorder: \(error)")
        }
    }
    
    func getAudioFileURL() -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = urls[0] as URL
        return documentsDirectory.appendingPathComponent("audio.m4a")
    }
    
}

extension AudioRecorder: AVAudioRecorderDelegate {
    
    func startMonitoringLoudSounds() {
        audioRecorder?.record()
        monitorLoudSounds()
    }
    
    func monitorLoudSounds() {
        backgroundQueue.async { [weak self] in
            guard let self, let recorder = self.audioRecorder else { return }
            recorder.updateMeters()

            let power = recorder.averagePower(forChannel: 0)
            let threshold: Float = -10.0 // Adjust this value based on your requirements

            if power > threshold {
                print("Loud sound detected")
                // Add your reaction code here
            }

            self.semaphore.signal()
        }

        let delayTime = DispatchTime.now() + 0.01 // Adjust the delay for higher frequency sampling
        _ = semaphore.wait(timeout: delayTime)
        
        if let audioRecorder, audioRecorder.isRecording {
            monitorLoudSounds()
        }
    }

    func stopMonitoringLoudSounds() {
        audioRecorder?.stop()
    }
    
}
