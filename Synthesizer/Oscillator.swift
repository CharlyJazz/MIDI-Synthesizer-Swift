//
//  Oscillator.swift
//  Synthesizer
//
//  Created by Carlos Azuaje on 06/01/2023.
//

import Foundation

typealias Signal = (Float, Float) -> (Float)

class Oscillator {
    // The amplitude of the oscillator's output signal
    static var amplitude: Float = 1
    
    // The sample rate of the audio system
    let sampleRate: Double
    
    // The attack time of the ADSR envelope (in seconds)
    static var attackTime: Float = 0.02
    
    // The decay time of the ADSR envelope (in seconds)
    static var decayTime: Float = 0.2
    
    // The sustain level of the ADSR envelope (between 0 and 1)
    static var sustainLevel: Float = 0.4
    
    // The release time of the ADSR envelope (in seconds)
    static var releaseTime: Float = 0.6
    
    init(sampleRate: Double) {
        self.sampleRate = sampleRate
    }
    
    // Generate an ADSR envelope for a given time
    func adsrEnvelope(time: Float) -> Float {
        let attackSamples = Int(Double(Oscillator.attackTime) * sampleRate)
        let decaySamples = Int(Double(Oscillator.decayTime) * sampleRate)
        let releaseSamples = Int(Double(Oscillator.releaseTime) * sampleRate)
        
        // Calculate the envelope value for the current time
        if time < Oscillator.attackTime {
            // Attack phase
            let attackDelta = Oscillator.amplitude / Float(attackSamples)
            return attackDelta * Float(Double(time) * sampleRate)
        } else if time < (Oscillator.attackTime + Oscillator.decayTime) {
            // Decay phase
            let decayDelta = (Oscillator.amplitude - Oscillator.sustainLevel) / Float(decaySamples)
            let decayTime = time - Oscillator.attackTime
            return Oscillator.amplitude - decayDelta * Float(Double(decayTime) * sampleRate)
        } else if time < (Oscillator.attackTime + Oscillator.decayTime + Oscillator.sustainLevel) {
            return Oscillator.sustainLevel
        } else {
            // Release phase
            let releaseDelta = Oscillator.sustainLevel / Float(releaseSamples)
            let releaseTime = time - (Oscillator.attackTime + Oscillator.decayTime + Oscillator.sustainLevel)
            let releaseLevel = Oscillator.sustainLevel - releaseDelta * Float(Double(releaseTime) * sampleRate)
            if releaseLevel <= 0 {
//                https://github.com/anujagannath24/ADSRenvelope/blob/master/ADSR.c
//                Still need figure out the reset attack for next time with press same key
                return 0
            } else {
                return releaseLevel
            }
        }
    }
    
    // The sine wave signal generator function that takes a time and frequency and returns the sample value of a sine wave at that time and frequency
    func sine(time: Float, frequency: Float) -> Float {
        // Generate the sine wave sample value at the given time and frequency
        let sineValue = sin(2.0 * Float.pi * frequency * time)
        
        // Apply the ADSR envelope to the sine wave sample value
        let envelopeValue = adsrEnvelope(time: time)
        return Oscillator.amplitude * envelopeValue * sineValue
    }
    
    func piano(time: Float, frequency: Float) -> Float {
        let harmonic1 = Oscillator.amplitude * sin(2.0 * Float.pi * frequency * time)
        let harmonic2 = (Oscillator.amplitude / 2) * sin(2.0 * Float.pi * 2 * frequency * time)
        let harmonic3 = (Oscillator.amplitude / 3) * sin(2.0 * Float.pi * 3 * frequency * time)
        let harmonic4 = (Oscillator.amplitude / 4) * sin(2.0 * Float.pi * 4 * frequency * time)
        let harmonic5 = (Oscillator.amplitude / 5) * sin(2.0 * Float.pi * 5 * frequency * time)
        let harmonic6 = (Oscillator.amplitude / 6) * sin(2.0 * Float.pi * 6 * frequency * time)
        
        // Apply ADSR envelope
        let envelope = adsrEnvelope(time: time)
        return envelope * tanh(harmonic1 + harmonic2 + harmonic3 + harmonic4 + harmonic5 + harmonic6)
    }

    static func midiNoteToFreq(midiNumber: UInt8) -> Float {
        return (440 / 32) * pow(2, ( (Float(midiNumber) - 9) / 12 ))
    }
}
