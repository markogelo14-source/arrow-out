import Foundation

/// Which board the player is on.
enum GameMode: Hashable, Sendable {
    case level(Int)
    /// The Daily Puzzle for a calendar day, keyed "yyyy-MM-dd".
    case daily(String)

    var spec: LevelSpec {
        switch self {
        case .level(let number):
            return LevelGenerator.spec(forLevel: number)
        case .daily(let key):
            return LevelGenerator.dailySpec(for: DayKey.date(from: key) ?? Date())
        }
    }

    var title: String {
        switch self {
        case .level(let number): return "Level \(number)"
        case .daily: return "Daily Puzzle"
        }
    }
}

/// Converts between dates and "yyyy-MM-dd" keys in the player's own calendar.
enum DayKey {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func key(for date: Date) -> String {
        formatter.string(from: date)
    }

    static func date(from key: String) -> Date? {
        formatter.date(from: key)
    }

    static var today: String { key(for: Date()) }

    static var yesterday: String {
        key(for: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date())
    }

    /// The key `days` days before the day `key` names, or nil if `key` is not a valid day.
    static func key(_ days: Int, daysBefore key: String) -> String? {
        guard let date = date(from: key),
              let earlier = Calendar.current.date(byAdding: .day, value: -days, to: date) else { return nil }
        return self.key(for: earlier)
    }

    /// The last `count` days ending today, oldest first.
    static func recentDays(_ count: Int) -> [String] {
        (0..<count).reversed().compactMap { key($0, daysBefore: today) }
    }
}
