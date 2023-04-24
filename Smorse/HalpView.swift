//
//  HalpView.swift
//  Smorse
//
//  Created by Kevin Conner on 2023-04-23.
//

import SwiftUI

struct HalpView: View {
    
    var body: some View {
        let entries = Array(morseDictionary).sorted {
            $0.value < $1.value
        }
        
        ScrollView {
            VStack {
                ForEach(entries, id: \.key) { entry in
                    HStack {
                        Text(entry.value).bold()
                        + Text("  ") +
                        Text(entry.key.flatMap { [$0, .unitInterval] }.morseText)
                        
                        Spacer()
                    }
                    .font(.title3)
                    .fontDesign(.monospaced)
                }
            }
            .scenePadding()
        }
    }
    
}

struct HalpView_Previews: PreviewProvider {
    static var previews: some View {
        HalpView()
    }
}
