//
//  Synth.swift
//  Synthesizer
//
//  Created by Carlos Azuaje on 06/01/2023.
//

import AVFoundation
import Foundation

protocol SynthProtocol: ObservableObject {
    func attachSourceNode(key: UInt8)
    func detachSourceNode(key: UInt8)
    func shutdownAVAudioEngine()
}

let LIST_MIDI_CODE = (21...108)

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
    private let deltaTime: Float
    private var hashNotesTimes = [UInt8: Float]()
    private var hashNotesSourceNodes = [UInt8: AVAudioSourceNode]()
    private let sampleRate: Double
    private let mainMixer: AVAudioMixerNode
    private let outputNode: AVAudioOutputNode
    private let inputFormat: NSObject?
    private let format: AVAudioFormat
    private var signal: Signal
    
    init(signal: @escaping Signal = Oscillator.sine) {
        audioEngine = AVAudioEngine()
        
        for code in LIST_MIDI_CODE {
            self.hashNotesTimes[UInt8(code)] = 0
        }

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
     
    private func createSourceNode(frequency: Float, midiKeyCode: UInt8) -> AVAudioSourceNode {
        return AVAudioSourceNode { (_, _, frameCount, audioBufferList) -> OSStatus in
           let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
           for frame in 0..<Int(frameCount) {
               if ((self.hashNotesTimes[midiKeyCode]) != nil) {
                   let sampleVal = self.signal(self.hashNotesTimes[midiKeyCode]!, frequency)
                   self.hashNotesTimes[midiKeyCode]! += self.deltaTime
                   for buffer in ablPointer {
                       let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                       buf[frame] = sampleVal
                   }
               }
           }
           return noErr
       }
    }
    
    public func attachSourceNode(midiKeyCode: UInt8) {
        let frequency: Float = Oscillator.midiNoteToFreq(midiKeyCode)
        let sourceNode = createSourceNode(frequency: frequency,  midiKeyCode: midiKeyCode)
        hashNotesSourceNodes[midiKeyCode] = sourceNode
        audioEngine.attach(sourceNode)
        audioEngine.connect(
            sourceNode,
            to: self.mainMixer,
            format: self.inputFormat as? AVAudioFormat
        )
    }
    
    public func detachSourceNode(midiKeyCode: UInt8) {
        if let sourceNode = self.hashNotesSourceNodes[midiKeyCode] {
            audioEngine.detach(sourceNode)
            self.hashNotesSourceNodes[midiKeyCode] = nil
        }
    }
    
    public func shutdownAVAudioEngine() {
        self.audioEngine.disconnectNodeInput(self.mainMixer)
        self.audioEngine.disconnectNodeOutput(self.outputNode)
    }
}
