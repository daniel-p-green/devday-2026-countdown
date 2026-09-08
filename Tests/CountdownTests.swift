import Foundation

@main struct CountdownTests {
    static func main() {
        let iso = ISO8601DateFormatter()
        func check(_ stamp: String, _ expected: Int) {
            let actual = Countdown(at: iso.date(from: stamp)!).days
            precondition(actual == expected, "\(stamp): expected \(expected), got \(actual)")
        }
        check("2026-09-08T19:00:00Z", 21)
        check("2026-09-29T06:59:59Z", 1)
        check("2026-09-29T07:00:00Z", 0)
        check("2026-09-30T06:59:59Z", 0)
        check("2026-09-30T07:00:00Z", -1)
        check("2026-08-01T12:00:00Z", 59)
        for days in -2...70 {
            let value = Countdown(at: Countdown.date(daysBeforeEvent: days))
            precondition(value.days == days)
            precondition(value.artwork == (days <= 0 ? "AnimalTODAY" : "Animal\(min(days,21))"))
        }
        precondition(Countdown(at: Countdown.date(daysBeforeEvent: 1)).caption == "day to go")
        // Midnight across both US daylight-saving boundaries must remain local midnight.
        for stamp in ["2026-03-08T08:00:00Z", "2026-11-01T07:00:00Z"] {
            let next = Countdown.nextMidnight(after: iso.date(from: stamp)!)
            precondition(Countdown.calendar.component(.hour, from: next) == 0)
        }
        for choice in Attendance.allCases {
            for days in [-1, 0, 1, 21] {
                let text = choice.caption(for: Countdown(at: Countdown.date(daysBeforeEvent: days)))
                precondition(text.contains("@OpenAIDevs") && text.contains("#DevDay2026"))
                precondition(!text.contains("http"))
                precondition(!text.hasPrefix("1 days"))
            }
        }
        precondition(Attendance.virtual.caption(for: Countdown(at: Countdown.date(daysBeforeEvent: 0))).contains("online today"))
        print("PASS: date boundaries, event day, post-event, pre-window, artwork range, singular label, DST")
    }
}
