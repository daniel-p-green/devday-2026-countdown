import SwiftUI

#if os(macOS)
import AppKit

/// Both items are handed to the selected service in the same invocation.
struct NativeShareButton: NSViewRepresentable {
    let imageURL: URL
    let caption: String
    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeNSView(context: Context) -> NSButton {
        let button = NSButton(title: "Share image + caption", target: context.coordinator, action: #selector(Coordinator.share(_:)))
        button.bezelStyle = .rounded
        button.image = NSImage(systemSymbolName: "square.and.arrow.up", accessibilityDescription: nil)
        button.imagePosition = .imageLeading
        button.setAccessibilityLabel("Share image and caption")
        return button
    }
    func updateNSView(_ button: NSButton, context: Context) {
        context.coordinator.items = [imageURL, caption]
    }
    final class Coordinator: NSObject {
        var items: [Any] = []
        private var picker: NSSharingServicePicker?
        @objc func share(_ sender: NSButton) {
            let picker = NSSharingServicePicker(items: items)
            self.picker = picker
            picker.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
        }
    }
}
#else
import UIKit

struct NativeShareButton: View {
    let imageURL: URL
    let caption: String
    @State private var presenting = false
    var body: some View {
        Button("Share image + caption", systemImage: "square.and.arrow.up") { presenting = true }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $presenting) { ActivitySheet(imageURL: imageURL, caption: caption) }
    }
}
struct ActivitySheet: UIViewControllerRepresentable {
    let imageURL: URL
    let caption: String
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [imageURL, caption], applicationActivities: nil)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
#endif
