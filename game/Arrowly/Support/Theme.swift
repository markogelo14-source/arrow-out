import SwiftUI

enum Theme {
    static let background = Color(red: 1.000, green: 0.973, blue: 0.933)   // #FFF8EE
    static let board = Color(red: 0.961, green: 0.918, blue: 0.851)        // #F5EAD9
    static let gridDot = Color(red: 0.839, green: 0.780, blue: 0.690)
    static let ink = Color(red: 0.149, green: 0.137, blue: 0.231)          // #26233B
    static let secondaryInk = Color(red: 0.149, green: 0.137, blue: 0.231).opacity(0.6)
    static let indigo = Color(red: 0.310, green: 0.275, blue: 0.898)       // #4F46E5
    static let coral = Color(red: 0.976, green: 0.451, blue: 0.384)        // #F97362
    static let danger = Color(red: 0.902, green: 0.224, blue: 0.275)

    /// Piece colors, indexed by `Piece.colorIndex`. Keep in step with `LevelGenerator.paletteSize`.
    static let pieceColors: [Color] = [
        indigo,
        coral,
        Color(red: 0.078, green: 0.663, blue: 0.627),   // teal
        Color(red: 0.961, green: 0.651, blue: 0.137),   // amber
        Color(red: 0.851, green: 0.333, blue: 0.627),   // pink
        Color(red: 0.235, green: 0.639, blue: 0.341),   // green
    ]

    static func color(for piece: Piece) -> Color {
        pieceColors[piece.colorIndex % pieceColors.count]
    }
}

/// Links shown in Settings. Replace with the real pages once the website is live.
enum AppLinks {
    static let privacyPolicy = URL(string: "https://example.com/arrowly/privacy")!
    static let support = URL(string: "https://example.com/arrowly/support")!
}
