//
//  Synth.swift
//  Synthesizer
//
//  Created by Carlos Azuaje on 06/01/2023.
//

import AVFoundation
import Foundation

class Synth {
    // MARK: Properties
    public static let shared = Synth()
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
    
    private lazy var sourceNode = AVAudioSourceNode { (_, _, frameCount, audioBufferList) -> OSStatus in
           let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
           for frame in 0..<Int(frameCount) {
               let sampleVal = self.signal(self.time)
               self.time += self.deltaTime
               for buffer in ablPointer {
                   let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                   buf[frame] = sampleVal
               }
           }
           return noErr
       }
       
   private var signal: Signal

    // MARK: Init
    init(signal: @escaping Signal = Oscillator.sine) {
        audioEngine = AVAudioEngine()


        let mainMixer = audioEngine.mainMixerNode
        let outputNode = audioEngine.outputNode
        let format = outputNode.inputFormat(forBus: 0)


        sampleRate = format.sampleRate
        deltaTime = 1 / Float(sampleRate) // 1 / 44,100
        
        self.signal = signal
        let inputFormat = AVAudioFormat(commonFormat: format.commonFormat, sampleRate: sampleRate, channels: 1, interleaved: format.isInterleaved)
        audioEngine.attach(sourceNode)
        audioEngine.connect(sourceNode, to: mainMixer, format: inputFormat)
        audioEngine.connect(mainMixer, to: outputNode, format: nil)
        mainMixer.outputVolume = 0
        do {
           try audioEngine.start()
        } catch {
           print("Could not start engine: \(error.localizedDescription)")
        }
    }
 
    // MARK: Public Functions
    
    public func setWaveformTo(_ signal: @escaping Signal) {
        self.signal = signal
    }
}
