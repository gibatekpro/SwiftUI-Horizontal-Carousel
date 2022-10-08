//

import CoreGraphics
import Foundation
import SwiftUI

/**
 Implements Builder pattern.
 */
public protocol Buildable {
    func map(_ closure: (inout Self) -> Void) -> Self
}

public extension Buildable {
    func map(_ closure: (inout Self) -> Void) -> Self {
        var copy = self
        closure(&copy)
        return copy
    }
}

final class PagerContentModel: ObservableObject {
    @Published var internalIndex: Int = -1

    @Published var isDragGestureAvailable = true

    /// Raw dragging gesture value
    var lastDraggingValue: DragGesture.Value?

    /// `swipeGesture` velocity on the X-Axis
    /// Need to track it to calculate page update if user scrolled fast but not far enough.
    var draggingVelocity: Double = 0

    /// internal index value to set when animation is finished
    var pendingInternalIndex: Int?

    func applyPendingInternalIndex() {
        guard let newIndex = pendingInternalIndex else {
            return
        }

        internalIndex = newIndex
    }
}

struct PagerContent<PageView: View, Element: Equatable, ID: Hashable>: View, Buildable {
    @ObservedObject var pagerModel: PagerModel
    @ObservedObject var settings: PagerSettingsModel

    /// `ViewBuilder` block to create each page
    let content: (Element) -> PageView

    /// Apply any modification for an item after item size is applied. Shadow, for example.
    let itemPostProcessingBlock: ((AnyView, Element) -> AnyView)?

    @StateObject var innerModel = PagerContentModel()

    @State var dragOffset: CGFloat = .zero

    let id: KeyPath<Element, ID>

    let originalData: [Element]

    /// Container size
    let size: CGSize

    var originalDataCount: Int {
        originalData.count
    }

    var internalIndex: Int {
        innerModel.internalIndex
    }

    var numberOfPages: Int {
        displayedData.count
    }

    init(
        size: CGSize,
        pagerModel: PagerModel,
        data: [Element],
        id: KeyPath<Element, ID>,
        @ViewBuilder content: @escaping (Element) -> PageView,
        itemPostProcessingBlock: ((AnyView, Element) -> AnyView)? = nil
    ) {
        self.size = size
        self.pagerModel = pagerModel
        self.id = id
        self.content = content
        self.itemPostProcessingBlock = itemPostProcessingBlock

        settings = pagerModel.settings
        originalData = data
    }

    var body: some View {
        HStack(spacing: interactiveItemSpacing) {
            Spacer.minZero

            ForEach(displayedData.indexed(), id: \.element.id) { index, item in
                VStack.zeroSpacing {
                    Spacer.minZero

                    content(item.element)
                        .frame(size: pageSize)
                        .onTapGesture {
                            onSelect(index, animation: .default)
                        }

                    Spacer.minZero
                }
                .modifier(ifLet: itemPostProcessingBlock) { view, block in
                    block(AnyView(view), item.element)
                }
            }

            Spacer.minZero
        }
        .offset(x: xOffset)
        .frame(width: size.width)
        .clipped()
        .gesture(
            innerModel.isDragGestureAvailable && settings.allowsDragging ? dragGesture : nil,
            priority: settings.gesturePriority
        )
        .onReceive(pagerModel.$selectedIndex) { index in
            // setup initial value
            guard innerModel.internalIndex < 0 else {
                return
            }

            handleSelectedIndexUpdate(
                index: index,
                isInfinitePager: settings.isInfinitePager,
                animation: nil
            )
        }
        .onReceive(pagerModel.selectedIndexWithAnimationPublisher) { index, animation in
            handleSelectedIndexUpdate(
                index: index,
                isInfinitePager: settings.isInfinitePager,
                animation: animation
            )
        }
        .onReceive(settings.$isInfinitePager) { newValue in
            handleSelectedIndexUpdate(
                index: pagerModel.selectedIndex,
                isInfinitePager: newValue,
                animation: nil
            )
        }
        .onReceive(innerModel.$internalIndex) { newValue in
            guard newValue >= 0 else {
                return
            }

            updateRealIndex(internalIndex: newValue)
        }
        .onAnimationCompleted(for: dragOffset) {
            if let index = innerModel.pendingInternalIndex {
                innerModel.pendingInternalIndex = nil
                onSelect(index, animation: nil)
            }
        }
        .onReceive(innerModel.$isDragGestureAvailable) { value in
            if !value {
                innerModel.isDragGestureAvailable = true
            }
        }
    }

