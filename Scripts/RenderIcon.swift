import SwiftUI
import AppKit

/// Render inside the built Mac bundle so Animal21 resolves from the asset catalog.
@main
struct RenderIcon {
    @MainActor static func main() throws {
        let output = URL(fileURLWithPath: CommandLine.arguments[1])
        let content = ZStack {
            Color(red: 0.03, green: 0.03, blue: 0.03)
            Image("Animal21").resizable().scaledToFit()
                .frame(width: 690, height: 620).position(x: 512, y: 400)
            Text("2026").font(.system(size: 180, weight: .bold, design: .monospaced))
                .foregroundStyle(Color(red: 0.28, green: 0.86, blue: 0.13))
                .position(x: 512, y: 845)
        }.frame(width: 1024, height: 1024)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 1
        guard let image = renderer.cgImage,
              let png = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else { fatalError("Icon render failed") }
        try png.write(to: output)
    }
}
