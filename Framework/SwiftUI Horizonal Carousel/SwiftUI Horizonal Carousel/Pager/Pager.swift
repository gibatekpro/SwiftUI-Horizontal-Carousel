//

import Combine
import Foundation
import SwiftUI

public final class PagerModel: ObservableObject {
    public var settings = PagerSettingsModel()
    public var autoScroller = PagerAutoScroller()

    /// Selected index of the collection
    @Published public internal(set) var selectedIndex: Int = 0

    /// Total number of pages
    @Published public private(set) var pagesCount = Int.max {
        didSet {
            // reset in case there's a deletion
            updateSelectedIndex(selectedIndex)
        }
    }

    var selectedIndexWithAnimationPublisher = PassthroughSubject<(Int, Animation?), Never>()

    public init() {
        autoScroller.onScrollBlock = { [weak self] in
            guard let self = self,
                  self.pagesCount != 0 else {
                return
            }

            let animation = self.settings.autoScrollAnimation ?? self.settings.defaultPagingAnimation
            self.update(.next, withAnimation: animation)
        }
    }

    public func updateSelectedIndex(_ index: Int, withAnimation animation: Animation? = nil) {
        let newIndex = min(max(index, 0), pagesCount - 1)

        guard selectedIndex != newIndex else {
            return
        }

        selectedIndex = newIndex
        selectedIndexWithAnimationPublisher.send((newIndex, animation))
    }

    /// Will update `Page` accordingly and trigger `objectWillChange`
    ///
    /// - Parameter update: update to perform
    ///
    /// If you do not wish to trigger an update because you want to take control of the update, set `index` direclty
    public func update(_ update: Update, withAnimation animation: Animation? = nil) {
        var newIndex = selectedIndex

        switch update {
        case .next:
            newIndex += 1

            if settings.isInfinitePager {
                if newIndex >= pagesCount, settings.isInfinitePager {
                    newIndex = 0
                }
            }
        case .previous:
            newIndex -= 1

            if settings.isInfinitePager {
                if newIndex < 0, settings.isInfinitePager {
                    newIndex = pagesCount - 1
                }
            }
        case .moveToFirst:
            newIndex = 0

        case .moveToLast:
            newIndex = pagesCount - 1

        case let .move(increment):
            newIndex += increment

        case let .new(index):
            newIndex = index
        }

        if pagesCount != 0 {
            newIndex = max(newIndex % pagesCount, 0)
        } else {
            newIndex = 0
        }

        updateSelectedIndex(newIndex, withAnimation: animation)
    }

    func updatePagesCount(_ count: Int) {
        if pagesCount != count {
            pagesCount = count
        }
    }
}

public extension PagerModel {
    /// An update to perform on a `Page` index
    enum Update {
        /// Will increase the `index` by `1`
        case next

        /// Will decrease the `index` by `1`
        case previous

        /// Will move to the first page
        case moveToFirst

        /// Will increment or decrement the `index` by the passed argument
        case move(increment: Int)

        /// Will move to the last page
        case moveToLast

        /// Will set the `index` to the new value
        case new(index: Int)
    }
}

public struct Pager<PageView: View, Element: Equatable, ID: Hashable>: View {
    @ObservedObject var pagerModel: PagerModel
    @ObservedObject var settings: PagerSettingsModel

    /// `ViewBuilder` block to create each page
    let content: (Element) -> PageView

    /// Array of items that will populate each page
    var data: [Element]

    /// `KeyPath` to data id property
    let id: KeyPath<Element, ID>

    /// Apply any modification for an item after item size is applied. Shadow, for example.
    let itemPostProcessingBlock: ((AnyView, Element) -> AnyView)?

    public init<Data: RandomAccessCollection>(
        pagerModel: PagerModel,
        data: Data,
        id: KeyPath<Element, ID>,
        @ViewBuilder content: @escaping (Element) -> PageView,
        itemPostProcessingBlock: ((AnyView, Element) -> AnyView)? = nil
    ) where Data.Index == Int, Data.Element == Element {
        self.pagerModel = pagerModel
        settings = pagerModel.settings
        self.id = id
        self.content = content
        self.data = Array(data)
        self.itemPostProcessingBlock = itemPostProcessingBlock
        pagerModel.updatePagesCount(data.count)
    }

    public var body: some View {
        GeometryReader { proxy in
            if !proxy.size.height.isZero {
                PagerContent(
                    size: proxy.size,
                    pagerModel: pagerModel,
                    data: data,
                    id: id,
                    content: content,
                    itemPostProcessingBlock: itemPostProcessingBlock
                )
            }
        }
        .clipped()
    }
}

public extension Pager where ID == Element.ID, Element: Identifiable {
    /// Initializes a new Pager.
    ///
    /// - Parameter page: Current page index
    /// - Parameter data: Collection of items to populate the content
    /// - Parameter content: Factory method to build new pages
    init<Data: RandomAccessCollection>(
        pagerModel: PagerModel,
        data: Data,
        @ViewBuilder content: @escaping (Element) -> PageView
    ) where Data.Index == Int, Data.Element == Element {
        self.init(
            pagerModel: pagerModel,
            data: Array(data),
            id: \Element.id,
            content: content
        )
    }
}

// MARK: - Settings setup

public extension Pager {
    /// Changes the a the  alignment of the pages relative to their container
    ///
    /// - Parameter value: alignment of the pages inside the scroll
    func alignment(_ value: PositionAlignment) -> Self {
        settings.updateIfNeeded(keyPath: \.alignment, value: value)
        return self
    }

    func itemHeight(_ value: CGFloat) -> Self {
        settings.updateIfNeeded(keyPath: \.preferredItemHeight, value: value)
        return self
    }
}
