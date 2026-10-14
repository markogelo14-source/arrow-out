import Foundation
import Observation

/// Everything the game remembers between launches. Stored only on the device (UserDefaults).
@MainActor
@Observable
final class PlayerProgress {
    private let defaults: UserDefaults

    /// The next level to play (levels are endless).
    var currentLevel: Int {
        didSet { defaults.set(currentLevel, forKey: Keys.currentLevel) }
    }

    /// Day key of the last Daily Puzzle solved.
    var dailyLastCompleted: String {
        didSet { defaults.set(dailyLastCompleted, forKey: Keys.dailyLastCompleted) }
    }

    /// Days in a row the Daily Puzzle was solved.
    var dailyStreak: Int {
        didSet { defaults.set(dailyStreak, forKey: Keys.dailyStreak) }
    }

    /// Day keys of every Daily Puzzle solved, for the week row and streak screen.
    var dailySolvedDays: Set<String> {
        didSet { defaults.set(dailySolvedDays.sorted(), forKey: Keys.dailySolvedDays) }
    }

    var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Haptics.enabledKey) }
    }

    var soundEnabled: Bool {
        didSet { defaults.set(soundEnabled, forKey: Sound.enabledKey) }
    }

    var hasSeenTutorial: Bool {
        didSet { defaults.set(hasSeenTutorial, forKey: Keys.hasSeenTutorial) }
    }

    /// Moments we already asked for a rating at, so each one asks only once.
    private(set) var reviewMomentsAsked: Set<String> {
        didSet { defaults.set(reviewMomentsAsked.sorted(), forKey: Keys.reviewMomentsAsked) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        currentLevel = max(defaults.integer(forKey: Keys.currentLevel), 1)
        dailyLastCompleted = defaults.string(forKey: Keys.dailyLastCompleted) ?? ""
        dailyStreak = defaults.integer(forKey: Keys.dailyStreak)
        if let saved = defaults.stringArray(forKey: Keys.dailySolvedDays) {
            dailySolvedDays = Set(saved)
        } else {
            // Older installs only stored the last solve and the streak, so rebuild the run of days it implies.
            let last = defaults.string(forKey: Keys.dailyLastCompleted) ?? ""
            let streak = max(defaults.integer(forKey: Keys.dailyStreak), 1)
            dailySolvedDays = last.isEmpty ? [] : Set((0..<streak).compactMap { DayKey.key($0, daysBefore: last) })
        }
        hapticsEnabled = defaults.object(forKey: Haptics.enabledKey) as? Bool ?? true
        soundEnabled = defaults.object(forKey: Sound.enabledKey) as? Bool ?? true
        hasSeenTutorial = defaults.bool(forKey: Keys.hasSeenTutorial)
        reviewMomentsAsked = Set(defaults.stringArray(forKey: Keys.reviewMomentsAsked) ?? [])
    }

    var dailySolvedToday: Bool { dailyLastCompleted == DayKey.today }

    /// The streak as it stands today (it lapses if yesterday's puzzle was missed).
    var currentStreak: Int {
        dailyLastCompleted == DayKey.today || dailyLastCompleted == DayKey.yesterday ? dailyStreak : 0
    }

    func recordWin(_ mode: GameMode) {
        switch mode {
        case .level(let number):
            if number >= currentLevel { currentLevel = number + 1 }
        case .daily(let key):
            guard key == DayKey.today, dailyLastCompleted != key else { return }
            dailyStreak = dailyLastCompleted == DayKey.yesterday ? dailyStreak + 1 : 1
            dailyLastCompleted = key
            dailySolvedDays.insert(key)
        }
    }

    /// True once, right after a win worth asking for a rating at: the 5th cleared level, and a
    /// Daily Puzzle that takes the streak to 3 days. Apple shows the prompt at most 3 times a year.
    func takeReviewMoment(after mode: GameMode) -> Bool {
        let moment: String
        switch mode {
        case .level(let number):
            guard number == 5 else { return false }
            moment = "level5"
        case .daily:
            guard currentStreak >= 3 else { return false }
            moment = "streak3"
        }
        return reviewMomentsAsked.insert(moment).inserted
    }

    func reset() {
        currentLevel = 1
        dailyLastCompleted = ""
        dailyStreak = 0
        dailySolvedDays = []
        hasSeenTutorial = false
    }

    private enum Keys {
        static let currentLevel = "currentLevel"
        static let dailyLastCompleted = "dailyLastCompleted"
        static let dailyStreak = "dailyStreak"
        static let dailySolvedDays = "dailySolvedDays"
        static let hasSeenTutorial = "hasSeenTutorial"
        static let reviewMomentsAsked = "reviewMomentsAsked"
    }
}
