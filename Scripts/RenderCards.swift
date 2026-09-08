import SwiftUI
import AppKit

/// Run using render_cards.sh so the compiled asset catalog is in Bundle.main.
@main
struct RenderCards {
    @MainActor static func main() throws {
        let folder = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        for day in 0...21 {
            for story in [false, true] {
                let value = Countdown(at: Countdown.date(daysBeforeEvent: day))
                let renderer = ImageRenderer(content: CalendarFace(countdown: value, story: story).frame(width: 1080, height: story ? 1920 : 1080))
                renderer.scale = 1
                guard let image = renderer.cgImage,
                      let data = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else { fatalError("Render failed") }
                try data.write(to: folder.appendingPathComponent("DevDay2026-\(day == 0 ? "TODAY" : String(day))-\(story ? "story" : "square").png"))
            }
        }
        print("Rendered 44 cards at 1080 pixels wide.")
    }
}
