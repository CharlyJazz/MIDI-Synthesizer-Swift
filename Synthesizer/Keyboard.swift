//
//  Keyboard.swift
//  Synthesizer
//
//  Created by Carlos Azuaje on 23/02/2023.
//

import SwiftUI

let whiteKeyWidth: CGFloat = 20
let dictXOffsetWhiteKeys: [Int: CGFloat] = [
    36: 0,
    38: 20 / 2 * -1,
    40: 20 * -1,
    41: 20 * -1 + 3,
    43: -27,
    45: -37,
    47: -47,
    48: -44,
    50: -54,
    52: -64,
    53: -61,
    55: -71,
    57: -80,
    59: -90,
    60: -87,
    62: -97,
    64: -107,
    65: -104,
    67: -114,
    69: -123,
    71: -133,
    72: -130,
    74: -140,
    76: -150,
    77: -147,
    79: -157,
    81: -167,
    83: -177,
    84: -174,
    86: -184,
    88: -194,
    89: -191,
    91: -201,
    93: -211,
    95: -221
]

let dictXOffsetBlackKeys: [Int: CGFloat] = [
    37: -5,
    39: -15,
    42: -23,
    44: -33,
    46: -39,
    49: -49,
    51: -58,
    54: -65,
    56: -75,
    58: -85,
    61: -92,
    63: -102,
    66: -109,
    68: -114,
    70: -127,
    73: -135,
    75: -145,
    78: -152,
    80: -162,
    82: -172,
    85: -180,
    87: -189,
    90: -196,
    92: -206,
    94: -216,
]

let dictCNoteOctavesLabels: [Int: String] = [
    36: "C3",
    48: "C4",
    60: "C5",
    72: "C6",
    84: "C7",
]

struct Keyboard: View {
    var onTapKey: ((Int) -> Void)?
    
    func  calculatePercentage(value:Double,percentageVal:Double)->Double{
        let val = value * percentageVal
        return val / 100.0
    }
    
    func isWhiteKey(midiCode: Int) -> Bool {
        let k = midiCode % 12
        return (k == 0 || k == 2 || k == 4 || k == 5 || k == 7 || k == 9 || k == 11)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 1) {
            ForEach((36..<96)) { code in
                if isWhiteKey(midiCode: code){
                        Button(action: {
                            if ((onTapKey) != nil) {
                                onTapKey!(code)
                            }
                        }) {
                        Text(String(dictCNoteOctavesLabels[code] ?? ""))
                            .font(.system(size: 15))
                            .padding(.top, 40)
                            .foregroundColor(Color.black)
                            .frame(width: whiteKeyWidth, height: 80)
                            .background(Color.white)
                    }.buttonStyle(.plain)
                        .offset(
                            x: dictXOffsetWhiteKeys[code] ?? 0
                        )
                        .zIndex(0)
                } else {
                    Button(action: {
                        if ((onTapKey) != nil) {
                            onTapKey!(code)
                        }
                    }) {
                        Text("")
                            .font(.system(size: 10))
                            .foregroundColor(Color.white)
                            .frame(
                                width: calculatePercentage(value: whiteKeyWidth, percentageVal:  60),
                                height: 50)
                            .background(Color.black)
                    }.buttonStyle(.plain)
                        .offset(
                            x: dictXOffsetBlackKeys[code] ?? 0
                        )
                        .zIndex(1)
                }
            }
        }.frame(height: 80)
    }
}

struct Keyboard_Previews: PreviewProvider {
    static var previews: some View {
        Keyboard()
    }
}

