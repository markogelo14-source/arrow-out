import SwiftUI

/// The level map: chapters of tiles on the board's dotted background. Cleared and current
/// levels can be played; later ones are locked.
struct LevelMapView: View {
    let onSelect: (Int) -> Void
    @Environment(PlayerProgress.self) private var progress
    @Environment(\.dismiss) private var dismiss

    static let levelsPerChapter = 8
    /// Sideways offsets that make each chapter's tiles wind down the screen.
    private let swing: [CGFloat] = [0, 56, 84, 56, 0, -56, -84, -56]

    var body: some View {
        ZStack(alignment: .top) {
            Theme.background.ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 28) {
                        ForEach(1...chapterCount, id: \.self) { chapter in
                            chapterView(chapter)
                        }
                    }
                    .padding(.top, 76)
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity)
                    .background(MapDots())
                }
                .onAppear {
                    proxy.scrollTo(progress.currentLevel, anchor: .center)
                }
            }

            header
        }
    }

    private var header: some View {
        HStack {
            Text("Levels")
                .font(.system(.title, design: .rounded).weight(.heavy))
                .foregroundStyle(Theme.ink)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Theme.secondaryInk)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Theme.background.opacity(0.94))
    }

    /// Every chapter up to the player's, plus one locked chapter to look forward to.
    private var chapterCount: Int {
        (progress.currentLevel - 1) / Self.levelsPerChapter + 2
    }

    private func chapterView(_ chapter: Int) -> some View {
        let first = (chapter - 1) * Self.levelsPerChapter + 1
        let levels = Array(first..<(first + Self.levelsPerChapter))

        return VStack(spacing: 14) {
            VStack(spacing: 2) {
                Text("Chapter \(chapter)")
                    .font(.system(.headline, design: .rounded).weight(.heavy))
                    .foregroundStyle(Theme.ink)
                Text(sizeLabel(levels))
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Theme.secondaryInk)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Capsule().fill(Theme.board))

            ForEach(Array(levels.enumerated()), id: \.element) { index, level in
                LevelTile(level: level, state: state(of: level)) {
                    onSelect(level)
                }
                .offset(x: swing[index % swing.count])
                .id(level)
            }
        }
    }

    private func state(of level: Int) -> LevelTile.Status {
        if level < progress.currentLevel { return .cleared }
        if level == progress.currentLevel { return .current }
        return .locked
    }

    private func sizeLabel(_ levels: [Int]) -> String {
        let sizes = levels.map { level -> String in
            let spec = LevelGenerator.spec(forLevel: level)
            return "\(spec.columns)×\(spec.rows)"
        }
        var unique: [String] = []
        for size in sizes where !unique.contains(size) { unique.append(size) }
        return unique.joined(separator: " and ") + " boards"
    }
}

/// One level on the map, drawn as a chunky arrow-colored tile.
struct LevelTile: View {
    enum Status { case cleared, current, locked }

    let level: Int
    let state: Status
    let action: () -> Void

    @State private var pulse = false

    var body: some View {
        Button(action: action) {
            ZStack {
                switch state {
                case .cleared:
                    VStack(spacing: 0) {
                        Text("\(level)")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.heavy))
                            .opacity(0.85)
                    }
                case .current:
                    VStack(spacing: 0) {
                        Image(systemName: "play.fill")
                            .font(.title3)
                        Text("\(level)")
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                    }
                case .locked:
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.gridDot)
                }
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(TileButtonStyle(color: color, isLocked: state == .locked))
        .disabled(state == .locked)
        .overlay {
            if state == .current {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(Theme.indigo.opacity(0.35), lineWidth: 4)
                    .frame(width: size + 14, height: size + 14)
                    .scaleEffect(pulse ? 1.08 : 1)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) { pulse = true }
                    }
                    .allowsHitTesting(false)
            }
        }
        .accessibilityLabel(accessibilityText)
    }

    private var size: CGFloat { state == .current ? 78 : 64 }

    private var color: Color {
        switch state {
        case .cleared: return Theme.pieceColors[(level - 1) % Theme.pieceColors.count]
        case .current: return Theme.indigo
        case .locked: return Theme.board
        }
    }

    private var accessibilityText: String {
        switch state {
        case .cleared: return "Level \(level), cleared"
        case .current: return "Level \(level), play next"
        case .locked: return "Level \(level), locked"
        }
    }
}

/// A raised square tile with a darker lip, matching the board's arrow pieces.
struct TileButtonStyle: ButtonStyle {
    var color: Color
    var isLocked: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(color)
                    .shadow(
                        color: .black.opacity(isLocked ? 0.06 : 0.18),
                        radius: 0, x: 0, y: configuration.isPressed ? 1 : 5
                    )
            )
            .offset(y: configuration.isPressed ? 4 : 0)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
    }
}

/// The board's dot grid, repeated behind the whole map.
private struct MapDots: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 28
            let radius: CGFloat = 1.6
            var y = spacing / 2
            while y < size.height {
                var x = spacing / 2
                while x < size.width {
                    let dot = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                    context.fill(Path(ellipseIn: dot), with: .color(Theme.gridDot.opacity(0.6)))
                    x += spacing
                }
                y += spacing
            }
        }
        .allowsHitTesting(false)
    }
}