    var displayedData: [PageWrapper<Element, ID>] {
        if settings.isInfinitePager {
            let indexOffset = settings.itemsLoopingPaddingCount

            let prefixPadding = originalData.prefix(indexOffset)
                .prefix(indexOffset)
                .map { PageWrapper(batchId: 0, keyPath: id, element: $0) }
                .asArray

            let suffixPadding = originalData.suffix(indexOffset)
                .prefix(indexOffset)
                .map { PageWrapper(batchId: 2, keyPath: id, element: $0) }
                .asArray

            var newData = originalData
                .map { PageWrapper(batchId: 1, keyPath: id, element: $0) }
                .asArray

            newData.insert(contentsOf: suffixPadding, at: 0)
            newData.append(contentsOf: prefixPadding)

            return newData
        } else {
            return originalData.map { PageWrapper(batchId: 0, keyPath: id, element: $0) }
        }
    }

    /// Handle real index update, convet to internalIndex
    func handleSelectedIndexUpdate(index: Int, isInfinitePager: Bool, animation: Animation?) {
        let newInternalIndex = calculateInternalIndex(fromReal: index, isInfinitePager: isInfinitePager)

        if newInternalIndex != internalIndex || internalIndex < 0 {
            onSelect(newInternalIndex, animation: animation)
        }
    }

    func updateRealIndex(internalIndex: Int) {
        let newRealIndex = realIndex(fromInternal: internalIndex)

        if pagerModel.selectedIndex != newRealIndex {
            pagerModel.selectedIndex = newRealIndex
        }
    }

    var pageSize: CGSize {
        settings.pageSize(in: size)
    }

    /// Total distance between items
    var pageDistance: CGFloat {
        guard size != .zero else {
            return .zero
        }

        return pageSize.width + interactiveItemSpacing
    }

    /// Total space between items. The spacing will be larger when `Pager` is interactive
    var interactiveItemSpacing: CGFloat {
        settings.interitemSpacing - (pageSize.width * settings.scaleIncrement) / 2.0
    }

    var xOffset: CGFloat {
        calculateCurrentPageOffset(page: internalIndex)
    }

    func calculateCurrentPageOffset(page: Int) -> CGFloat {
        let xIncrement = pageDistance / 2.0
        let halfPages = numberOfPages.asDouble / 2.0
        let offset = (halfPages - page.asDouble) * pageDistance - xIncrement + dragOffset + alignmentOffset
        let result = max(offsetUpperbound, min(offsetLowerbound, offset))

        return result
    }

    var offsetUpperbound: CGFloat {
        guard internalIndex == numberOfPages - 1, !settings.isInfinitePager else {
            return -CGFloat(numberOfPages) * size.width
        }

        let halfPages = -(numberOfPages.asDouble / 2.0)
        let bounceOffset = settings.bounces ? pageDistance / 4.0 : pageDistance / 2.0

        let value = halfPages * pageDistance + bounceOffset + alignmentOffset

        return value
    }

    /// Minimum offset allowed. This allows a bounce offset
    var offsetLowerbound: CGFloat {
        guard internalIndex == 0, !settings.isInfinitePager else {
            return CGFloat(numberOfPages) * size.width
        }

        let bounceOffset = settings.bounces ? -pageDistance / 4.0 : -pageDistance / 2.0

        let halfPages = numberOfPages.asDouble / 2.0

        let value = halfPages * pageDistance + bounceOffset + alignmentOffset

        return value
    }

    var alignmentOffset: CGFloat {
        let offset: CGFloat

        switch (settings.alignment, internalIndex) {
        case let (.end(insets), _), (.justified(let insets), numberOfPages - 1):
            offset = (size.width - pageSize.width) / 2.0 - insets
        case let (.start(insets), _), let (.justified(insets), 0):
            offset = -(size.width - pageSize.width) / 2.0 + insets
        case (.center, _), (.justified, _):
            offset = 0
        }

        return offset
    }

    func onSelect(_ index: Int, animation: Animation?) {
        if !settings.isInfinitePager {
            withAnimation(animation) {
                innerModel.internalIndex = min(max(index, 0), displayedData.count - 1)
            }
            return
        }

        let jump = abs(innerModel.internalIndex - index)

        let indexOffset = min(settings.itemsLoopingPaddingCount, originalDataCount)

        if index >= displayedData.count - indexOffset {
            // suffix area
            let newValue = index - originalDataCount - jump

            innerModel.internalIndex = newValue

            withAnimation(animation) {
                innerModel.internalIndex += jump
            }
        } else if index < indexOffset {
            // prefix area
            let newValue = indexOffset - 1 + originalDataCount + jump
            innerModel.internalIndex = newValue

            withAnimation(animation) {
                innerModel.internalIndex -= jump
            }
        } else {
            withAnimation(animation) {
                innerModel.internalIndex = index
            }
        }
    }

    // MARK: Drag gesture

    var dragGesture: some Gesture {
        DragGesture(
            minimumDistance: settings.gestureMinimumDistance,
            coordinateSpace: settings.gestureCoordinateSpace
        )
        .onChanged { value in
            withAnimation(settings.draggingAnimation) {
                onDragChanged(with: value)
            }
        }
        .onEnded { value in
            onDragEnded(with: value)
        }
    }

