import SwiftUI

/// Draws the grid and its pieces, scaled to fit the space it is given.
struct BoardView: View {
    let model: GameModel

    var body: some View {
        GeometryReader { geometry in
            let columns = CGFloat(model.board.columns)
            let rows = CGFloat(model.board.rows)
            let cell = floor(min(geometry.size.width / columns, geometry.size.height / rows))
            let size = CGSize(width: cell * columns, height: cell * rows)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: cell * 0.3, style: .continuous)
                    .fill(Theme.board)
                    .frame(width: size.width + cell * 0.3, height: size.height + cell * 0.3)
                    .offset(x: -cell * 0.15, y: -cell * 0.15)

                GridDots(columns: model.board.columns, rows: model.board.rows, cell: cell)

                ForEach(model.visiblePieces) { piece in
                    PieceView(
                        piece: piece,
                        cell: cell,
                        isHinted: model.hintedID == piece.id,
                        isFlashing: model.flashingID == piece.id
                    )
                    // The tap target is the tile itself, so attach it before positioning.
                    .onTapGesture { model.tap(piece.id) }
                    .accessibilityElement()
                    .accessibilityLabel("Arrow pointing \(name(of: piece.direction))")
                    .accessibilityAddTraits(.isButton)
                    .opacity(model.isLeaving(piece.id) ? 0 : 1)
                    .position(center(of: piece, cell: cell))
                    .offset(offset(of: piece, cell: cell))
                }
            }
            .frame(width: size.width, height: size.height)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func center(of piece: Piece, cell: CGFloat) -> CGPoint {
        let cols = piece.cells.map(\.col)
        let rows = piece.cells.map(\.row)
        let x = CGFloat(cols.min()! + cols.max()! + 1) / 2 * cell
        let y = CGFloat(rows.min()! + rows.max()! + 1) / 2 * cell
        return CGPoint(x: x, y: y)
    }

    private func offset(of piece: Piece, cell: CGFloat) -> CGSize {
        let distance = model.offsets[piece.id] ?? 0
        return CGSize(
            width: CGFloat(piece.direction.dx) * distance * cell,
            height: CGFloat(piece.direction.dy) * distance * cell
        )
    }

    private func name(of direction: Direction) -> String {
        switch direction {
        case .up: return "up"
        case .right: return "right"
        case .down: return "down"
        case .left: return "left"
        }
    }
}

/// One arrow: a colored rounded tile with a white arrow on it.
struct PieceView: View {
    let piece: Piece
    let cell: CGFloat
    let isHinted: Bool
    let isFlashing: Bool

    @State private var pulse = false

    var body: some View {
        let horizontal = piece.direction == .left || piece.direction == .right
        let width = horizontal ? CGFloat(piece.length) * cell : cell
        let height = horizontal ? cell : CGFloat(piece.length) * cell
        let inset = cell * 0.07
        let color = Theme.color(for: piece)

        ZStack {
            RoundedRectangle(cornerRadius: cell * 0.26, style: .continuous)
                .fill(isFlashing ? Theme.danger : color)
                .shadow(color: color.opacity(0.35), radius: 0, x: 0, y: cell * 0.06)
                .padding(inset)
            ArrowShape(direction: piece.direction, length: piece.length)
                .fill(.white)
            if isHinted {
                RoundedRectangle(cornerRadius: cell * 0.3, style: .continuous)
                    .stroke(Theme.ink, lineWidth: max(2, cell * 0.06))
                    .padding(inset * 0.2)
                    .scaleEffect(pulse ? 1.06 : 1)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                            pulse = true
                        }
                    }
            }
        }
        .frame(width: width, height: height)
        .contentShape(Rectangle())
    }
}

/// Faint dots marking each cell of the grid.
struct GridDots: View {
    let columns: Int
    let rows: Int
    let cell: CGFloat

    var body: some View {
        Canvas { context, _ in
            let radius = max(1.5, cell * 0.05)
            for row in 0..<rows {
                for col in 0..<columns {
                    let center = CGPoint(x: (CGFloat(col) + 0.5) * cell, y: (CGFloat(row) + 0.5) * cell)
                    let dot = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
                    context.fill(Path(ellipseIn: dot), with: .color(Theme.gridDot))
                }
            }
        }
        .frame(width: CGFloat(columns) * cell, height: CGFloat(rows) * cell)
        .allowsHitTesting(false)
    }
}
