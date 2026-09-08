import SwiftUI

@main
struct DevDayApp: App {
    @StateObject private var clock = CountdownClock()
    #if os(macOS)
    @AppStorage("showMenuBar") private var showMenuBar = false
    #endif
    var body: some Scene {
        WindowGroup("DevDay 2026", id: "countdown") {
            CountdownView().environmentObject(clock)
                #if os(macOS)
                .frame(minWidth: 280, idealWidth: 440, minHeight: 280, idealHeight: 440)
                #endif
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 440, height: 440)
        #endif
        #if os(macOS)
        Settings { DisplaySettings().environmentObject(clock) }
        MenuBarExtra(isInserted: $showMenuBar) {
            MenuBarCountdown().environmentObject(clock)
        } label: {
            Text(clock.countdown.days < 0 ? "DevDay 2026" : clock.countdown.days == 0 ? "DevDay · Today" : "DevDay · \(clock.countdown.days)d")
        }
        #endif
    }
}

/// The artwork is the interface. Secondary actions live in its context menu.
struct CountdownView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var previewDay: Int?
    @EnvironmentObject private var clock: CountdownClock
    #if os(macOS)
    @AppStorage("showMenuBar") private var showMenuBar = false
    #endif
    @State private var sharing = false
    var selected: Countdown { Countdown(at: previewDay.map(Countdown.date(daysBeforeEvent:)) ?? clock.date) }
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CalendarFace(countdown: selected)
                .aspectRatio(1, contentMode: .fit)
                .id(selected.days)
                .transition(reduceMotion ? .opacity : .asymmetric(insertion: .opacity, removal: .modifier(active: PageTurn(angle: -88), identity: PageTurn(angle: 0))))
                .contextMenu {
                    Button("Share this day…", systemImage: "square.and.arrow.up") { sharing = true }
                    Divider()
                    Button("Previous day", systemImage: "chevron.left") { browse(1) }.disabled(selected.days >= 21)
                    Button("Next day", systemImage: "chevron.right") { browse(-1) }.disabled(selected.days <= 0)
                    #if os(macOS)
                    Divider()
                    SettingsLink { Text("Settings…") }
                    Button("Quit DevDay") { NSApplication.shared.terminate(nil) }
                    Divider()
                    #endif
                    Button("Back to today", systemImage: "calendar") { withAnimation(animation) { previewDay = nil; clock.refresh() } }.disabled(previewDay == nil)
                }
                .accessibilityAction(named: "Share this day") { sharing = true }
                .accessibilityAction(named: "Preview next day") { browse(-1) }
                .accessibilityHint("Right-click or touch and hold for sharing and day previews.")
            if previewDay != nil {
                VStack { Spacer(); Button("Preview · Back to today") { withAnimation(animation) { previewDay = nil; clock.refresh() } }.font(.caption2).buttonStyle(.plain).foregroundStyle(.white.opacity(0.7)).padding(8) }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $sharing) { ShareCardView(countdown: selected) }
        .onChange(of: scenePhase) { _, phase in if phase == .active { clock.refresh() } }
        .onOpenURL { _ in previewDay = nil; clock.refresh() }
    }
    var animation: Animation { reduceMotion ? .easeOut(duration: 0.15) : .easeInOut(duration: 0.45) }
    func browse(_ delta: Int) { withAnimation(animation) { previewDay = min(21, max(0, selected.days + delta)) } }
}
struct PageTurn: ViewModifier {
    let angle: Double
    func body(content: Content) -> some View {
        content.rotation3DEffect(.degrees(angle), axis: (x: 1, y: 0, z: 0), anchor: .top, perspective: 0.35)
    }
}

#if os(macOS)
private struct MenuBarCountdown: View {
    @EnvironmentObject private var clock: CountdownClock
    @Environment(\.openWindow) private var openWindow
    @AppStorage("showMenuBar") private var showMenuBar = false
    var body: some View {
        Text(clock.countdown.accessibilityLabel)
        Button("Open countdown") { openWindow(id: "countdown"); NSApplication.shared.activate(ignoringOtherApps: true) }
        Divider()
        SettingsLink { Text("Settings…") }
        Button("Hide menu-bar countdown") { showMenuBar = false }
        Button("Quit DevDay") { NSApplication.shared.terminate(nil) }
    }
}
#endif
