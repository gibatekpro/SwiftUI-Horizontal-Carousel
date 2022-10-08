//

import Foundation
import UIKit

/// Defines how sensitive the pagination is to determine whether or not to move to the next the page.
public enum PaginationSensitivity: Equatable {
    /// The shift relative to container size needs to be greater than or equal to 75%
    case low

    /// The shift relative to container size needs to be greater than or equal to 50%
    case medium

    /// The shift relative to container size needs to be greater than or equal to 25%
    case high

    /// The shift relative to container size needs to be greater than or equal to the specified value
    case custom(CGFloat)

    /// The shift relative to container size needs to be greater than or equal to 50%
    public static var `default`: Self = .medium

    var value: CGFloat {
        switch self {
        case .low:
            return 0.75
        case .high:
            return 0.25
        case .medium:
            return 0.5
        case let .custom(value):
            return value
        }
    }
}
