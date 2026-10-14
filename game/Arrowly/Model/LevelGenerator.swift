import Foundation

/// The knobs that shape one generated board.
struct LevelSpec: Equatable, Sendable {
    var columns: Int
    var rows: Int
    /// Share of cells to fill with arrows, 0...1. The generator stops early if no arrow fits.
    var targetFill: Double
    /// Longest arrow, in cells (1...3).
    var maxLength: Int
    var seed: UInt64
}

enum LevelGenerator {
    /// Number of colors in the piece palette (see `Theme.pieceColors`).
    static let paletteSize = 6

    private static let sizes: [(Int, Int)] = [
        (4, 4), (4, 5), (5, 5), (5, 6), (6, 6), (6, 7),
        (6, 8), (7, 8), (7, 9), (8, 9), (8, 10),
    ]

    /// Levels per chapter on the level map. The board grows once per chapter.
    static let levelsPerChapter = 8

    /// Difficulty curve for the endless level list. Boards grow at the start of each chapter,
    /// reaching the largest size in chapter 11 (level 81). 3-cell arrows arrive in chapter 3.
    static func spec(forLevel level: Int) -> LevelSpec {
        let n = max(level, 1)
        let tier = min((n - 1) / levelsPerChapter, sizes.count - 1)
        let (columns, rows) = sizes[tier]
        let fill = min(0.62 + 0.025 * Double(tier), 0.88)
        let maxLength = n < 4 ? 1 : (n <= 2 * levelsPerChapter ? 2 : 3)
        return LevelSpec(
            columns: columns, rows: rows, targetFill: fill, maxLength: maxLength,
            seed: UInt64(n) &* 0x2545_F491_4F6C_DD1D &+ 0x1234_5678
        )
    }

    /// The Daily Puzzle: one larger board per calendar day, the same for everyone.
    static func dailySpec(for date: Date, calendar: Calendar = .current) -> LevelSpec {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        let key = (parts.year ?? 2026) * 10_000 + (parts.month ?? 1) * 100 + (parts.day ?? 1)
        return LevelSpec(
            columns: 7, rows: 9, targetFill: 0.85, maxLength: 3,
            seed: UInt64(key) &* 0x9E37_79B9_7F4A_7C15 &+ 0xDA11
        )
    }

    /// Builds a board that is always solvable.
    ///
    /// Arrows are placed one at a time in *reverse removal order*: each new arrow must have a
    /// clear path to the edge past the arrows already placed. The player removes them in the
    /// opposite order, so the last arrow placed is free first, and every earlier arrow is free
    /// once the later ones have gone. Placements that sit in the path of existing arrows are
    /// preferred, which creates chains of dependencies and makes the board a real puzzle.
    static func generate(_ spec: LevelSpec) -> Board {
        var rng = SeededGenerator(seed: spec.seed)
        let empty = Board(columns: spec.columns, rows: spec.rows, pieces: [])
        let totalCells = spec.columns * spec.rows
        let targetCells = Int((Double(totalCells) * spec.targetFill).rounded())

        var occupancy: [Cell: Int] = [:]
        var placed: [Piece] = []
        var filled = 0

        struct Candidate {
            let head: Cell
            let direction: Direction
            let length: Int
            let weight: Int
        }

        while filled < targetCells {
            // For each placed piece, the cells in front of it that it must travel through.
            var laneUse: [Cell: Int] = [:]
            for piece in placed {
                var cell = piece.head.moved(piece.direction)
                while empty.contains(cell) {
                    laneUse[cell, default: 0] += 1
                    cell = cell.moved(piece.direction)
                }
            }

            var candidates: [Candidate] = []
            for row in 0..<spec.rows {
                for col in 0..<spec.columns {
                    let head = Cell(col: col, row: row)
                    if occupancy[head] != nil { continue }
                    for direction in Direction.allCases {
                        guard let travel = clearTravel(from: head, direction, in: empty, occupancy: occupancy) else { continue }
                        for length in 1...max(1, spec.maxLength) {
                            let cells = (0..<length).map { head.moved(direction, by: -$0) }
                            guard cells.allSatisfy({ empty.contains($0) && occupancy[$0] == nil }) else { break }
                            // A piece that faces straight out of a full lane is boring; one that
                            // blocks other arrows is interesting.
                            let blocking = cells.reduce(0) { $0 + (laneUse[$1] ?? 0) }
                            // Arrows facing a long open lane can be blocked by later arrows, too.
                            let weight = 1 + blocking * blockWeight + travel * travelWeight + (length - 1) * 2
                            candidates.append(Candidate(head: head, direction: direction, length: length, weight: weight))
                        }
                    }
                }
            }

            guard !candidates.isEmpty else { break }

            let total = candidates.reduce(0) { $0 + $1.weight }
            var pick = Int.random(in: 0..<total, using: &rng)
            var chosen = candidates[0]
            for candidate in candidates {
                if pick < candidate.weight {
                    chosen = candidate
                    break
                }
                pick -= candidate.weight
            }

            let piece = Piece(
                id: placed.count,
                head: chosen.head,
                direction: chosen.direction,
                length: chosen.length,
                colorIndex: Int.random(in: 0..<paletteSize, using: &rng)
            )
            for cell in piece.cells { occupancy[cell] = piece.id }
            placed.append(piece)
            filled += piece.length
        }

        // Shuffle ids so the id order does not leak the solution order.
        var ids = Array(0..<placed.count)
        ids.shuffle(using: &rng)
        let pieces = placed.enumerated().map { index, piece in
            Piece(id: ids[index], head: piece.head, direction: piece.direction,
                  length: piece.length, colorIndex: piece.colorIndex)
        }
        return Board(columns: spec.columns, rows: spec.rows, pieces: pieces)
    }

    /// Placement weights, tuned so roughly half the arrows are blocked at the start.
    private static let blockWeight = 12
    private static let travelWeight = 3

    /// Number of free cells between `head` and the edge, or nil if something is in the way.
    private static func clearTravel(from head: Cell, _ direction: Direction, in board: Board, occupancy: [Cell: Int]) -> Int? {
        var cell = head.moved(direction)
        var steps = 0
        while board.contains(cell) {
            if occupancy[cell] != nil { return nil }
            steps += 1
            cell = cell.moved(direction)
        }
        return steps
    }
}
