//

import Foundation
import SwiftUI

public struct BannerCellSkeleton: View {
    private var skeletonTheme: BannerSkeletonTheme
    private var cellType: BannerCellType

    public init(
        cellType: BannerCellType,
        skeletonTheme: BannerSkeletonTheme
    ) {
        self.skeletonTheme = skeletonTheme
        self.cellType = cellType
    }

    public var body: some View {
        VStack.zeroSpacing {
            switch (cellType, skeletonTheme) {
            case (_, .light):
                BannerCellSkeletonLight(cellType: cellType)

            case (_, .dark):
                BannerCellSkeletonDark(cellType: cellType)
            }
        }
    }
}

public struct BannerCellSkeletonLight: View {
    private let cellType: BannerCellType
    private let layout: BannerCellSkeletonLayout

    public init(cellType: BannerCellType) {
        self.cellType = cellType
        layout = cellType.skeletonLayout
    }

    public var body: some View {
        ZStack {
            Color.gray

            VStack(alignment: .leading, spacing: 0) {
                Rectangle()
                    .frame(width: layout.topItemWidth, height: layout.itemHeight)
                    .cornerRadius(layout.itemCornerRadius)

                Spacer.frame(height: layout.interitemSpacing)

                Rectangle()
                    .frame(width: layout.bottomItemWidth, height: layout.itemHeight)
                    .cornerRadius(layout.itemCornerRadius)

                Spacer.minZero
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .top], layout.itemPadding)
        }
        .cornerRadius(cellType.cornerRadius)
        .frame(height: cellType.bannerHeight)
    }
}

public struct BannerCellSkeletonDark: View {
    private let cellType: BannerCellType
    private let layout: BannerCellSkeletonLayout

    public init(cellType: BannerCellType) {
        self.cellType = cellType
        layout = cellType.skeletonLayout
    }

    public var body: some View {
        ZStack {
            backgroundGradient

            VStack(alignment: .leading, spacing: 0) {
                skeletonItem
                    .frame(width: layout.topItemWidth, height: layout.itemHeight)

                Spacer.frame(height: layout.interitemSpacing)

                skeletonItem
                    .frame(width: layout.bottomItemWidth, height: layout.itemHeight)

                Spacer.minZero
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .top], layout.interitemSpacing)
        }
        .cornerRadius(cellType.cornerRadius)
        .frame(height: cellType.bannerHeight)
    }

    private var skeletonItem: some View {
        Rectangle()
            .background(Color.clear)
            .cornerRadius(layout.itemCornerRadius)
            
    }

    private var backgroundGradient: some View {
        let gradient = Gradient(
            colors: [
                Color.gray,
                Color.gray.opacity(0.7)
            ]
        )

        return LinearGradient(
            gradient: gradient,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
