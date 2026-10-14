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

    var hapticsEnabled: Bool {
        didSet { defaults.set(hapticsEnabled, forKey: Haptics.enabledKey) }
    }

    var hasSeenTutorial: Bool {
        didSet { defaults.set(hasSeenTutorial, forKey: Keys.hasSeenTutorial) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        currentLevel = max(defaults.integer(forKey: Keys.currentLevel), 1)
        dailyLastCompleted = defaults.string(forKey: Keys.dailyLastCompleted) ?? ""
        dailyStreak = defaults.integer(forKey: Keys.dailyStreak)
        hapticsEnabled = defaults.object(forKey: Haptics.enabledKey) as? Bool ?? true
        hasSeenTutorial = defaults.bool(forKey: Keys.hasSeenTutorial)
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
        }
    }

    func reset() {
        currentLevel = 1
        dailyLastCompleted = ""
        dailyStreak = 0
        hasSeenTutorial = false
    }

    private enum Keys {
        static let currentLevel = "currentLevel"
        static let dailyLastCompleted = "dailyLastCompleted"
        static let dailyStreak = "dailyStreak"
        static let hasSeenTutorial = "hasSeenTutorial"
    }
}
