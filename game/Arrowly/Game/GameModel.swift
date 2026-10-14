import SwiftUI
import Observation

/// Runs one board: taps, animations, hearts, hints and the win / lose result.
@MainActor
@Observable
final class GameModel {
    enum Phase: Equatable {
        case playing, won, lost
    }

    static let maxHearts = 3
    static let maxHints = 3

    private(set) var mode: GameMode
    private(set) var board: Board
    private(set) var phase: Phase = .playing
    private(set) var hearts = GameModel.maxHearts
    private(set) var hintsLeft = GameModel.maxHints
    private(set) var hintedID: Int?
    private(set) var flashingID: Int?
    /// Arrows on the board when it was dealt, for the progress bar.
    private(set) var totalPieces = 0
    /// Seconds from the deal to the last arrow leaving, set when the board is won.
    private(set) var finishTime: TimeInterval = 0
    private var startedAt = Date()

    /// Pieces that already left the board logically but are still flying off screen.
    private(set) var leaving: [Piece] = []
    /// How far each piece is drawn from its resting place, in cells along its direction.
    private(set) var offsets: [Int: Double] = [:]
    /// Pieces mid-bump, which ignore taps until they settle.
    private var bumping: Set<Int> = []

    private var generation = 0

    init(mode: GameMode) {
        self.mode = mode
        board = LevelGenerator.generate(mode.spec)
        totalPieces = board.pieces.count
    }

    /// Everything to draw: pieces on the board plus pieces flying away.
    var visiblePieces: [Piece] { board.pieces + leaving }

    var piecesLeft: Int { board.pieces.count }

    /// Share of the board cleared, 0...1.
    var progress: Double {
        totalPieces == 0 ? 1 : Double(totalPieces - piecesLeft) / Double(totalPieces)
    }

    var hintsUsed: Int { Self.maxHints - hintsLeft }

    /// What VoiceOver reads for an arrow: "Coral arrow, 2 cells long, pointing up, tip at row 3,
    /// column 4". It never says whether the arrow can escape; that is what hints are for.
    func accessibilityDescription(of piece: Piece) -> String {
        let color = Theme.pieceColorNames[piece.colorIndex % Theme.pieceColorNames.count]
        let length = piece.length == 1 ? "1 cell" : "\(piece.length) cells long"
        let direction = switch piece.direction {
        case .up: "up"
        case .right: "right"
        case .down: "down"
        case .left: "left"
        }
        return "\(color) arrow, \(length), pointing \(direction), tip at row \(piece.head.row + 1), column \(piece.head.col + 1)"
    }

    func isLeaving(_ id: Int) -> Bool {
        leaving.contains { $0.id == id }
    }

    func load(_ newMode: GameMode) {
        mode = newMode
        restart()
    }

    func restart() {
        generation += 1
        board = LevelGenerator.generate(mode.spec)
        totalPieces = board.pieces.count
        startedAt = Date()
        finishTime = 0
        phase = .playing
        hearts = Self.maxHearts
        hintsLeft = Self.maxHints
        hintedID = nil
        flashingID = nil
        leaving = []
        offsets = [:]
        bumping = []
    }

    func tap(_ id: Int) {
        guard phase == .playing, !bumping.contains(id), let piece = board.piece(withID: id) else { return }
        if hintedID == id { hintedID = nil }

        switch board.result(for: piece) {
        case .escapes(let distance):
            escape(piece, distance: distance)
        case .blocked(let blockerID, let freeSteps):
            bump(piece, into: blockerID, freeSteps: freeSteps)
        }
    }

    func useHint() {
        guard phase == .playing, hintsLeft > 0, hintedID == nil else { return }
        guard let piece = board.escapablePieces().randomElement() else { return }
        hintsLeft -= 1
        hintedID = piece.id
        Haptics.tap()
        announce("Hint: \(accessibilityDescription(of: piece))")
    }

    // MARK: - Moves

    private var reduceMotion: Bool { UIAccessibility.isReduceMotionEnabled }

    /// Speaks a short update to VoiceOver users; does nothing otherwise.
    private func announce(_ message: String) {
        guard UIAccessibility.isVoiceOverRunning else { return }
        AccessibilityNotification.Announcement(message).post()
    }

    private func escape(_ piece: Piece, distance: Int) {
        let token = generation
        board.remove(id: piece.id)
        Haptics.tap()
        Sound.tap()

        // With Reduce Motion the arrow fades out in place instead of sliding off.
        let travel = reduceMotion ? 0 : Double(distance + piece.length + 2)
        withAnimation(.easeIn(duration: reduceMotion ? 0.2 : 0.32)) {
            leaving.append(piece)
            offsets[piece.id] = travel
        }

        let cleared = board.isCleared
        if cleared { finishTime = Date().timeIntervalSince(startedAt) }
        announce(cleared ? "Board cleared" : (piecesLeft == 1 ? "1 arrow left" : "\(piecesLeft) arrows left"))
        Task {
            try? await Task.sleep(for: .milliseconds(340))
            guard token == generation else { return }
            leaving.removeAll { $0.id == piece.id }
            offsets[piece.id] = nil
            if cleared {
                Haptics.win()
                Sound.win()
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) { phase = .won }
            }
        }
    }

    private func bump(_ piece: Piece, into blockerID: Int, freeSteps: Int) {
        let token = generation
        bumping.insert(piece.id)
        hearts -= 1
        Haptics.blocked()
        Sound.blocked()

        withAnimation(.easeOut(duration: 0.12)) {
            if !reduceMotion { offsets[piece.id] = Double(freeSteps) + 0.18 }
            flashingID = blockerID
        }

        let outOfHearts = hearts <= 0
        if let blocker = board.piece(withID: blockerID) {
            let left = outOfHearts ? "Out of hearts" : (hearts == 1 ? "1 heart left" : "\(hearts) hearts left")
            announce("Blocked by \(Theme.pieceColorNames[blocker.colorIndex % Theme.pieceColorNames.count].lowercased()) arrow. \(left)")
        }
        Task {
            try? await Task.sleep(for: .milliseconds(130))
            guard token == generation else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
                offsets[piece.id] = 0
            }
            try? await Task.sleep(for: .milliseconds(320))
            guard token == generation else { return }
            bumping.remove(piece.id)
            offsets[piece.id] = nil
            withAnimation(.easeOut(duration: 0.2)) {
                if flashingID == blockerID { flashingID = nil }
            }
            if outOfHearts {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) { phase = .lost }
            }
        }
    }
}
