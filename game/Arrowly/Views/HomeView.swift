import SwiftUI

struct HomeView: View {
    @Binding var path: [GameMode]
    @Environment(PlayerProgress.self) private var progress
    @State private var showSettings = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 28) {
                HStack {
                    Spacer()
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundStyle(Theme.secondaryInk)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Settings")
                }

                Spacer()

                LogoView()
                    .frame(width: 150, height: 150)

                VStack(spacing: 6) {
                    Text("Arrowly")
                        .font(.system(size: 52, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.ink)
                    Text("Tap arrows. Clear the board.")
                        .font(.system(.title3, design: .rounded))
                        .foregroundStyle(Theme.secondaryInk)
                }

                Spacer()

                VStack(spacing: 14) {
                    Button {
                        path.append(.level(progress.currentLevel))
                    } label: {
                        VStack(spacing: 2) {
                            Text("Play")
                                .font(.system(.title2, design: .rounded).weight(.bold))
                            Text("Level \(progress.currentLevel)")
                                .font(.system(.subheadline, design: .rounded).weight(.medium))
                                .opacity(0.85)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.indigo))

                    Button {
                        path.append(.daily(DayKey.today))
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: progress.dailySolvedToday ? "checkmark.seal.fill" : "calendar")
                            Text(progress.dailySolvedToday ? "Daily Puzzle solved" : "Daily Puzzle")
                        }
                        .font(.system(.title3, design: .rounded).weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .buttonStyle(ChunkyButtonStyle(color: Theme.coral))

                    Text(streakText)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(Theme.secondaryInk)
                        .frame(height: 20)
                }
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 28)
            .frame(maxWidth: 520)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private var streakText: String {
        let streak = progress.currentStreak
        if streak == 0 { return "Solve the Daily Puzzle to start a streak" }
        return streak == 1 ? "🔥 1 day streak" : "🔥 \(streak) day streak"
    }
}

/// A raised, rounded button with a darker "lip" underneath.
struct ChunkyButtonStyle: ButtonStyle {
    var color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(color)
                    .shadow(color: .black.opacity(0.18), radius: 0, x: 0, y: configuration.isPressed ? 1 : 5)
            )
            .offset(y: configuration.isPressed ? 4 : 0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

/// The home screen logo: a 3x3 cluster of arrow tiles.
struct LogoView: View {
    private let pieces: [Piece] = [
        Piece(id: 0, head: Cell(col: 0, row: 0), direction: .up, length: 1, colorIndex: 2),
        Piece(id: 1, head: Cell(col: 2, row: 0), direction: .right, length: 2, colorIndex: 0),
        Piece(id: 2, head: Cell(col: 0, row: 2), direction: .down, length: 2, colorIndex: 3),
        Piece(id: 3, head: Cell(col: 1, row: 1), direction: .left, length: 1, colorIndex: 1),
        Piece(id: 4, head: Cell(col: 2, row: 1), direction: .down, length: 1, colorIndex: 4),
        Piece(id: 5, head: Cell(col: 2, row: 2), direction: .right, length: 2, colorIndex: 5),
    ]

    var body: some View {
        GeometryReader { geometry in
            let cell = min(geometry.size.width, geometry.size.height) / 3
            ZStack(alignment: .topLeading) {
                ForEach(pieces) { piece in
                    let cols = piece.cells.map(\.col)
                    let rows = piece.cells.map(\.row)
                    PieceView(piece: piece, cell: cell, isHinted: false, isFlashing: false)
                        .position(
                            x: CGFloat(cols.min()! + cols.max()! + 1) / 2 * cell,
                            y: CGFloat(rows.min()! + rows.max()! + 1) / 2 * cell
                        )
                }
            }
        }
        .accessibilityHidden(true)
    }
}
