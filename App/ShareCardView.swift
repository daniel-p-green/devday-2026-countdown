import SwiftUI
import UniformTypeIdentifiers
#if os(iOS)
import UIKit
#else
import AppKit
#endif

struct ShareCardView: View {
    @State private var countdown: Countdown
    @Environment(\.openURL) private var openURL
    @State private var xStatus: String?
    @State private var captionCopied = false
    @State private var savingImage = false
    @State private var imageDocument: ShareImageDocument?
    @State private var saveStatus: String?

    init(countdown: Countdown) {
        _countdown = State(initialValue: countdown)
    }
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
                        Button("Copy image & open X", action: openX)
                            .buttonStyle(.borderedProminent)
                        #if os(macOS)
                        Text("Your caption opens in X. Click in the post and press ⌘V to paste the image, then review and post.")
                            .font(.caption).foregroundStyle(.secondary)
                        #else
                        Text("Your caption opens in X. Touch and hold in the post and choose Paste to add the image, then review and post.")
                            .font(.caption).foregroundStyle(.secondary)
                        #endif
                        if let xStatus { Text(xStatus).font(.caption) }
                        Divider()
                        Text("Instagram").font(.headline)
                        Text("Instagram shares the image only. Copy the caption below, then paste it in Instagram after adding the image.")
                            .font(.caption).foregroundStyle(.secondary)
                        Button(captionCopied ? "Caption copied" : "Copy caption for Instagram") {
                            xStatus = nil
                            #if os(macOS)
                            NSPasteboard.general.clearContents()
                            captionCopied = NSPasteboard.general.setString(caption, forType: .string)
                            #else
                            UIPasteboard.general.string = caption
                            captionCopied = true
                            #endif
                        }
                        Button("Save image…") {
                            do {
                                let data = try Data(contentsOf: exportURL)
                                saveStatus = nil
                                #if os(macOS)
                                let panel = NSSavePanel()
                                panel.allowedContentTypes = [.png]
                                panel.nameFieldStringValue = exportURL.lastPathComponent
                                panel.canCreateDirectories = true
                                if panel.runModal() == .OK, let destination = panel.url {
                                    try data.write(to: destination, options: .atomic)
                                    saveStatus = "Image saved."
                                }
                                #else
                                imageDocument = ShareImageDocument(data: data)
                                savingImage = true
                                #endif
                            } catch { saveStatus = "Could not read image: \(error.localizedDescription)" }
                        }
                        Text("Save the PNG to a folder or Files, then upload it in Instagram.")
                            .font(.caption).foregroundStyle(.secondary)
                        if let saveStatus { Text(saveStatus).font(.caption) }
                        NativeShareButton(imageURL: exportURL, caption: caption)
                            .frame(height: 34)
                    } else if let exportError { Text(exportError).foregroundStyle(.red) }
                    else { ProgressView() }
                    Text("Other sharing options opens the system share sheet. Choose Instagram if available, or save the image to upload yourself.")
                        .font(.caption).foregroundStyle(.secondary)
                }.padding(24)
            }
            .navigationTitle("Share this day")
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
        #if os(macOS)
        .frame(width: 440, height: story ? 760 : 700)
        #endif
        .preferredColorScheme(.dark)
        .task(id: story) { render() }
        .onChange(of: attendance) { _, _ in captionCopied = false; xStatus = nil }
        .fileExporter(isPresented: $savingImage, document: imageDocument, contentType: .png,
                      defaultFilename: exportURL?.deletingPathExtension().lastPathComponent ?? "DevDay2026") { result in
            switch result {
            case .success: saveStatus = "Image saved."
            case .failure(let error): saveStatus = "Could not save image: \(error.localizedDescription)"
            }
        }
    }
    @MainActor private func openX() {
        guard let exportURL, let data = try? Data(contentsOf: exportURL) else {
            xStatus = "Could not copy the image. Close sharing and try again."
            return
        }
        captionCopied = false
        #if os(macOS)
        guard let image = NSImage(data: data) else { return }
        NSPasteboard.general.clearContents()
        guard NSPasteboard.general.writeObjects([image]) else {
            xStatus = "Could not copy the image. Please try again."
            return
        }
        #else
        guard let image = UIImage(data: data) else { return }
        UIPasteboard.general.image = image
        #endif
        var components = URLComponents(string: "https://x.com/intent/tweet")!
        components.queryItems = [URLQueryItem(name: "text", value: caption)]
        guard let url = components.url else { return }
        openURL(url) { accepted in
            xStatus = accepted ? "Image copied. Paste it into your X post." : "Image copied, but X could not open. Please try again."
        }
    }
    @MainActor func render() {
        exportURL = nil; exportError = nil; saveStatus = nil; xStatus = nil
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

/// A PNG export works with the Mac save panel and the iOS Files picker.
struct ShareImageDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.png] }
    let data: Data
    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
