//

import Foundation
import SwiftUI

public extension Int {
    var asDouble: Double {
        Double(self)
    }
}

public extension Collection {
    var asArray: [Element] {
        Array(self)
    }
}

public extension Spacer {
    static var minZero: Spacer {
        Spacer(minLength: .zero)
    }
    
    static func frame(width: CGFloat) -> some View {
        Spacer.minZero.frame(width: width)
    }

    static func frame(height: CGFloat) -> some View {
        Spacer.minZero.frame(height: height)
    }
}

public extension VStack {
    static func zeroSpacing(@ViewBuilder content: () -> Content) -> VStack {
        VStack(spacing: .zero, content: content)
    }
}


public extension HStack {
    static func zeroSpacing(@ViewBuilder content: () -> Content) -> HStack {
        HStack(spacing: .zero, content: content)
    }
}

public extension CGPoint {
    /// Trigonometry angle calculated from degree
    var angle: Angle? {
        guard x != 0 || y != 0 else {
            return nil
        }

        guard x != 0 else {
            return y > 0 ? Angle(degrees: 90) : Angle(degrees: 270)
        }

        guard y != 0 else {
            return x > 0 ? Angle(degrees: 0) : Angle(degrees: 180)
        }

        var angle = atan(abs(y) / abs(x)) * 180 / .pi

        switch (x, y) {
        case let (x, y) where x < 0 && y < 0:
            angle = 180 + angle
        case let (x, y) where x < 0 && y > 0:
            angle = 180 - angle
        case let (x, y) where x > 0 && y < 0:
            angle = 360 - angle
        default:
            break
        }

        return .init(degrees: Double(angle))
    }
    
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

extension Angle {
    func isAlongXAxis(margin: Int = 30) -> Bool {
        assert((0 ... 360).contains(margin))

        let degrees = ((Int(self.degrees.rounded()) % 360) + 360) % 360

        // looking at trigonometry circle
        let leftCircleHalf = (180 - margin) ... (180 + margin)
        let fourthQuater = (360 - margin) ... 360
        let firstQuater = 0 ... margin

        return fourthQuater.contains(degrees)
            || firstQuater.contains(degrees)
            || leftCircleHalf.contains(degrees)
    }
}
