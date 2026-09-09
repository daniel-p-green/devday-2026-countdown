import SwiftUI
import WidgetKit

struct DayEntry: TimelineEntry { let date: Date }
struct DayProvider: TimelineProvider {
    func placeholder(in context: Context) -> DayEntry { DayEntry(date: .now) }
    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> Void) { completion(DayEntry(date: .now)) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<DayEntry>) -> Void) {
        let now = Date.now
        // Preload calendar boundaries; WidgetKit controls the exact refresh time.
        let entries = (0..<8).map { offset in
            DayEntry(date: offset == 0 ? now : Countdown.calendar.date(byAdding: .day, value: offset - 1, to: Countdown.nextMidnight(after: now))!)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }
}
struct WidgetFace: View {
    let entry: DayEntry
    @Environment(\.widgetFamily) private var family
    var body: some View {
        let day = Countdown(at: entry.date)
        Group {
            if family == .systemLarge || family == .systemSmall {
                CalendarFace(countdown: day)
            } else {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(day.isCommunityNight ? "GPT-6 Community Night" : "OpenAI DevDay").font(.caption.weight(.medium)).lineLimit(1).minimumScaleFactor(0.7)
                        Spacer(minLength: 2)
                        Text(day.headline).font(.system(size: day.days < 0 ? 24 : day.days == 0 ? 32 : 48, weight: .medium, design: .monospaced)).minimumScaleFactor(0.6).lineLimit(1)
                        Text(day.isCommunityNight ? "days to DevDay" : day.days < 0 ? "2026" : day.days == 0 ? "San Francisco" : day.caption).font(.caption)
                        Spacer(minLength: 2)
                        Text(day.isCommunityNight ? "SEP 16 · SAN FRANCISCO" : "SEP 29 · 2026").font(.system(size: 9, design: .monospaced)).foregroundStyle(.secondary)
                    }
                    if family == .systemMedium { Image(day.isCommunityNight ? "CommunityNightSquare" : day.artwork).resizable().scaledToFit().frame(maxWidth: 145).accessibilityHidden(true) }
                }.padding(16).foregroundStyle(.white)
            }
        }
        .containerBackground(.black, for: .widget)
        .widgetURL(URL(string: "devday2026://today"))
        .accessibilityElement(children: .ignore).accessibilityLabel(day.accessibilityLabel)
    }
}
@main
struct DevDayWidget: Widget {
    let kind = "DevDay2026"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DayProvider()) { WidgetFace(entry: $0) }
            .configurationDisplayName("DevDay 2026")
            .description("Count down to September 29 in San Francisco. Tap to browse and share.")
            .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
            .contentMarginsDisabled()
    }
}
