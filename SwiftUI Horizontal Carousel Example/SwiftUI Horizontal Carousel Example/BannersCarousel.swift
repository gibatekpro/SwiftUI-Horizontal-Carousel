//

import SwiftUI
import Combine
import Foundation
import CoreGraphics
import SwiftUI_Horizonal_Carousel

public final class BannersCarouselModel: ObservableObject, ReferenceWritableKeyPathUpdating {
    private var bannersCountSubscription: AnyCancellable?

    /// Carousel is used starting with 2 banners
    public let pagerModel = PagerModel()

    @Published public var banners: [BannerCellModel] = []

    @Published public var skeletonTheme: BannerSkeletonTheme = .light
    @Published public var cellType: BannerCellType = .slim

    /// Horizontal padding for a single cell or a placeholder
    @Published public var singleItemHorizontalPadding: CGFloat = 8

    @Published public var shouldShowPlaceholderWhenEmpty: Bool = false

    public let bannerTapSubject = PassthroughSubject<Int, Never>()

    public init(
        banners: [BannerCellModel] = [],
        skeletonTheme: BannerSkeletonTheme = .light,
        cellType: BannerCellType = .slim
    ) {
        self.banners = banners
        self.skeletonTheme = skeletonTheme
        self.cellType = cellType

        subscribeToBannersCount()
        configureCarouselUI()
    }

    private func configureCarouselUI() {
        pagerModel.settings.interitemSpacing = 8
        pagerModel.settings.itemHorizontalInsets = 16
        pagerModel.settings.alignment = .justified(16)
    }

    private func subscribeToBannersCount() {
        bannersCountSubscription = $banners.sink { [weak self] newBanners in
            self?.pagerModel.settings.isInfinitePager = newBanners.count > 2

            if self?.pagerModel.settings.isInfinitePager == false {
                self?.pagerModel.autoScroller.stop()
            }
        }
    }

    func didTapBanner(model: BannerCellModel) {
        guard let index = banners.firstIndex(of: model) else {
            return
        }

        bannerTapSubject.send(index)
    }

    /// Starts auto scroll for infinite pager if scroller settings allows it
    public func startAutoScroll() {
        guard pagerModel.settings.isInfinitePager, !banners.isEmpty else {
            return
        }
        pagerModel.autoScroller.start()
    }

    public func stopAutoScroll() {
        pagerModel.autoScroller.stop()
    }
}

public struct BannersCarousel: View {
    @ObservedObject var viewModel: BannersCarouselModel
    @ObservedObject var pagerSettings: PagerSettingsModel

    public init(
        viewModel: BannersCarouselModel
    ) {
        self.viewModel = viewModel
        pagerSettings = viewModel.pagerModel.settings
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                switch viewModel.banners.count {
                case 0:
                    if viewModel.shouldShowPlaceholderWhenEmpty {
                        placeholderView
                            .padding(.horizontal, viewModel.singleItemHorizontalPadding)
                    }

                case 1:
                    bannerCell(
                        model: viewModel.banners[0],
                        bannerSize: CGSize(
                            width: proxy.size.width - viewModel.singleItemHorizontalPadding * 2,
                            height: bannerHeight
                        )
                    )
                    .padding(.horizontal, viewModel.singleItemHorizontalPadding)

                default:
                    Pager(
                        pagerModel: viewModel.pagerModel,
                        data: viewModel.banners,
                        id: \.id
                    ) { bannerModel in
                        bannerCell(
                            model: bannerModel,
                            bannerSize: viewModel.pagerModel.settings.pageSize(
                                in: CGSize(
                                    width: proxy.size.width,
                                    height: bannerHeight
                                )
                            )
                        )
                    }
                }
            }
        }
        .frame(height: contentHeight)
    }

    private var contentHeight: CGFloat {
        guard !viewModel.shouldShowPlaceholderWhenEmpty else {
            return bannerHeight
        }

        return viewModel.banners.isEmpty ? 0 : bannerHeight
    }

    private var bannerHeight: CGFloat {
        viewModel.cellType.bannerHeight
    }

    @ViewBuilder private var placeholderView: some View {
        BannerCellPlaceholder(
            cellType: viewModel.cellType,
            skeletonTheme: viewModel.skeletonTheme
        )
    }

    private var skeletonView: some View {
        BannerCellSkeleton(
            cellType: viewModel.cellType,
            skeletonTheme: viewModel.skeletonTheme
        )
    }

    func bannerCell(model: BannerCellModel, bannerSize: CGSize) -> some View {
        Button(action: {
            viewModel.didTapBanner(model: model)
        }) {
            BannerCell(
                viewModel: model,
                size: bannerSize,
                cornerRadius: viewModel.cellType.cornerRadius,
                skeleton: { skeletonView },
                placeholder: { placeholderView }
            )
        }
    }
}

public extension BannersCarousel {
    func singleItemHorizontalPadding(_ value: CGFloat) -> Self {
        viewModel.updateIfNeeded(keyPath: \.singleItemHorizontalPadding, value: value)

        return self
    }
}
