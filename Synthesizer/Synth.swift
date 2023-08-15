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
    
    init() {
        audioEngine = AVAudioEngine()
        
        for code in LIST_MIDI_CODE {
            self.hashNotesTimes[UInt8(code)] = 0
        }
        
        self.mainMixer = audioEngine.mainMixerNode
        self.outputNode = audioEngine.outputNode
        self.format = outputNode.inputFormat(forBus: 0)
        self.sampleRate = self.format.sampleRate
        self.signal = Oscillator(sampleRate: self.sampleRate).piano
        self.inputFormat = AVAudioFormat(
            commonFormat: self.format.commonFormat,
            sampleRate: self.sampleRate,
            channels: 1,
            interleaved: self.format.isInterleaved
        )
        
        self.deltaTime = 1 / Float(self.sampleRate) // 1 / 44,100
        
        audioEngine.connect(mainMixer, to: outputNode, format: nil)
        mainMixer.outputVolume = 0

        do {
           try audioEngine.start()
        } catch {
           print("Could not start engine: \(error.localizedDescription)")
        }
    }

    //    This code uses the pointee property to access the
    //    underlying AudioBuffer struct,
    //    and calculates the stride manually based on the
    //    number of channels and the size of the buffer's
    //    element. It then creates an UnsafeMutableBufferPointer
    //    based on the mData property of the
    //    AudioBuffer, and uses that to write the sample
    //    value for each channel.
    private func createSourceNode(frequency: Float, midiKeyCode: UInt8) -> AVAudioSourceNode {
        return AVAudioSourceNode { (_, _, frameCount, audioBufferList) -> OSStatus in
            let numChannels = Int(audioBufferList.pointee.mNumberBuffers)
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            
            for frame in 0..<Int(frameCount) {
                if let time = self.hashNotesTimes[midiKeyCode] {
                    let sampleVal = self.signal(time, frequency)
                    self.hashNotesTimes[midiKeyCode] = time + self.deltaTime
                    
                    for channel in 0..<numChannels {
                        let buf = UnsafeMutableBufferPointer(start: ablPointer[channel].mData?.assumingMemoryBound(to: Float.self), count: Int(frameCount))
                        buf[frame] = sampleVal
                    }
                }
            }
            
            return noErr
        }
    }

    public func attachSourceNode(midiKeyCode: UInt8) {
        let frequency: Float = Oscillator.midiNoteToFreq(midiNumber: midiKeyCode)
        let sourceNode = createSourceNode(frequency: frequency,  midiKeyCode: midiKeyCode)
        detachSourceNode(midiKeyCode: midiKeyCode)
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
