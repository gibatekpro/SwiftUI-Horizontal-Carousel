//

import CoreGraphics
import Foundation
import SwiftUI

public final class PagerSettingsModel: ObservableObject, ReferenceWritableKeyPathUpdating {
    /// Whether the `Pager` loops endlessly
    @Published public var isInfinitePager: Bool = false

    /// How many pages must be added to the both sides of data array to appear infinite
    @Published public var itemsLoopingPaddingCount = 2

    @Published public var preferredItemHeight: CGFloat?

    @Published public var preferredItemWidth: CGFloat?

    /// Define this value if pager is to be inside ScrollView
    @Published public var containerHeight: CGFloat?

    /// Horizontal space from item to container edges
    @Published public var itemHorizontalInsets: CGFloat?

    /// Vertical space from item to container edges
    @Published public var itemVerticalInsets: CGFloat?

    /// Will apply this ratio to each page item. The aspect ratio follows the formula _width / height_
    /// Second value to check in page size calculation
    @Published public var itemAspectRatio: CGFloat?

    /// Space between pages
    @Published public var interitemSpacing: CGFloat = 0

    @Published public var gestureMinimumDistance: CGFloat = 10.0

    @Published public var gestureCoordinateSpace: CoordinateSpace = .local

    /// Animation used for dragging
    @Published public var draggingAnimation: Animation? = .default

    @Published public var defaultPagingAnimation: Animation? = Animation.easeOut(duration: 0.35)

    @Published public var autoScrollAnimation: Animation?

    /// `true` if  `Pager` can be dragged
    @Published public var allowsDragging: Bool = true

    /// Priority selected to add `swipeGesture`
    @Published public var gesturePriority: GesturePriority = .high

    /// Создает тянучесть ячейки при свайпе
    /// Если ячейка маленькая, то можно увеличить этот множитель, чтобы скрол был более отзывчивый
    ///
    /// offsetIncrement = pageDistance * multiplier / size
    ///
    /// Финальное значение normalizedRatio никогда не будет больше 1
    ///
    @Published public var pageDragNormalizationMultiplier: CGFloat = 1.0

    /// Нужно ли создавать тянучесть ячейки или она должна следовать за пальцем 1 в 1
    ///
    /// true по-умолчанию
    @Published public var isDragOffsetNormalized: Bool = true

    /// Whether `Pager` should bounce or not
    @Published public var bounces: Bool = true

    /// Shrink ratio that affects the items that aren't focused
    @Published public var interactiveScale: CGFloat = 1

    /// Max relative item size that `Pager` will scroll before determining whether to move to the next page
    @Published public var pageRatio: CGFloat = 1

    /// Drag velocity that will trigger new page calculation even if user didn't swipe far enough
    @Published public var dragVelocityThreshold: Double = 500

    /// Sensitivity used to determine whether or not to swipe the page
    @Published public var sensitivity: PaginationSensitivity = .default

    /// Used to modify `Pager` offset outside this view
    @Published var pageOffset: Double = 0

    /// The elements alignment relative to the container
    @Published public var alignment: PositionAlignment = .center

    init() {}

    /// Size increment to be applied to a unfocs item when it comes to focus
    var scaleIncrement: CGFloat { 1 - interactiveScale }

    // MARK: Calculations

    public func pagerHeight() -> CGFloat? {
        if let height = containerHeight {
            return height
        }

        var height: CGFloat?

        if let preferredItemHeight = preferredItemHeight {
            height = preferredItemHeight
        }

        if let heightValue = height,
           let itemVerticalInsets = itemVerticalInsets {
            height = heightValue + itemVerticalInsets * 2
        }

        return height
    }

    /// Size of each item.
    public func pageSize(in availableSize: CGSize) -> CGSize {
        guard availableSize != .zero else {
            return .zero
        }

        let containerHeight = pagerHeight() ?? availableSize.height

        var itemHeight: CGFloat = .zero
        var itemWidth: CGFloat = .zero

        if let preferredItemHeight = preferredItemHeight {
            itemHeight = min(preferredItemHeight, containerHeight)
        } else {
            itemHeight = containerHeight - 2 * (itemVerticalInsets ?? 0)
        }

        if let preferredItemWidth = preferredItemWidth {
            itemWidth = min(preferredItemWidth, availableSize.width)
        } else {
            itemWidth = availableSize.width - 2 * (itemHorizontalInsets ?? 0)
        }

        let size = CGSize(
            width: itemWidth,
            height: itemHeight
        )

        guard let itemAspectRatio = itemAspectRatio else {
            return size
        }

        if itemAspectRatio > 1 {
            itemHeight /= itemAspectRatio
        }

        return CGSize(width: itemWidth * itemAspectRatio, height: itemHeight)
    }
}
