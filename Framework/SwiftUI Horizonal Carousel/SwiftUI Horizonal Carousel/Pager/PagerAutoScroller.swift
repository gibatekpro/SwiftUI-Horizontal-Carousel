//

import Combine
import Foundation

public final class PagerAutoScroller: ObservableObject {
    private var availabilitySubscription: AnyCancellable?

    /// In how many seconds perform next scroll
    @Published public var scrollInterval: Double = 2.0

    /// Is auto scroll ongoing
    @Published public private(set) var isRunning = false

    @Published public var isEnabled = false

    /// If auto scroll should be disabled on the next stop() call
    @Published public var shouldDisableAfterStop = false

    /// Was stopped by user earlier
    public var wasStoppedByUser: Bool = false

    /// perform scrolling
    var onScrollBlock: (() -> Void)?

    private var timerSubscription: AnyCancellable?

    init() {
        subscribeToAvilability()
    }

    private func subscribeToAvilability() {
        availabilitySubscription = $isEnabled
            .sink { [weak self] value in
                if !value {
                    self?.stop()
                }
            }
    }

    public func start() {
        guard isEnabled, !isRunning else {
            return
        }

        isRunning = true

        timerSubscription = Timer.publish(every: scrollInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.onScrollBlock?()
            }
    }

    public func stop() {
        guard isRunning else {
            return
        }

        timerSubscription = nil
        isRunning = false

        if shouldDisableAfterStop {
            isEnabled = false
        }
    }

    /// Stop and disable
    /// Was stopped by user manualy
    public func disableManually() {
        if isRunning {
            wasStoppedByUser = true
        }
        stop()
        isEnabled = false
    }

    public func enable() {
        isEnabled = true
    }
}
