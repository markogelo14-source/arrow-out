import SwiftUI

/// A white arrow glyph drawn inside a piece's frame, pointing in `direction`.
/// The frame is `length` cells long along the direction and one cell across.
struct ArrowShape: Shape {
    var direction: Direction
    var length: Int

    func path(in rect: CGRect) -> Path {
        let horizontal = direction == .left || direction == .right
        let cell = horizontal ? rect.height : rect.width
        let len = CGFloat(length)

        // Points are given as (u, v) in cells: u runs from tail to tip, v across the piece.
        func point(_ u: CGFloat, _ v: CGFloat) -> CGPoint {
            let local: CGPoint
            switch direction {
            case .right: local = CGPoint(x: u, y: v)
            case .left: local = CGPoint(x: len - u, y: v)
            case .down: local = CGPoint(x: v, y: u)
            case .up: local = CGPoint(x: v, y: len - u)
            }
            return CGPoint(x: rect.minX + local.x * cell, y: rect.minY + local.y * cell)
        }

        var path = Path()

        // Shaft.
        let shaftStart: CGFloat = 0.28
        let shaftEnd = len - 0.42
        let half: CGFloat = 0.075
        if shaftEnd > shaftStart {
            path.move(to: point(shaftStart, 0.5 - half))
            path.addLine(to: point(shaftEnd, 0.5 - half))
            path.addLine(to: point(shaftEnd, 0.5 + half))
            path.addLine(to: point(shaftStart, 0.5 + half))
            path.closeSubpath()
        }

        // Head.
        path.move(to: point(len - 0.2, 0.5))
        path.addLine(to: point(len - 0.52, 0.24))
        path.addLine(to: point(len - 0.52, 0.76))
        path.closeSubpath()

        return path
    }
}
