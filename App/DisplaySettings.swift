#if os(macOS)
import SwiftUI

struct DisplaySettings: View {
    @EnvironmentObject private var clock: CountdownClock
    @AppStorage("showInDock") private var showInDock = false
    @AppStorage("showMenuBar") private var showMenuBar = false
    var body: some View {
        Form {
            Toggle("Show in Dock", isOn: $showInDock)
            Toggle("Show in menu bar", isOn: $showMenuBar)
            Text("Leave both off for widget-only. Add the widget through desktop Edit Widgets; then close the companion card.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .toggleStyle(.checkbox)
        .formStyle(.grouped)
        .frame(width: 380, height: 180)
        .onChange(of: showInDock) { _, _ in clock.refresh() }
    }
}
#endif
