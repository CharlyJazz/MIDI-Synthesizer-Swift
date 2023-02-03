//
//  ContentView.swift
//  Synthesizer
//
//  Created by Carlos Azuaje on 03/01/2023.
//

import SwiftUI
import Gong

struct ContentView: View {
    
    @State public var synth = Synth<any SynthProtocol>()
    @State private var observerTokens = [MIDIObserverTokens]()
    
    var body: some View {
        HStack(spacing: 8.0) {
            Text("Detecting Keyboard MIDI Notes")
        }
        .padding()
        .onAppear(perform: subscribe)
        .onDisappear(perform: unsubscribe)
    }
    
}

extension ContentView {
    
    func subscribe() {
        observerTokens.append(MIDI.addObserver(self))
        synth.volume = 0.5
    }
    
    func unsubscribe() {
        synth.shutdownAVAudioEngine()
        for observerTokens in observerTokens {
            MIDI.removeObserver(observerTokens)
        }
    }
    
}

extension ContentView: MIDIObserver {
    
    func receive(_ notice: MIDINotice) {

    }

    func receive(_ packet: MIDIPacket, from source: MIDISource) {
        switch packet.message {
        case let .noteOn(_, key, _):
            synth.attachSourceNode(midiKeyCode: key)
        case let .noteOff(_, key, _):
            synth.detachSourceNode(midiKeyCode: key)
        default:
            break
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
