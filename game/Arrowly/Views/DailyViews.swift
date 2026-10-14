import SwiftUI

/// The Daily Puzzle on the home screen: today's date and the last seven days at a glance.
struct DailyCard: View {
    let action: () -> Void
    @Environment(PlayerProgress.self) private var progress

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daily Puzzle")
                            .font(.system(.title3, design: .rounded).weight(.bold))
                        Text(Date.now.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                            .font(.system(.subheadline, design: .rounded).weight(.medium))
                            .opacity(0.85)
                    }
                    Spacer()
                    Label(
                        progress.dailySolvedToday ? "Solved" : "Play",
                        systemImage: progress.dailySolvedToday ? "checkmark.seal.fill" : "play.fill"
                    )
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color.white.opacity(0.22)))
                }

                WeekRow(solvedDays: progress.dailySolvedDays, tint: .white)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(ChunkyButtonStyle(color: Theme.coral))
        .accessibilityLabel(progress.dailySolvedToday ? "Daily Puzzle, solved today" : "Daily Puzzle")
    }
}

/// Seven days ending today: a filled check for each solved Daily Puzzle.
struct WeekRow: View {
    let solvedDays: Set<String>
    var tint: Color = Theme.coral

    var body: some View {
        let days = DayKey.recentDays(7)
        HStack(spacing: 6) {
            ForEach(days, id: \.self) { key in
                let solved = solvedDays.contains(key)
                let isToday = key == DayKey.today
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(solved ? tint : .clear)
                        Circle()
                            .stroke(tint.opacity(solved ? 1 : 0.45), lineWidth: isToday ? 2.5 : 1.5)
                        if solved {
                            Image(systemName: "checkmark")
                                .font(.caption2.weight(.heavy))
                                .foregroundStyle(tint == .white ? Theme.coral : .white)
                        }
                    }
                    .frame(width: 26, height: 26)
                    Text(weekdayLetter(key))
                        .font(.system(.caption2, design: .rounded).weight(isToday ? .heavy : .medium))
                        .foregroundStyle(tint.opacity(isToday ? 1 : 0.75))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(days.filter(solvedDays.contains).count) of the last 7 Daily Puzzles solved")
    }

    private func weekdayLetter(_ key: String) -> String {
        guard let date = DayKey.date(from: key) else { return "" }
        return date.formatted(.dateTime.weekday(.narrow))
    }
}

/// Shown after the Daily Puzzle is solved: the streak, the week and a way to share it.
struct StreakCard: View {
    let model: GameModel
    let onHome: () -> Void
    @Environment(PlayerProgress.self) private var progress

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.system(size: 96))
                .foregroundStyle(Theme.coral)
                .overlay(alignment: .bottomTrailing) {
                    Text("\(progress.currentStreak)")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.coral)
                        .contentTransition(.numericText())
                        .frame(minWidth: 48, minHeight: 48)
                        .padding(.horizontal, 4)
                        .background(
                            Capsule()
                                .fill(.white)
                                .overlay(Capsule().stroke(Theme.coral, lineWidth: 3))
                        )
                        .offset(x: 22, y: 8)
                }
                .accessibilityHidden(true)

            VStack(spacing: 4) {
                Text(progress.currentStreak == 1 ? "1 day streak" : "\(progress.currentStreak) day streak")
                    .font(.system(.title, design: .rounded).weight(.heavy))
                    .foregroundStyle(Theme.ink)
                Text("Today's puzzle solved in \(formatTime(model.finishTime)). Come back tomorrow to keep it going.")
                    .font(.system(.callout, design: .rounded))
                    .foregroundStyle(Theme.secondaryInk)
                    .multilineTextAlignment(.center)
            }

            WeekRow(solvedDays: progress.dailySolvedDays)
                .padding(.vertical, 4)

            ShareLink(item: shareText) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(ChunkyButtonStyle(color: Theme.coral))

            Button("Done", action: onHome)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Theme.secondaryInk)
        }
    }

    /// A spoiler-free result, Wordle style:
    /// Arrowly #12 🏹 / ⏱ 2:41  ❤️❤️🤍  💡1 / 🔥 5 day streak, plus the App Store link once it exists.
    private var shareText: String {
        var title = "Arrowly"
        if case .daily(let key) = model.mode, let number = DayKey.puzzleNumber(for: key) {
            title += " #\(number)"
        }
        let hearts = String(repeating: "❤️", count: model.hearts)
            + String(repeating: "🤍", count: GameModel.maxHearts - model.hearts)
        var lines = [
            "\(title) 🏹",
            "⏱ \(formatTime(model.finishTime))  \(hearts)  💡\(model.hintsUsed)",
            progress.currentStreak == 1 ? "🔥 1 day streak" : "🔥 \(progress.currentStreak) day streak",
        ]
        if let link = AppLinks.appStore { lines.append(link.absoluteString) }
        return lines.joined(separator: "\n")
    }
}

/// "1:05" style minutes and seconds.
func formatTime(_ seconds: TimeInterval) -> String {
    let total = max(Int(seconds.rounded()), 0)
    return String(format: "%d:%02d", total / 60, total % 60)
}
