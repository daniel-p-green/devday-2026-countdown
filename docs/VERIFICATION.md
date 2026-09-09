# Verification

Checked locally on September 8, 2026 with Xcode 26.6, Swift 6.3.3, macOS 26.6.2, and an iOS 26.5 iPhone simulator.

## Passed

- Mac app and WidgetKit extension compiled.
- iOS app and WidgetKit extension compiled for the simulator; the companion launched and displayed the card.
- Date tests: Pacific midnight before/on/after September 29, pre-series dates, all artwork mappings, singular labels, and both daylight-saving transitions.
- Caption tests: all attendance options, event-day wording, required tags, and no URLs.
- Mac card context menu, day preview, reset, share preview, and attendance selector exercised.
- Mac Settings opened from the card with both display options initially off; each option accepted an on state. Dock mode was verified through the running app activation policy: regular when enabled, accessory when disabled. Both options were restored to off after testing.
- Mac and iOS native sharing opened from one image-and-caption action. In the simulator, the same share sheet showed the PNG and its Copy action returned the selected caption, confirming the combined payload. No post or message was sent.
- Mac widget extension registered and appeared in the desktop widget gallery.
- All 22 square cards and 22 portrait exports rendered. Square compositions were inspected together; portrait composition was reviewed at export size.
- The repository was scanned for personal filesystem paths and credential strings. No credentials, developer team identifiers, private original paths, or font binaries are included.

## Limits

- Adding the Mac widget to the desktop and inspecting its live appearance still requires confirmation; gallery presence alone is not that check.
- The Dock badge was confirmed in the owner-provided screenshot. Menu-bar appearance still needs a final visual check.
- X and Instagram receiving both image and caption has not been tested on physical devices. The receiving app controls which items it accepts. Universal caption prefill is not promised.
- Physical iPhone/iPad testing, overnight rollover, and wake-from-sleep testing are pending. Automated date-boundary tests are separate from OS refresh timing.
- No notarized Mac installer, App Store release, or TestFlight build is provided. Development signing and public distribution signing are separate.

A local Xcode compiler-discovery subprocess stalled while writing to its output pipe during later builds. Verification resumed using a temporary wrapper around the same Apple Clang executable that buffered and forwarded its unchanged stdout/stderr. That local workaround is not part of the project or its build settings. Earlier ordinary unsigned builds also passed; clean CI uses the standard commands in the README.

## Sharing update

The primary action now copies the image and opens X with the selected caption prefilled. Instructions explain the remaining paste and review step. The system share sheet is available separately as Other sharing options. The selected day stays fixed while sharing is open, keeping the preview, caption, and export consistent across midnight. Mac and iOS builds and the date/caption checks passed. The owner confirmed Instagram receives the image only. A separate Copy caption for Instagram action and instructions now explain that limitation. Pasting into a signed-in X composer and the revised Instagram flow still require end-to-end confirmation.
