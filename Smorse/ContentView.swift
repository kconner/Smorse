//
//  ContentView.swift
//  Smorse
//
//  Created by Kevin Conner on 2023-04-23.
//

import SwiftUI

struct ContentView: View {
    
    @State var morseString: [MorseCharacter] = [
        .dot, .unitInterval, .dot, .unitInterval, .dot, .letterInterval,
        .dash, .unitInterval, .dash, .unitInterval, .dash, .letterInterval,
        .dot, .unitInterval, .dot, .unitInterval, .dot, .wordInterval
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    SelfSizingTextEditor(value: .constant(morseString.morseText))
                        .fontDesign(.monospaced)
                        .font(.headline)
                    
                    SelfSizingTextEditor(value: .constant(morseString.latinText))
                        .font(.title)
                }
                .findDisabled(true)
                
                TimedButton { upDuration, downDuration in
                    let unit: TimeInterval = 0.15
                    
                    if let upDuration {
                        morseString.append(
                            upDuration < 2 * unit
                            ? .unitInterval
                            : upDuration < 5 * unit
                            ? .letterInterval
                            : .wordInterval
                        )
                    }
                    
                    morseString.append(downDuration < unit ? .dot : .dash)
                } label: { isTouching in
                    Text("BOOP")
                        .font(.title)
                        .bold(isTouching)
                        .dynamicTypeSize(.accessibility5)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .fill(.yellow)
                        )
                }
            }
            .scenePadding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
