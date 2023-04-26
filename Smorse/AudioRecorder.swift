//
//  AudioRecorder.swift
//  Smorse
//
//  Created by Kevin Conner on 2023-04-25.
//

import AVFoundation

class AudioRecorder: NSObject {
    
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
        Task {
            await monitorLoudSounds()
        }
    }

    func monitorLoudSounds() async {
        guard let recorder = audioRecorder else { return }
        recorder.updateMeters()

        let power = recorder.averagePower(forChannel: 0)
        let threshold: Float = -10.0 // Adjust this value based on your requirements

        if power > threshold {
            print("Loud sound detected")
            // Add your reaction code here
        }

        do {
            try await Task.sleep(nanoseconds: 5_000_000) // Sleep for 5 milliseconds (0.005 seconds)
        } catch {
            // Task was cancelled
            return
        }
        
        // I hope we get tail recursion
        await monitorLoudSounds()
    }
    
    func stopMonitoringLoudSounds() {
        audioRecorder?.stop()
    }
    
}
