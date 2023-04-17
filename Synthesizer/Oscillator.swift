//
//  Oscillator.swift
//  Synthesizer
//
//  Created by Carlos Azuaje on 06/01/2023.
//

import Foundation

typealias Signal = (Float, Float) -> (Float)

struct Oscillator {
    // The amplitude of the oscillator's output signal
    static var amplitude: Float = 1
    
    // The sample rate of the audio system
    static let sampleRate: Float = 44100.0
    
    // The attack time of the ADSR envelope (in seconds)
    static var attackTime: Float = 0.01 // Why is reseting as the value?
    
    // The decay time of the ADSR envelope (in seconds)
    static var decayTime: Float = 0.1
    
    // The sustain level of the ADSR envelope (between 0 and 1)
    static var sustainLevel: Float = 0.5
    
    // The release time of the ADSR envelope (in seconds)
    static var releaseTime: Float = 0.1
    
    // Generate an ADSR envelope for a given time
    static func adsrEnvelope(time: Float) -> Float {
        let attackSamples = Int(attackTime * sampleRate)
        let decaySamples = Int(decayTime * sampleRate)
        let releaseSamples = Int(releaseTime * sampleRate)
        
        // Calculate the envelope value for the current time
        if time < attackTime {
            // Attack phase
            let attackDelta = Oscillator.amplitude / Float(attackSamples)
            return attackDelta * Float(time * sampleRate)
        } else if time < (attackTime + decayTime) {
            // Decay phase
            let decayDelta = (Oscillator.amplitude - sustainLevel) / Float(decaySamples)
            let decayTime = time - attackTime
            return Oscillator.amplitude - decayDelta * Float(decayTime * sampleRate)
        } else if time < (attackTime + decayTime + sustainLevel) {
            // Sustain phase
            return sustainLevel
        } else {
            // Release phase
            let releaseDelta = sustainLevel / Float(releaseSamples)
            let releaseTime = time - (attackTime + decayTime + sustainLevel)
            return sustainLevel - releaseDelta * Float(releaseTime * sampleRate)
        }
    }
    
    // The sine wave signal generator function that takes a time and frequency and returns the sample value of a sine wave at that time and frequency
    static let sine = { (time: Float, frequency: Float) -> Float in
        // Generate the sine wave sample value at the given time and frequency
        let sineValue = sin(2.0 * Float.pi * frequency * time)
        
        // Apply the ADSR envelope to the sine wave sample value
        let envelopeValue = adsrEnvelope(time: time)
        return amplitude * envelopeValue * sineValue
    }
    
    static let piano = { (time: Float, frequency: Float) -> Float in
        let harmonic1 = Oscillator.amplitude * sin(2.0 * Float.pi * frequency * time)
        let harmonic2 = (Oscillator.amplitude / 2) * sin(2.0 * Float.pi * 2 * frequency * time)
        let harmonic3 = (Oscillator.amplitude / 3) * sin(2.0 * Float.pi * 3 * frequency * time)
        let harmonic4 = (Oscillator.amplitude / 4) * sin(2.0 * Float.pi * 4 * frequency * time)
        let harmonic5 = (Oscillator.amplitude / 5) * sin(2.0 * Float.pi * 5 * frequency * time)
        let harmonic6 = (Oscillator.amplitude / 6) * sin(2.0 * Float.pi * 6 * frequency * time)
        
        let nonLinearDistortion = tanh(harmonic1 + harmonic2 + harmonic3 + harmonic4 + harmonic5 + harmonic6)
    
        // Apply ADSR envelope
        // I need debug the adsrEnvelope method because it has a weird behavior
        // let envelope = adsrEnvelope(time: time)
        // return nonLinearDistortion * envelope
        
        return nonLinearDistortion
    }

    static let midiNoteToFreq = { (midiNumber: UInt8) -> Float in
        return (440 / 32) * pow(2, ( (Float(midiNumber) - 9) / 12 ))
    }
}
