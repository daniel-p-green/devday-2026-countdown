# DevDay 2026 Countdown

A small, unofficial countdown to OpenAI DevDay on September 29, 2026.

![DevDay countdown on Mac](docs/product.png)

Daily artwork, desktop and Home Screen widgets, and cards to share. On Mac, you can also show the count in your Dock or menu bar. Everything runs locally, with no account or API key.

## Run it

**Requires Xcode, macOS 14+ or iOS 17+.** This is a source release; a ready-to-install download isn't available yet.

1. Download or clone this repo and open `DevDay2026.xcodeproj`.
2. Choose **DevDayMac** or **DevDayiOS**.
3. Select your signing team for the app and widget targets. Use your own bundle identifiers if provisioning requires it.
4. Build and run.

Then add **DevDay 2026** through **Edit Widgets** on Mac or the Home Screen widget gallery on iPhone/iPad. The large widget best shows the artwork.

The window pictured above is the companion card for settings and sharing. You can close it after adding the widget.

## Make it yours

Right-click the card on Mac, or touch and hold on iOS, to preview days or share a card.

- **Display:** Mac Settings has **Show in Dock** and **Show in menu bar** checkboxes. Leave both off for widget-only use.
- **Share:** Choose a square or portrait Story, then a caption for **Following along**, **In person**, or **Virtually**. One action shares the image and caption with `@OpenAIDevs` and `#DevDay2026`. Caption handling depends on the receiving app.

The countdown follows San Francisco's timezone. Widget refresh timing is managed by the OS.

## Development

Built with SwiftUI and WidgetKit. Run `./Scripts/test.sh` for date and caption checks, or `./Scripts/render_cards.sh` to export all 44 share images.

See [verification notes](docs/VERIFICATION.md) for tested behavior and remaining checks.

Code is [MIT licensed](LICENSE); [artwork and marks are excluded](ARTWORK-NOTICE.md). Not affiliated with or endorsed by OpenAI.
