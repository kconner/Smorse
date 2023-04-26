//
//  AudioRecorder.swift
//  Smorse
//
//  Created by Kevin Conner on 2023-04-25.
//

import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    
    private var task: Task<Void, Never>? = nil
    
    private var audioRecorder: AVAudioRecorder?
    
    func setUpAudioRecorder() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [.allowBluetooth])
            try audioSession.setActive(true)
        } catch {
            print("Error setting up audio session: \(error)")
        }
        
        let recordingSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 8000.0, // As low as possible; we don't want the data
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue
        ]
        
        do {
            let audioRecorder = try AVAudioRecorder(url: getAudioFileURL(), settings: recordingSettings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            self.audioRecorder = audioRecorder
        } catch {
            print("Error setting up audio recorder: \(error)")
        }
    }
    
    func getAudioFileURL() -> URL {
        let fileManager = FileManager.default
        let folder = fileManager.temporaryDirectory
        return folder.appendingPathComponent("audio.m4a")
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    func startMonitoringLoudSounds() {
        stopMonitoringLoudSounds()
        
        audioRecorder?.record()
        
        task = Task {
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
        task?.cancel()
        task = nil
        
        audioRecorder?.stop()
    }
    
}
