//

import SwiftUI
import SwiftUI_Horizonal_Carousel

public struct BannerCellPlaceholder: View {
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
            case (_, .dark):
                BannerCellPlaceholderDark(cellType: cellType)

            case (_, .light):
                BannerCellPlaceholderLight(cellType: cellType)
            }
        }
    }
}

public struct BannerCellPlaceholderLight: View {
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

            VStack.zeroSpacing {
                Spacer.minZero

                HStack.zeroSpacing {
                    Spacer.minZero

                    
                    Image("no-image-icon-23494")
                        .resizable()
                        .scaledToFit()
                        .frame(height: layout.imageHeight)
                }
            }
        }
        .cornerRadius(cellType.cornerRadius)
        .frame(height: cellType.bannerHeight)
    }
}

public struct BannerCellPlaceholderDark: View {
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
                itemGradient
                    .frame(width: layout.topItemWidth, height: layout.itemHeight)
                    .cornerRadius(layout.itemCornerRadius)

                Spacer.frame(height: layout.interitemSpacing)

                itemGradient
                    .frame(width: layout.bottomItemWidth, height: layout.itemHeight)
                    .cornerRadius(layout.itemCornerRadius)

                Spacer.minZero
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.horizontal, .top], layout.itemPadding)

            VStack.zeroSpacing {
                Spacer.minZero

                HStack.zeroSpacing {
                    Spacer.minZero

                    Image("no-image-icon-23494")
                        .resizable()
                        .scaledToFit()
                        .frame(height: layout.imageHeight)
                }
            }
        }
        .cornerRadius(cellType.cornerRadius)
    }

    private var itemGradient: some View {
        let gradient = Gradient(
            colors: [
                Color.gray,
                Color.gray.opacity(0.7)
            ]
        )

        return LinearGradient(
            gradient: gradient,
            startPoint: .init(x: 0.25, y: 0.5),
            endPoint: .init(x: 0.75, y: 0.5)
        )
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
