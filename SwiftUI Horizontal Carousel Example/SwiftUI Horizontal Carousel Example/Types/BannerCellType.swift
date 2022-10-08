//

import Foundation
import CoreGraphics

public enum BannerCellType: CaseIterable {
    case slim
    case regular
    case large

    public var bannerHeight: CGFloat {
        switch self {
        case .slim:
            return 72

        case .regular:
            return 120

        case .large:
            return 168
        }
    }

    public var cornerRadius: CGFloat {
        switch self {
        case .slim, .large:
            return 12

        case .regular:
            return 16
        }
    }

    var skeletonLayout: BannerCellSkeletonLayout {
        switch self {
        case .slim:
            return .slim

        case .regular:
            return .regular

        case .large:
            return .large
        }
    }
}

struct BannerCellSkeletonLayout {
    let topItemWidth: CGFloat
    let bottomItemWidth: CGFloat
    let itemHeight: CGFloat
    let imageHeight: CGFloat

    /// leading and top paddings
    let itemPadding: CGFloat
    let itemCornerRadius: CGFloat
    let interitemSpacing: CGFloat

    static var slim: Self {
        .init(
            topItemWidth: 151,
            bottomItemWidth: 194,
            itemHeight: 16,
            imageHeight: BannerCellType.slim.bannerHeight,
            itemPadding: 12,
            itemCornerRadius: 4,
            interitemSpacing: 10
        )
    }

    static var regular: Self {
        .init(
            topItemWidth: 94,
            bottomItemWidth: 134,
            itemHeight: 16,
            imageHeight: BannerCellType.regular.bannerHeight,
            itemPadding: 16,
            itemCornerRadius: 4,
            interitemSpacing: 10
        )
    }

    static var large: Self {
        .init(
            topItemWidth: 94,
            bottomItemWidth: 134,
            itemHeight: 16,
            imageHeight: 120,
            itemPadding: 16,
            itemCornerRadius: 4,
            interitemSpacing: 10
        )
    }
}
