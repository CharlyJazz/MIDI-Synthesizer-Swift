//
//  Oscillator.swift
//  Synthesizer
//
//  Created by Carlos Azuaje on 06/01/2023.
//

import Foundation

typealias Signal = (Float, Float) -> (Float)

struct Oscillator {
    static var amplitude: Float = 1

    static let sine = { (time: Float, frequency: Float) -> Float in
        return Oscillator.amplitude * sin(2.0 * Float.pi * frequency * time)
    }
    
    static let midiNoteToFreq = { (midiNumber: UInt8) -> Float in
        return (440 / 32) * pow(2, ( (Float(midiNumber) - 9) / 12 ))
    }
}
