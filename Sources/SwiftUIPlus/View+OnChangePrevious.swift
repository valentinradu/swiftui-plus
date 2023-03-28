//
//  File.swift
//
//
//  Created by Valentin Radu on 26/03/2023.
//

import SwiftUI

private struct OnChangePreviousModifier<V>: ViewModifier where V: Equatable {
    let value: V
    let perform: (V, V) -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: value) { [value] newValue in
                perform(newValue, value)
            }
    }
}

public extension View {
    func onChange<V>(of value: V, perform: @escaping (V, V) -> Void) -> some View where V: Equatable {
        modifier(OnChangePreviousModifier(value: value, perform: perform))
    }
}
