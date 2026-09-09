import Foundation

/// Calendar-day countdown; never depends on the viewer's current timezone.
struct Countdown: Equatable, Sendable {
    static let timeZone = TimeZone(identifier: "America/Los_Angeles")!
    static var calendar: Calendar {
        var value = Calendar(identifier: .gregorian)
        value.timeZone = timeZone
        return value
    }
    static let eventDate = calendar.date(from: DateComponents(year: 2026, month: 9, day: 29))!
    let days: Int

    init(at date: Date = .now) {
        days = Self.calendar.dateComponents([.day], from: Self.calendar.startOfDay(for: date), to: Self.eventDate).day!
    }
    var isCommunityNight: Bool { days == 13 }
    var headline: String { days < 0 ? "THANK YOU" : days == 0 ? "TODAY" : String(days) }
    var caption: String { days < 0 ? "See you next time" : days == 0 ? "September 29 · San Francisco" : days == 1 ? "day to go" : "days to go" }
    var artwork: String { days <= 0 ? "AnimalTODAY" : "Animal\(min(days, 21))" }
    var accessibilityLabel: String { isCommunityNight ? "GPT-6 Community Night, September 16 in San Francisco. 13 days to OpenAI DevDay." : days < 0 ? "DevDay 2026 has ended" : days == 0 ? "OpenAI DevDay is today" : "\(days) \(caption) until OpenAI DevDay" }
    static func date(daysBeforeEvent days: Int) -> Date {
        calendar.date(byAdding: .day, value: -days, to: eventDate)!
    }
    static func nextMidnight(after date: Date) -> Date {
        calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date))!
    }
}
