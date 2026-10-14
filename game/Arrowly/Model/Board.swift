import Foundation

/// One of the four directions an arrow can point.
enum Direction: Int, CaseIterable, Codable, Sendable {
    case up, right, down, left

    /// Column step when moving one cell in this direction.
    var dx: Int {
        switch self {
        case .up, .down: return 0
        case .right: return 1
        case .left: return -1
        }
    }

    /// Row step when moving one cell in this direction. Row 0 is the top row.
    var dy: Int {
        switch self {
        case .left, .right: return 0
        case .down: return 1
        case .up: return -1
        }
    }
}

/// A square on the board.
struct Cell: Hashable, Codable, Sendable {
    var col: Int
    var row: Int

    func moved(_ direction: Direction, by steps: Int = 1) -> Cell {
        Cell(col: col + direction.dx * steps, row: row + direction.dy * steps)
    }
}

/// A straight arrow that is 1 to 3 cells long. The head is the cell the arrow tip sits in;
/// the tail extends behind it, opposite to the direction it points.
struct Piece: Identifiable, Hashable, Codable, Sendable {
    let id: Int
    let head: Cell
    let direction: Direction
    let length: Int
    let colorIndex: Int

    /// Cells covered by the piece, head first.
    var cells: [Cell] {
        (0..<length).map { head.moved(direction, by: -$0) }
    }

    /// The tail end (the cell farthest from the tip).
    var tail: Cell { head.moved(direction, by: -(length - 1)) }
}

/// What happens when a piece is tapped.
enum MoveResult: Equatable, Sendable {
    /// The piece has a clear path and leaves the board. `distance` is how many cells the
    /// head travels before it crosses the edge.
    case escapes(distance: Int)
    /// The piece is stopped by `blockerID` after moving `freeSteps` cells.
    case blocked(blockerID: Int, freeSteps: Int)
}

/// The state of a puzzle: its size and the pieces still on it.
struct Board: Codable, Sendable {
    let columns: Int
    let rows: Int
    private(set) var pieces: [Piece]

    init(columns: Int, rows: Int, pieces: [Piece]) {
        self.columns = columns
        self.rows = rows
        self.pieces = pieces
    }

    var isCleared: Bool { pieces.isEmpty }

    func contains(_ cell: Cell) -> Bool {
        cell.col >= 0 && cell.col < columns && cell.row >= 0 && cell.row < rows
    }

    func piece(withID id: Int) -> Piece? {
        pieces.first { $0.id == id }
    }

    /// Maps every occupied cell to the id of the piece covering it.
    func occupancy() -> [Cell: Int] {
        var map: [Cell: Int] = [:]
        for piece in pieces {
            for cell in piece.cells { map[cell] = piece.id }
        }
        return map
    }

    /// Works out whether `piece` can slide off the board or what stops it.
    func result(for piece: Piece, occupancy: [Cell: Int]? = nil) -> MoveResult {
        let map = occupancy ?? self.occupancy()
        var cell = piece.head.moved(piece.direction)
        var steps = 0
        while contains(cell) {
            if let other = map[cell], other != piece.id {
                return .blocked(blockerID: other, freeSteps: steps)
            }
            steps += 1
            cell = cell.moved(piece.direction)
        }
        return .escapes(distance: steps)
    }

    func canEscape(_ piece: Piece) -> Bool {
        if case .escapes = result(for: piece) { return true }
        return false
    }

    /// Pieces that could be tapped away right now.
    func escapablePieces() -> [Piece] {
        let map = occupancy()
        return pieces.filter {
            if case .escapes = result(for: $0, occupancy: map) { return true }
            return false
        }
    }

    /// Removes a piece from the board (after it escaped).
    mutating func remove(id: Int) {
        pieces.removeAll { $0.id == id }
    }

    /// True when every piece can eventually be removed. Removing a piece only ever frees
    /// space, so greedily removing any escapable piece is a complete check.
    func isSolvable() -> Bool {
        var board = self
        while !board.isCleared {
            guard let next = board.escapablePieces().first else { return false }
            board.remove(id: next.id)
        }
        return true
    }
}
