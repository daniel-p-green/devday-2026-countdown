import SwiftUI
#if os(macOS)
import AppKit
#endif

@MainActor
final class CountdownClock: ObservableObject {
    @Published private(set) var date = Date.now
    private var timer: Timer?
    init() {
        UserDefaults.standard.register(defaults: ["showInDock": false, "showMenuBar": false])
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }
    deinit { timer?.invalidate() }
    var countdown: Countdown { Countdown(at: date) }
    func refresh() {
        date = .now
        #if os(macOS)
        let day = countdown.days
        let showInDock = UserDefaults.standard.bool(forKey: "showInDock")
        let policy: NSApplication.ActivationPolicy = showInDock ? .regular : .accessory
        if NSApplication.shared.activationPolicy() != policy { NSApplication.shared.setActivationPolicy(policy) }
        NSApplication.shared.dockTile.badgeLabel = showInDock && day >= 0 ? (day == 0 ? "TODAY" : String(day)) : nil
        #endif
    }
}
