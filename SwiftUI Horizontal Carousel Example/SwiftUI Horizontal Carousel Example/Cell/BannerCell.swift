//

import Foundation
import SwiftUI

public struct BannerCellModel: Identifiable, Equatable {
    public let id: String

    public let imageName: String?

    public init(
        id: String = UUID().uuidString,
        imageName: String?
    ) {
        self.id = id
        self.imageName = imageName
    }
}

public struct BannerCell<PlaceholderView: View, SkeletonView: View>: View {

    @Binding private var viewModel: BannerCellModel
    private let size: CGSize
    private let cornerRadius: CGFloat

    private let skeleton: () -> SkeletonView
    private let placeholder: () -> PlaceholderView

    public init(
        viewModel: BannerCellModel,
        size: CGSize,
        cornerRadius: CGFloat,
        @ViewBuilder skeleton: @escaping () -> SkeletonView,
        @ViewBuilder placeholder: @escaping () -> PlaceholderView
    ) {
        _viewModel = .constant(viewModel)

        self.size = size
        self.cornerRadius = cornerRadius
        self.skeleton = skeleton
        self.placeholder = placeholder
    }

    public var body: some View {
        if let imageName = viewModel.imageName {
            Image(imageName)
                .resizable()
                .frame(size: size)
                .cornerRadius(cornerRadius)
        } else {
            placeholder()
        }
    }
}
