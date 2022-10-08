//

import Combine
import SwiftUI
import SwiftUI_Horizonal_Carousel

struct BannersCarouselSample: View {
    @StateObject private var bannersModel: BannersCarouselModel
    @StateObject private var autoScrollerRef: PagerAutoScroller

    @State private var banners = [
        BannerCellModel(imageName: "banner1"),
        BannerCellModel(imageName: "banner2"),
        BannerCellModel(imageName: "banner1"),
        BannerCellModel(imageName: "banner2"),
        BannerCellModel(imageName: nil)
    ]

    private var numberOfBanners: Int {
        Int(numberOfBannersForSlider)
    }

    @State var carouselId = UUID()

    private let maxNumberOfBanners = 5

    @State private var numberOfBannersForSlider: Double = 5

    /// View is not destroyed in styleguide when we leave it.
    /// Need to remove content when view is off screen so when we return back screen size is correct
    @State var isAppeared: Bool = false

    static func createBannersModel() -> BannersCarouselModel {
        let model = BannersCarouselModel()
        model.pagerModel.autoScroller.isEnabled = true
        return model
    }

    init() {
        let model = Self.createBannersModel()
        _bannersModel = StateObject(wrappedValue: model)
        _autoScrollerRef = StateObject(wrappedValue: model.pagerModel.autoScroller)
    }

    var body: some View {
        ScrollView {
            VStack.zeroSpacing {
                if isAppeared {
                    Spacer.frame(height: 100)

                    carousel
                        .padding(.vertical)
                        .id(carouselId)

                    settings
                }
            }
            .frame(maxWidth: .infinity)
        }
        .onChange(of: numberOfBanners) { count in
            bannersModel.banners = banners.prefix(count).asArray
        }
        .onAppear {
            isAppeared = true
            bannersModel.banners = banners.prefix(numberOfBanners).asArray
            bannersModel.startAutoScroll()
        }
        .onDisappear {
            bannersModel.stopAutoScroll()
            isAppeared = false
        }
        .navigationTitle("Banners Carousel")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var carousel: some View {
        VStack.zeroSpacing {
            BannersCarousel(viewModel: bannersModel)
        }
        .padding(.vertical)
    }

    private var settings: some View {
        VStack.zeroSpacing {
            numberOfBannersSetting
                .padding(.bottom)

            shouldShowPlaceholderWhenEmptySetting
                .padding(.bottom)

            skeletonThemeSetting
                .padding(.bottom)

            cellTypeSetting
                .padding(.bottom)

            HStack.zeroSpacing {
                Text("Auto Scroll работает")

                Spacer.minZero

                Text(String(autoScrollerRef.isRunning))
            }
            .padding(.bottom)

            switchSettingCell(
                value: $autoScrollerRef.isEnabled,
                title: "Авто скрол доступен",
                description: nil
            )
            .padding(.bottom)

            autoScrollControls
                .padding(.top)

        }
        .padding()
    }

    private var numberOfBannersSetting: some View {
        VStack.zeroSpacing {
            Text("Количество баннеров \(Int(numberOfBanners))")

            Slider(
                value: $numberOfBannersForSlider,
                in: 0 ... Double(maxNumberOfBanners),
                label: { EmptyView() },
                minimumValueLabel: { Text("0") },
                maximumValueLabel: { Text("\(maxNumberOfBanners)") }
            )
        }
    }

    private var skeletonThemeSetting: some View {
        Picker("Цвет скелетона", selection: $bannersModel.skeletonTheme) {
            ForEach(BannerSkeletonTheme.allCases, id: \.self) {
                Text($0.pickerDescription)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    private var cellTypeSetting: some View {
        Picker("Тип ячейки", selection: $bannersModel.cellType) {
            ForEach(BannerCellType.allCases, id: \.self) {
                Text($0.pickerDescription)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }

    private var shouldShowPlaceholderWhenEmptySetting: some View {
        VStack.zeroSpacing {
            Toggle("No Image при 0 баннерах", isOn: $bannersModel.shouldShowPlaceholderWhenEmpty)

            Text("Показать ли заглушку, если в карусели нет баннеров")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical)
    }

    private var autoScrollControls: some View {
        VStack(spacing: 8) {
            Text("Auto Scroll Actions")
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 20) {
                Button(action: { autoScrollerRef.start() }) {
                    Text("Start").padding()
                }
                .disabled(!autoScrollerRef.isEnabled)

                Button(action: { autoScrollerRef.stop() }) {
                    Text("Stop").padding()
                }
            }
        }
    }

    // MARK: Helpers

    private func switchSettingCell(value: Binding<Bool>, title: String, description: String?) -> some View {
        VStack.zeroSpacing {
            Toggle(title, isOn: value)

            if let text = description {
                Text(text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.top)
    }
}

private extension BannerSkeletonTheme {
    var pickerDescription: String {
        switch self {
        case .light:
            return "Light"

        case .dark:
            return "Dark"
        }
    }
}

private extension BannerCellType {
    var pickerDescription: String {
        return "\(bannerHeight)"
    }
}
