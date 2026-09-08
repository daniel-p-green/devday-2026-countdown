import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct ShareCardView: View {
    let countdown: Countdown
    @Environment(\.dismiss) private var dismiss
    @State private var story = false
    @State private var exportURL: URL?
    @State private var exportError: String?
    @State private var attendance = Attendance.following
    var caption: String { attendance.caption(for: countdown) }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("Format", selection: $story) {
                        Text("Square · X / Instagram").tag(false)
                        Text("Instagram Story").tag(true)
                    }.pickerStyle(.segmented)
                    CalendarFace(countdown: countdown, story: story)
                        .aspectRatio(story ? 9.0 / 16 : 1, contentMode: .fit)
                        .frame(maxWidth: story ? 200 : 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Picker("I'm joining", selection: $attendance) {
                        ForEach(Attendance.allCases) { choice in Text(choice.rawValue).tag(choice) }
                    }.pickerStyle(.menu)
                    Text(caption).font(.callout).textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading)
                    if let exportURL {
                        NativeShareButton(imageURL: exportURL, caption: caption)
                            .frame(height: 34)
                    } else if let exportError { Text(exportError).foregroundStyle(.red) }
                    else { ProgressView() }
                    Text("Image and caption are shared together. Your chosen app controls how they appear.")
                        .font(.caption).foregroundStyle(.secondary)
                }.padding(24)
            }
            .navigationTitle("Share this day")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
        #if os(macOS)
        .frame(width: 440, height: story ? 660 : 600)
        #endif
        .preferredColorScheme(.dark)
        .task(id: story) { render() }
    }
    @MainActor func render() {
        exportURL = nil; exportError = nil
        let renderer = ImageRenderer(content: CalendarFace(countdown: countdown, story: story).frame(width: 1080, height: story ? 1920 : 1080))
        renderer.scale = 1
        #if os(iOS)
        let data = renderer.uiImage?.pngData()
        #else
        let data = renderer.cgImage.flatMap { NSBitmapImageRep(cgImage: $0).representation(using: .png, properties: [:]) }
        #endif
        guard let data else { exportError = "Could not render image."; return }
        do {
            let folder = FileManager.default.temporaryDirectory.appendingPathComponent("DevDayShares", isDirectory: true)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let url = folder.appendingPathComponent("DevDay2026-\(countdown.headline)-\(story ? "story" : "square").png")
            try data.write(to: url, options: .atomic)
            exportURL = url
        } catch { exportError = "Could not save image: \(error.localizedDescription)" }
    }
}
