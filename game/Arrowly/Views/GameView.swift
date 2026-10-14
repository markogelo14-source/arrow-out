import SwiftUI

struct GameView: View {
    @State private var model: GameModel
    @Environment(PlayerProgress.self) private var progress
    @Environment(\.dismiss) private var dismiss

    init(mode: GameMode) {
        _model = State(initialValue: GameModel(mode: mode))
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 16) {
                header

                if showTutorial {
                    Text("Tap an arrow with a clear path to send it off the board. A blocked arrow costs a heart.")
                        .font(.system(.callout, design: .rounded))
                        .foregroundStyle(Theme.secondaryInk)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                        .transition(.opacity)
                }

                BoardView(model: model)
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                footer
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .frame(maxWidth: 640)

            if model.phase != .playing {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .transition(.opacity)
                ResultCard(
                    phase: model.phase,
                    mode: model.mode,
                    onNext: nextLevel,
                    onRetry: { model.restart() },
                    onHome: { dismiss() }
                )
                .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: model.phase) { _, phase in
            if phase == .won {
                progress.recordWin(model.mode)
                progress.hasSeenTutorial = true
            }
        }
    }

    private var showTutorial: Bool {
        if case .level(let number) = model.mode, number <= 2, !progress.hasSeenTutorial { return true }
        return false
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Back")

            Spacer()

            VStack(spacing: 2) {
                Text(model.mode.title)
                    .font(.system(.title2, design: .rounded).weight(.heavy))
                    .foregroundStyle(Theme.ink)
                Text("\(model.piecesLeft) arrows left")
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(Theme.secondaryInk)
                    .contentTransition(.numericText())
            }

            Spacer()

            HStack(spacing: 3) {
                ForEach(0..<GameModel.maxHearts, id: \.self) { index in
                    Image(systemName: index < model.hearts ? "heart.fill" : "heart")
                        .foregroundStyle(index < model.hearts ? Theme.danger : Theme.secondaryInk)
                        .symbolEffect(.bounce, value: model.hearts)
                }
            }
            .font(.title3)
            .frame(width: 80, alignment: .trailing)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(model.hearts) hearts left")
        }
    }

    private var footer: some View {
        HStack(spacing: 16) {
            Button {
                model.restart()
            } label: {
                Label("Restart", systemImage: "arrow.counterclockwise")
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(ChunkyButtonStyle(color: Theme.secondaryInk))

            Button {
                model.useHint()
            } label: {
                Label("Hint (\(model.hintsLeft))", systemImage: "lightbulb.fill")
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(ChunkyButtonStyle(color: Theme.indigo))
            .disabled(model.hintsLeft == 0 || model.phase != .playing)
            .opacity(model.hintsLeft == 0 ? 0.5 : 1)
        }
        .padding(.bottom, 8)
    }

    private func nextLevel() {
        if case .level(let number) = model.mode {
            model.load(.level(number + 1))
        } else {
            dismiss()
        }
    }
}

/// Shown over the board when a level is won or lost.
struct ResultCard: View {
    let phase: GameModel.Phase
    let mode: GameMode
    let onNext: () -> Void
    let onRetry: () -> Void
    let onHome: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: phase == .won ? "star.fill" : "heart.slash.fill")
                .font(.system(size: 52))
                .foregroundStyle(phase == .won ? Color(red: 0.961, green: 0.651, blue: 0.137) : Theme.danger)
                .symbolEffect(.bounce, value: phase)

            Text(phase == .won ? "Board cleared!" : "Out of hearts")
                .font(.system(.title, design: .rounded).weight(.heavy))
                .foregroundStyle(Theme.ink)

            Text(message)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(Theme.secondaryInk)
                .multilineTextAlignment(.center)

            if phase == .won {
                if case .level = mode {
                    Button(action: onNext) {
                        Text("Next level")
                            .font(.system(.title3, design: .rounded).weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.indigo))
                } else {
                    Button(action: onHome) {
                        Text("Done")
                            .font(.system(.title3, design: .rounded).weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.indigo))
                }
            } else {
                Button(action: onRetry) {
                    Text("Try again")
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(ChunkyButtonStyle(color: Theme.coral))
            }

            Button("Home", action: onHome)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Theme.secondaryInk)
        }
        .padding(28)
        .frame(maxWidth: 340)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Theme.background)
                .shadow(color: .black.opacity(0.2), radius: 24, y: 10)
        )
        .padding(24)
    }

    private var message: String {
        switch (phase, mode) {
        case (.won, .daily): return "You solved today's puzzle. Come back tomorrow for a new one."
        case (.won, _): return "Nice work. The next board is a little bigger."
        default: return "A blocked arrow costs a heart. Look for arrows with a clear path first."
        }
    }
}
