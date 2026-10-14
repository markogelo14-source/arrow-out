import XCTest
@testable import ArrowlyCore

final class GeneratorTests: XCTestCase {
    func testEveryLevelIsSolvableAndFilled() {
        for level in 1...300 {
            let spec = LevelGenerator.spec(forLevel: level)
            let board = LevelGenerator.generate(spec)
            XCTAssertTrue(board.isSolvable(), "level \(level) is not solvable")
            let cells = board.pieces.reduce(0) { $0 + $1.length }
            let fill = Double(cells) / Double(spec.columns * spec.rows)
            XCTAssertGreaterThan(fill, 0.45, "level \(level) too empty (\(fill))")
            // No two pieces overlap and all are inside the board.
            var seen = Set<Cell>()
            for piece in board.pieces {
                XCTAssertLessThanOrEqual(piece.length, spec.maxLength)
                for cell in piece.cells {
                    XCTAssertTrue(board.contains(cell))
                    XCTAssertTrue(seen.insert(cell).inserted, "overlap on level \(level)")
                }
            }
        }
    }

    func testBoardsGrowOncePerChapter() {
        for chapter in 0..<10 {
            let first = LevelGenerator.spec(forLevel: chapter * 8 + 1)
            let last = LevelGenerator.spec(forLevel: chapter * 8 + 8)
            XCTAssertEqual(first.columns, last.columns, "chapter \(chapter + 1) changes width")
            XCTAssertEqual(first.rows, last.rows, "chapter \(chapter + 1) changes height")
        }
        let largest = LevelGenerator.spec(forLevel: 81)
        XCTAssertEqual([largest.columns, largest.rows], [8, 10])
        XCTAssertLessThan(LevelGenerator.spec(forLevel: 80).columns * LevelGenerator.spec(forLevel: 80).rows, 80)
        XCTAssertEqual(LevelGenerator.spec(forLevel: 16).maxLength, 2)
        XCTAssertEqual(LevelGenerator.spec(forLevel: 17).maxLength, 3)
    }

    func testGenerationIsDeterministic() {
        let a = LevelGenerator.generate(LevelGenerator.spec(forLevel: 42))
        let b = LevelGenerator.generate(LevelGenerator.spec(forLevel: 42))
        XCTAssertEqual(a.pieces, b.pieces)
        let c = LevelGenerator.generate(LevelGenerator.spec(forLevel: 43))
        XCTAssertNotEqual(a.pieces, c.pieces)
    }

    func testDailyPuzzleIsSolvable() {
        var date = Date(timeIntervalSince1970: 1_790_000_000)
        for _ in 0..<60 {
            let board = LevelGenerator.generate(LevelGenerator.dailySpec(for: date))
            XCTAssertTrue(board.isSolvable())
            date.addTimeInterval(86_400)
        }
    }

    func testDailyPuzzleNumbers() {
        XCTAssertEqual(DayKey.puzzleNumber(for: DayKey.firstDaily), 1)
        XCTAssertEqual(DayKey.puzzleNumber(for: DayKey.key(-11, daysBefore: DayKey.firstDaily)!), 12)
        XCTAssertEqual(DayKey.puzzleNumber(for: DayKey.key(-400, daysBefore: DayKey.firstDaily)!), 401)
        XCTAssertNil(DayKey.puzzleNumber(for: DayKey.key(1, daysBefore: DayKey.firstDaily)!))
        XCTAssertNil(DayKey.puzzleNumber(for: "not a day"))
    }

    func testBlockedAndEscapingMoves() {
        // A points right into B; B points up and is free.
        let a = Piece(id: 0, head: Cell(col: 0, row: 1), direction: .right, length: 1, colorIndex: 0)
        let b = Piece(id: 1, head: Cell(col: 2, row: 1), direction: .up, length: 2, colorIndex: 0)
        var board = Board(columns: 3, rows: 3, pieces: [a, b])
        XCTAssertEqual(board.result(for: a), .blocked(blockerID: 1, freeSteps: 1))
        XCTAssertEqual(board.result(for: b), .escapes(distance: 1))
        board.remove(id: 1)
        XCTAssertEqual(board.result(for: a), .escapes(distance: 2))
        XCTAssertEqual(b.cells, [Cell(col: 2, row: 1), Cell(col: 2, row: 2)])
    }

    func testDeadlockIsDetected() {
        let a = Piece(id: 0, head: Cell(col: 0, row: 0), direction: .right, length: 1, colorIndex: 0)
        let b = Piece(id: 1, head: Cell(col: 2, row: 0), direction: .left, length: 1, colorIndex: 0)
        XCTAssertFalse(Board(columns: 3, rows: 1, pieces: [a, b]).isSolvable())
    }

    /// Prints how puzzle-like the curve is: how many arrows are free at the start.
    func testPrintDifficultyCurve() {
        for level in [1, 8, 9, 17, 25, 41, 60, 81, 100] {
            let spec = LevelGenerator.spec(forLevel: level)
            let board = LevelGenerator.generate(spec)
            let free = board.escapablePieces().count
            print("level \(level): \(spec.columns)x\(spec.rows) pieces=\(board.pieces.count) freeAtStart=\(free)")
        }
    }
}
