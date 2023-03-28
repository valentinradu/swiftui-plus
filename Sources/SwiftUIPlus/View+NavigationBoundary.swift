//
//  File.swift
//
//
//  Created by Valentin Radu on 13/03/2023.
//

import Foundation
import SwiftUI

private struct NavigationContextEnvironmentKey: EnvironmentKey {
    static var defaultValue: NavigationContext = .init(path: .init(), present: { _ in }, dismiss: { _ in })
}

public extension EnvironmentValues {
    var navigationContext: NavigationContext {
        get { self[NavigationContextEnvironmentKey.self] }
        set { self[NavigationContextEnvironmentKey.self] = newValue }
    }
}

public struct NavigationBoundary<Root, Data>: View
    where Root: View,
    Data: MutableCollection,
    Data: RandomAccessCollection,
    Data: RangeReplaceableCollection,
    Data.Element: Hashable {
    private let _content: NavigationStack<Data, Root>
    @Binding private var _path: Data

    public init(path: Binding<Data>, @ViewBuilder root: () -> Root) {
        __path = path
        _content = NavigationStack(path: path, root: root)
    }

    public var body: some View {
        _content
            .environment(\.navigationContext, _navigationContext)
    }

    private var _navigationContext: NavigationContext {
        NavigationContext(path: _path.map { AnyHashable($0) },
                          present: {
                              guard let fragment = $0 as? Data.Element else {
                                  assertionFailure()
                                  return
                              }
                              _path.append(fragment)
                          },
                          dismiss: {
                              _path.removeLast($0)
                          })
    }
}

public struct NavigationContext: Equatable {
    private let _present: (AnyHashable) -> Void
    private let _dismiss: (Int) -> Void
    private let _path: [AnyHashable]

    public init(path: [AnyHashable],
                present: @escaping (AnyHashable) -> Void,
                dismiss: @escaping (Int) -> Void) {
        _path = path
        _present = present
        _dismiss = dismiss
    }

    public func present<F>(fragment: F) where F: Hashable {
        _present(fragment)
    }

    public func dismiss(_ k: Int = 1) {
        _dismiss(k)
    }

    public static func == (lhs: NavigationContext, rhs: NavigationContext) -> Bool {
        lhs._path == rhs._path
    }
}
