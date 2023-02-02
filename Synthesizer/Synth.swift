//
//  Synth.swift
//  Synthesizer
//
//  Created by Carlos Azuaje on 06/01/2023.
//

import AVFoundation
import Foundation

protocol SynthProtocol: ObservableObject {
    func attachSourceNode(frequency: Float)
}

class Synth<SynthProtocol> {
    // MARK: Properties
//    public static let shared = Synth()
    public var volume: Float {
        set {
            audioEngine.mainMixerNode.outputVolume = newValue
        }
        get {
            return audioEngine.mainMixerNode.outputVolume
        }
    }
    private var audioEngine: AVAudioEngine
    private var time: Float = 0
    private let sampleRate: Double
    private let deltaTime: Float
    private let mainMixer: AVAudioMixerNode
    private let outputNode: AVAudioOutputNode
    private let inputFormat: NSObject?
    private let format: AVAudioFormat
    private var signal: Signal
    
    init(signal: @escaping Signal = Oscillator.sine) {
        audioEngine = AVAudioEngine()

        self.mainMixer = audioEngine.mainMixerNode
        self.outputNode = audioEngine.outputNode
        self.format = outputNode.inputFormat(forBus: 0)
        self.sampleRate = self.format.sampleRate
        
        self.inputFormat = AVAudioFormat(
            commonFormat: self.format.commonFormat,
            sampleRate: self.sampleRate,
            channels: 1,
            interleaved: self.format.isInterleaved
        )
        
        self.deltaTime = 1 / Float(self.sampleRate) // 1 / 44,100
        
        self.signal = signal

        audioEngine.connect(mainMixer, to: outputNode, format: nil)
        mainMixer.outputVolume = 0

        do {
           try audioEngine.start()
        } catch {
           print("Could not start engine: \(error.localizedDescription)")
        }
    }
 
    // MARK: Public Functions
    
    private func createSourceNode(frequency: Float) -> AVAudioSourceNode {
        return AVAudioSourceNode { (_, _, frameCount, audioBufferList) -> OSStatus in
           let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
           for frame in 0..<Int(frameCount) {
//               Create self.time and a self.deltaTime for every note
//               I can use a Hash Map where every Midi Code is a Key and the
//               time and deltatime are par of the value as dict
//               So I need and to the arguments of this method the midi key
               let sampleVal = self.signal(self.time, frequency)
               self.time += self.deltaTime
               for buffer in ablPointer {
                   let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                   buf[frame] = sampleVal
               }
           }
           return noErr
       }
    }
    
    public func attachSourceNode(frequency: Float) {
        let sourceNode = createSourceNode(frequency: frequency)
        audioEngine.attach(sourceNode)
        audioEngine.connect(
            sourceNode,
            to: self.mainMixer,
            format: self.inputFormat as? AVAudioFormat
        )
    }
}
