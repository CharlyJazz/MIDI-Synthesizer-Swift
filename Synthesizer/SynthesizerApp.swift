//
//  SynthesizerApp.swift
//  Synthesizer
//
//  Created by Carlos Azuaje on 06/01/2023.
//

import SwiftUI
import Foundation
import Gong

@main
struct SynthesizerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: MIDI.connect)
                .onDisappear(perform: MIDI.connect)
                .frame(width: 1000, height: 150)
        }
    }
}
