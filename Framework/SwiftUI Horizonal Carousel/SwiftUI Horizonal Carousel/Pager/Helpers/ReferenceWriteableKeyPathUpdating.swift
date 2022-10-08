//

import Foundation

/// Update class keyPath or @State in View
/// Useful to update @Published properties only if value changes
public protocol ReferenceWritableKeyPathUpdating {
    func updateIfNeeded<T: Equatable>(keyPath: ReferenceWritableKeyPath<Self, T?>, value: T?)
    func updateIfNeeded<T: Equatable>(keyPath: ReferenceWritableKeyPath<Self, T>, value: T)
}

public extension ReferenceWritableKeyPathUpdating {
    func updateIfNeeded<T>(keyPath: ReferenceWritableKeyPath<Self, T?>, value: T?) where T: Equatable {
        if self[keyPath: keyPath] != value {
            self[keyPath: keyPath] = value
        }
    }

    func updateIfNeeded<T>(keyPath: ReferenceWritableKeyPath<Self, T>, value: T) where T: Equatable {
        if self[keyPath: keyPath] != value {
            self[keyPath: keyPath] = value
        }
    }
}
