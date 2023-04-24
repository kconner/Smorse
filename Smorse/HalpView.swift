//
//  HalpView.swift
//  Smorse
//
//  Created by Kevin Conner on 2023-04-23.
//

import SwiftUI

struct HalpView: View {
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(morseDictionaryEntries, id: \.0) { entry in
                    let (key, value) = entry
                    
                    HStack {
                        Text(value).bold()
                        + Text("  ") +
                        Text(key.flatMap { [$0, .unitInterval] }.morseText)
                        
                        Spacer()
                    }
                    .font(.headline)
                    .fontDesign(.monospaced)
                }
            }
        }
    }
    
}

struct HalpView_Previews: PreviewProvider {
    static var previews: some View {
        HalpView()
    }
}
