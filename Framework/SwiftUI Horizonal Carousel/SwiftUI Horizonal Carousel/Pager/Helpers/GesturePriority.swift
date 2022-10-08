//

import SwiftUI

public enum GesturePriority {
    /// Refers to `highPriorityGesture` modifier
    case high

    /// Refers to `simultaneousGesture` modifier
    case simultaneous

    /// Refers to `gesture` modifier
    case normal

    /// Default value, a.k.a, `normal`
    static let `default`: GesturePriority = .normal
}

extension View {
    func gesture<T>(_ gesture: T, priority: GesturePriority) -> some View where T: Gesture {
        Group {
            if priority == .high {
                highPriorityGesture(gesture)
            } else if priority == .simultaneous {
                simultaneousGesture(gesture)
            } else {
                self.gesture(gesture)
            }
        }
    }
}
