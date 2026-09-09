import Foundation

enum Attendance: String, CaseIterable, Identifiable {
    case following = "Following along"
    case inPerson = "In person"
    case virtual = "Virtually"
    var id: String { rawValue }
    func caption(for day: Countdown) -> String {
        if day.isCommunityNight {
            return "13 days to @OpenAI DevDay!\nGPT-6 Community Night · September 16 · San Francisco. @OpenAIDevs\n#DevDay2026"
        }
        let lead = day.days < 0 ? "Celebrating @OpenAI DevDay 2026!" : day.days == 0 ? "Today is @OpenAI DevDay!" : "\(day.days) \(day.days == 1 ? "day" : "days") to @OpenAI DevDay!"
        let detail: String
        switch self {
        case .following: detail = day.days < 0 ? "Looking back with @OpenAIDevs." : day.days == 0 ? "Following along with @OpenAIDevs." : "Counting down with @OpenAIDevs."
        case .inPerson: detail = day.days < 0 ? "Memories from San Francisco. @OpenAIDevs" : day.days == 0 ? "Here in San Francisco! @OpenAIDevs" : "See you in San Francisco. @OpenAIDevs"
        case .virtual: detail = day.days < 0 ? "A look back from afar. @OpenAIDevs" : day.days == 0 ? "Following online today. @OpenAIDevs" : "I’ll be following online. @OpenAIDevs"
        }
        return "\(lead)\n\(detail)\n#DevDay2026"
    }
}
