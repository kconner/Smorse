//
//  PreviewState.swift
//  Smorse
//
//  Created by Kevin Conner on 2023-04-23.
//

import SwiftUI

struct PreviewState<T, U>: View where U: View {
    
    @State var value: T
    @ViewBuilder var content: (Binding<T>) -> U
    
    init(_ initialValue: T, @ViewBuilder content: @escaping (Binding<T>) -> U) {
        _value = State(initialValue: initialValue)
        self.content = content
    }
    
    var body: some View {
        content($value)
    }
    
}
