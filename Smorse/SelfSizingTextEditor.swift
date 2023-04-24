//
//  SelfSizingTextEditor.swift
//  Smorse
//
//  Created by Kevin Conner on 2023-04-23.
//

import SwiftUI

struct SelfSizingTextEditor: View {
    
    private struct HeightKey: PreferenceKey {
        static let defaultValue: CGFloat = 0
        
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value = value + nextValue()
        }
    }
    
    @Binding var value: String
    @State var textEditorHeight: CGFloat = 0

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Draw plain text where TextEditor will
            Text(value)
                .padding(.top, 8)        // Mimic TextEditor
                .padding(.horizontal, 5) // Mimic TextEditor
                .padding(.bottom, 10)    // Mimic TextEditor
                // .foregroundColor(.red).border(.red) // debug
                .hidden() // comment to debug
                .background(
                    // Measure the height
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: HeightKey.self,
                            value: proxy.size.height
                        )
                    }
                )

            TextEditor(text: $value)
                .frame(height: textEditorHeight) // Apply the measured height
                .scrollDisabled(true)
                .scrollBounceBehavior(.basedOnSize)
                // .scrollContentBackground(.hidden) // debug
                // .scrollIndicators(.visible) // debug
                // .border(.blue) // debug
        }
        .onPreferenceChange(HeightKey.self) { value in
            textEditorHeight = value
        }
    }
    
}

struct SelfSizingTextEditor_Previews: PreviewProvider {
    
    static var previews: some View {
        PreviewState("Text to be edited") { $value in
            SelfSizingTextEditor(value: $value)
                .previewLayout(.sizeThatFits)
                .previewDisplayName("View")
            
            NavigationStack {
                ScrollView {
                    SelfSizingTextEditor(value: $value)
                        .font(.headline)
                        .scenePadding()
                }
                .navigationTitle("Screen")
                .navigationBarTitleDisplayMode(.inline)
            }
            .previewDisplayName("In scroll view")
        }
    }
    
}