    func onDragChanged(with value: DragGesture.Value) {
        pagerModel.autoScroller.disableManually()

        let currentLocation = value.location
        let lastLocation = innerModel.lastDraggingValue?.location ?? currentLocation
        let swipeAngle = (currentLocation - lastLocation).angle ?? .zero

        // 1. check gesture direction
        // Ignore swipes that aren't on the X-Axis
        guard swipeAngle.isAlongXAxis() else {
            innerModel.lastDraggingValue = value
            return
        }

        let currentTranslation = value.translation

        // If swipe hasn't started yet, ignore swipes if they didn't start on the X-Axis
        let isTranslationInXAxis = abs(currentTranslation.width) > abs(currentTranslation.height)

        guard dragOffset != 0 || isTranslationInXAxis else {
            if dragOffset == 0 {
                innerModel.isDragGestureAvailable = false
            }

            return
        }

        // 2. Normalize swipe to page 1 page
        let side = size.width
        var normalizedRatio: Double = 1

        if settings.isDragOffsetNormalized {
            normalizedRatio = pageDistance * abs(settings.pageDragNormalizationMultiplier) / side
            normalizedRatio = min(normalizedRatio, 1.0)
        }

        let offsetIncrement = (currentLocation.x - lastLocation.x) * normalizedRatio

        guard isPageSwipeAllowed(offsetIncrement: offsetIncrement) else {
            return
        }

        let timeIncrement = value.time.timeIntervalSince(innerModel.lastDraggingValue?.time ?? value.time)
        if timeIncrement != 0 {
            innerModel.draggingVelocity = Double(offsetIncrement) / timeIncrement
        }

        var newOffset = dragOffset + offsetIncrement

        // swipe only one page
        newOffset = max(newOffset, settings.pageRatio * -pageDistance)

        innerModel.lastDraggingValue = value
        dragOffset = newOffset
    }

    /// Protect infinite loop edge page from being swiped while previous drag animation is still ongoing.
    /// Without it user can quickly swipe to the edge pages and there will be empty spaces.
    func isPageSwipeAllowed(offsetIncrement: CGFloat) -> Bool {
        guard settings.isInfinitePager else {
            return true
        }

        if internalIndex <= 1, offsetIncrement > 0 {
            return false
        }

        if internalIndex >= numberOfPages - 2, offsetIncrement < 0 {
            return false
        }

        return true
    }

    func onDragEnded(with value: DragGesture.Value) {
        let dragResult = dragResult
        let resultPageIndex = dragResult.page

        if settings.isInfinitePager,
           resultPageIndex < settings.itemsLoopingPaddingCount || resultPageIndex >= originalDataCount {
            innerModel.pendingInternalIndex = resultPageIndex

            withAnimation(settings.defaultPagingAnimation) {
                innerModel.internalIndex = resultPageIndex
                dragOffset = .zero
            }
        } else {
            withAnimation(settings.defaultPagingAnimation) {
                dragOffset = .zero
                onSelect(resultPageIndex, animation: settings.defaultPagingAnimation)
            }
        }

        innerModel.draggingVelocity = .zero
        innerModel.lastDraggingValue = nil
    }

    var dragResult: (page: Int, increment: Int) {
        let currentPage = calculateResultPageIndex(sensitivity: settings.sensitivity.value)
        let velocity = -innerModel.draggingVelocity

        var newPage = currentPage

        if currentPage == internalIndex, abs(velocity) > settings.dragVelocityThreshold {
            if settings.isInfinitePager {
                newPage = (newPage + Int(velocity / abs(velocity)) + self.numberOfPages) % self.numberOfPages
            } else {
                newPage += Int(velocity / abs(velocity))
            }
        }

        newPage = max(0, min(self.numberOfPages - 1, newPage))

        return (newPage, newPage != internalIndex ? 1 : 0)
    }

    /// Calculate index to stop at drag end
    func calculateResultPageIndex(sensitivity: CGFloat) -> Int {
        guard dragOffset != 0 else {
            return innerModel.internalIndex
        }

        let dOffset = dragOffset / pageDistance
        let remaining = dOffset - dOffset.rounded(.towardZero)
        let dPage = Int(dOffset.rounded(.towardZero))
            + (abs(remaining) < sensitivity ? 0 : Int(remaining.rounded(.awayFromZero)))

        var newPage = innerModel.internalIndex - dPage

        guard !displayedData.isEmpty else {
            return 0
        }

        if !settings.isInfinitePager {
            newPage = min(max(newPage, 0), displayedData.count - 1)
        }

        let value = max((newPage + displayedData.count) % displayedData.count, 0)

        return value
    }
}
