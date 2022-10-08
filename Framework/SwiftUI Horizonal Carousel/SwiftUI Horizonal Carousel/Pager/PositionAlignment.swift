//

import CoreGraphics

/// `Alignment` determines the focused page alignment inside `Pager`
public enum PositionAlignment: Equatable {
    /// Sets the alignment to be centered
    case center

    /// Sets the alignment to be centered, but first and last pages snapping to the sides with the specified insets:
    /// - Left, Right if horizontal
    case justified(CGFloat)

    /// Sets the alignment to be at the start of the container with the specified insets:
    ///
    /// - Left, if horizontal
    case start(CGFloat)

    /// Sets the alignment to be at the start of the container with the specified insets:
    ///
    /// - Right, if horizontal
    case end(CGFloat)

    /// Returns the alignment insets
    var insets: CGFloat {
        switch self {
        case .center:
            return 0
        case let .end(insets), let .start(insets), let .justified(insets):
            return insets
        }
    }

    /// Helper to compare `Alignment` ignoring associated values
    func equalsIgnoreValues(_ alignment: PositionAlignment) -> Bool {
        switch (self, alignment) {
        case (.center, .center), (.justified, .justified), (.start, .start), (.end, .end):
            return true
        default:
            return false
        }
    }

    /// Sets the alignment at the start, with 0 px of margin
    public static var start: PositionAlignment { .start(0) }

    /// Sets the alignment at the end, with 0 px of margin
    public static var end: PositionAlignment { .end(0) }

    /// Sets the alignment justified, with 0 px of margin
    public static var justified: PositionAlignment { .justified(0) }
}
