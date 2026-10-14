import SwiftUI

/// The bar under the game header that fills as arrows leave the board.
struct BoardProgressBar: View {
    let value: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.board)
                Capsule()
                    .fill(Theme.indigo)
                    .frame(width: max(geometry.size.width * value, value > 0 ? 12 : 0))
            }
        }
        .frame(height: 10)
        .animation(.easeOut(duration: 0.15), value: value)
        .accessibilityElement()
        .accessibilityLabel("Board \(Int((value * 100).rounded())) percent cleared")
    }
}

/// Three small result tiles: hearts left, hints used and time.
struct StatTiles: View {
    let hearts: Int
    let hintsUsed: Int
    let time: TimeInterval

    var body: some View {
        HStack(spacing: 10) {
            tile("Hearts", value: "\(hearts)/\(GameModel.maxHearts)", icon: "heart.fill", color: Theme.danger)
            tile("Hints", value: "\(hintsUsed)", icon: "lightbulb.fill", color: Theme.pieceColors[3])
            tile("Time", value: formatTime(time), icon: "stopwatch.fill", color: Theme.pieceColors[2])
        }
    }

    private func tile(_ title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(title.uppercased())
                .font(.system(.caption2, design: .rounded).weight(.heavy))
                .tracking(0.6)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(color)
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.footnote)
                    .foregroundStyle(color)
                Text(value)
                    .font(.system(.headline, design: .rounded).weight(.heavy))
                    .foregroundStyle(Theme.ink)
                    .monospacedDigit()
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(color, lineWidth: 2)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title): \(value)")
    }
}

/// Tiny arrow tiles in the piece colors falling over the screen after a win.
struct ConfettiView: View {
    private struct Bit: Identifiable {
        let id: Int
        let x = CGFloat.random(in: 0...1)
        let drift = CGFloat.random(in: -40...40)
        let delay = Double.random(in: 0...0.5)
        let duration = Double.random(in: 1.8...2.8)
        let spin = Double.random(in: -300...300)
        let colorIndex = Int.random(in: 0..<Theme.pieceColors.count)
        let direction = Direction.allCases.randomElement() ?? .up
        let size = CGFloat.random(in: 12...20)
    }

    @State private var bits = (0..<44).map { Bit(id: $0) }
    @State private var fallen = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geometry in
            if !reduceMotion {
                ForEach(bits) { bit in
                    ZStack {
                        RoundedRectangle(cornerRadius: bit.size * 0.26, style: .continuous)
                            .fill(Theme.pieceColors[bit.colorIndex])
                        ArrowShape(direction: bit.direction, length: 1)
                            .fill(.white)
                    }
                    .frame(width: bit.size, height: bit.size)
                    .rotationEffect(.degrees(fallen ? bit.spin : 0))
                    .position(
                        x: bit.x * geometry.size.width + (fallen ? bit.drift : 0),
                        y: fallen ? geometry.size.height + 40 : -40
                    )
                    .animation(.easeIn(duration: bit.duration).delay(bit.delay), value: fallen)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear { fallen = true }
    }
}
