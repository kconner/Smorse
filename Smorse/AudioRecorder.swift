//
//  AudioRecorder.swift
//  Smorse
//
//  Created by Kevin Conner on 2023-04-25.
//

import AVFoundation

@MainActor
class SampleStore: ObservableObject, SamplerDelegate {
    
    @Published var power: Float = 0
    
    private var audioRecorder: Sampler?
    
    var enabled = false {
        didSet {
            guard enabled != oldValue else { return }
            
            if enabled {
                if audioRecorder == nil {
                    audioRecorder = try? Sampler(delegate: self)
                }
                
                audioRecorder?.start()
            } else {
                audioRecorder?.stop()
            }
        }
    }
    
    // MARK: - SamplerDelegate
    
    func samplerDelegateDidMeasure(power: Float) {
        self.power = power
    }
    
}

@MainActor
protocol SamplerDelegate: AnyObject {
    func samplerDelegateDidMeasure(power: Float)
}

class Sampler: NSObject, AVAudioRecorderDelegate {
    
    private var audioRecorder: AVAudioRecorder?
    private var task: Task<Void, Never>? = nil
    
    private weak var delegate: SamplerDelegate?
    
    init(delegate: SamplerDelegate) throws {
        self.delegate = delegate
        
        super.init()
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: [.allowBluetooth])
        try audioSession.setActive(true)
        
        let recordingSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 8000.0, // As low as possible; we don't want the data
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue
        ]
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("discard.m4a")
        let audioRecorder = try AVAudioRecorder(url: url, settings: recordingSettings)
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        self.audioRecorder = audioRecorder
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    func start() {
        audioRecorder?.record()
        
        task = Task.detached(priority: .utility) {
            await self.monitorLoudSounds()
        }
    }

    private func monitorLoudSounds(priorPower: Float = 0) async {
        guard let recorder = audioRecorder else { return }
        recorder.updateMeters()

        let power = recorder.averagePower(forChannel: 0)
        // let threshold: Float = -10.0 // Adjust this value based on your requirements
        
        print("\(priorPower) -> \(power)")
        
        Task {
            await MainActor.run {
                self.delegate?.samplerDelegateDidMeasure(power: power)
            }
        }

        do {
            try await Task.sleep(nanoseconds: 50_000_000) // 50 ms
        } catch {
            // Task was cancelled
            return
        }
        
        // I hope we get tail recursion
        await monitorLoudSounds(priorPower: power)
    }
    
    func stop() {
        task?.cancel()
        task = nil
        
        audioRecorder?.stop()
    }
    
}
