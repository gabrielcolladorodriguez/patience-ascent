import Foundation

struct BlockCell: Equatable, Codable {
    let colorIndex: Int
}

struct BlockPiece: Equatable, Identifiable, Codable {
    let id: UUID
    let shapeId: Int
    let colorIndex: Int
    let cells: [GridPos]

    init(shapeId: Int, colorIndex: Int, cells: [GridPos], id: UUID = UUID()) {
        self.id = id
        self.shapeId = shapeId
        self.colorIndex = colorIndex
        self.cells = cells
    }
}

struct GravityBlockSnapshot: Codable {
    let grid: [[BlockCell?]]
    let tray: [BlockPiece?]
    let score: Int
    let combo: Int
    let wave: Int
    let totalLinesCleared: Int
}

struct LineClearResult: Equatable {
    let rows: Int
    let columns: Int
    let points: Int

    var total: Int { rows + columns }
}

/// Block-placement puzzle with column gravity after each move.
final class GravityBlockEngine {
    static let size = 8

    private(set) var grid: [[BlockCell?]]
    private(set) var tray: [BlockPiece?]
    private(set) var score = 0
    private(set) var combo = 0
    private(set) var wave = 1
    private(set) var totalLinesCleared = 0
    private(set) var lastClear = LineClearResult(rows: 0, columns: 0, points: 0)
    private(set) var isGameOver = false
    private(set) var moveHistory: [GravityBlockSnapshot] = []

    private var rng: SeededRNG

    init(seed: UInt64? = nil) {
        rng = SeededRNG(seed: seed ?? UInt64.random(in: 1...UInt64.max))
        grid = Array(repeating: Array(repeating: nil, count: Self.size), count: Self.size)
        tray = [nil, nil, nil]
        refillTray()
    }

    var waveMultiplier: Int { min(6, 1 + (wave - 1) / 2) }

    func canPlace(_ piece: BlockPiece, at anchor: GridPos) -> Bool {
        for cell in piece.cells {
            let r = anchor.row + cell.row
            let c = anchor.col + cell.col
            guard r >= 0, r < Self.size, c >= 0, c < Self.size else { return false }
            guard grid[r][c] == nil else { return false }
        }
        return true
    }

    func place(_ pieceIndex: Int, at anchor: GridPos) -> Bool {
        guard pieceIndex >= 0, pieceIndex < tray.count,
              let piece = tray[pieceIndex],
              canPlace(piece, at: anchor) else { return false }

        pushSnapshot()
        for cell in piece.cells {
            let r = anchor.row + cell.row
            let c = anchor.col + cell.col
            grid[r][c] = BlockCell(colorIndex: piece.colorIndex)
        }
        tray[pieceIndex] = nil

        score += piece.cells.count * 12 * waveMultiplier

        applyGravity()
        resolveClears()

        if tray.allSatisfy({ $0 == nil }) {
            refillTray()
        }

        if !hasAnyValidMove() {
            isGameOver = true
        }
        return true
    }

    func undo() -> Bool {
        guard let snap = moveHistory.popLast() else { return false }
        grid = snap.grid
        tray = snap.tray
        score = snap.score
        combo = snap.combo
        wave = snap.wave
        totalLinesCleared = snap.totalLinesCleared
        isGameOver = false
        lastClear = LineClearResult(rows: 0, columns: 0, points: 0)
        return true
    }

    func hasAnyValidMove() -> Bool {
        for piece in tray.compactMap({ $0 }) {
            for row in 0..<Self.size {
                for col in 0..<Self.size {
                    if canPlace(piece, at: GridPos(row: row, col: col)) {
                        return true
                    }
                }
            }
        }
        return false
    }

    private func pushSnapshot() {
        moveHistory.append(
            GravityBlockSnapshot(
                grid: grid, tray: tray, score: score, combo: combo,
                wave: wave, totalLinesCleared: totalLinesCleared
            )
        )
        if moveHistory.count > 50 { moveHistory.removeFirst() }
    }

    private func applyGravity() {
        for col in 0..<Self.size {
            var stack: [BlockCell] = []
            for row in 0..<Self.size {
                if let cell = grid[row][col] { stack.append(cell) }
            }
            for row in 0..<Self.size {
                let fillRow = Self.size - 1 - row
                grid[fillRow][col] = row < stack.count ? stack[stack.count - 1 - row] : nil
            }
        }
    }

    private func resolveClears() {
        var chain = 0
        var totalRows = 0
        var totalCols = 0
        var points = 0

        while true {
            let result = clearFullLines(chainStep: chain + 1)
            guard result.total > 0 else { break }

            chain += 1
            totalRows += result.rows
            totalCols += result.columns
            points += result.points
            applyGravity()
        }

        if chain > 0 {
            combo = chain
            lastClear = LineClearResult(rows: totalRows, columns: totalCols, points: points)
            totalLinesCleared += totalRows + totalCols
            while totalLinesCleared >= wave * 5 {
                wave += 1
            }
        } else {
            combo = 0
            lastClear = LineClearResult(rows: 0, columns: 0, points: 0)
        }
    }

    private func clearFullLines(chainStep: Int) -> LineClearResult {
        var toClear = Set<GridPos>()

        for row in 0..<Self.size {
            if grid[row].allSatisfy({ $0 != nil }) {
                for col in 0..<Self.size {
                    toClear.insert(GridPos(row: row, col: col))
                }
            }
        }
        for col in 0..<Self.size {
            if (0..<Self.size).allSatisfy({ grid[$0][col] != nil }) {
                for row in 0..<Self.size {
                    toClear.insert(GridPos(row: row, col: col))
                }
            }
        }

        guard !toClear.isEmpty else {
            return LineClearResult(rows: 0, columns: 0, points: 0)
        }

        var rowsCleared = 0
        var colsCleared = 0
        for row in 0..<Self.size {
            if grid[row].allSatisfy({ $0 != nil }) { rowsCleared += 1 }
        }
        for col in 0..<Self.size {
            if (0..<Self.size).allSatisfy({ grid[$0][col] != nil }) { colsCleared += 1 }
        }

        for pos in toClear {
            grid[pos.row][pos.col] = nil
        }

        let lines = rowsCleared + colsCleared
        var points = lines * 140 * waveMultiplier
        if chainStep > 1 { points = Int(Double(points) * (1.0 + Double(chainStep - 1) * 0.35)) }
        if lines >= 2 { points += 120 * lines }
        if lines >= 3 { points += 250 }
        score += points

        return LineClearResult(rows: rowsCleared, columns: colsCleared, points: points)
    }

    private func refillTray() {
        var pieces = (0..<3).map { _ in randomPiece() }
        if !pieces.contains(where: { piece in
            (0..<Self.size).contains { row in
                (0..<Self.size).contains { col in
                    canPlace(piece, at: GridPos(row: row, col: col))
                }
            }
        }) {
            pieces[0] = randomPiece(biasFit: true)
            if let second = shapesThatFit().randomElement(using: &rng) {
                pieces[1] = second
            }
        }
        for i in 0..<3 { tray[i] = pieces[i] }
    }

    private func shapesThatFit() -> [BlockPiece] {
        Self.shapeLibrary.compactMap { def in
            let piece = BlockPiece(
                shapeId: def.id, colorIndex: 0,
                cells: def.cells.map { GridPos(row: $0.0, col: $0.1) }
            )
            return fitsSomewhere(shapeId: def.id) ? piece : nil
        }
    }

    private func randomPiece(biasFit: Bool = false) -> BlockPiece {
        let shapes = Self.shapeLibrary
        let shape: ShapeDef
        if biasFit, let fit = shapes.first(where: { fitsSomewhere(shapeId: $0.id) }) {
            shape = fit
        } else {
            let idx = Int.random(in: 0..<shapes.count, using: &rng)
            shape = shapes[idx]
        }
        let color = Int.random(in: 0..<6, using: &rng)
        let cells = shape.cells.map { GridPos(row: $0.0, col: $0.1) }
        return BlockPiece(shapeId: shape.id, colorIndex: color, cells: cells)
    }

    private func fitsSomewhere(shapeId: Int) -> Bool {
        guard let def = Self.shapeLibrary.first(where: { $0.id == shapeId }) else { return false }
        let piece = BlockPiece(
            shapeId: shapeId, colorIndex: 0,
            cells: def.cells.map { GridPos(row: $0.0, col: $0.1) }
        )
        for row in 0..<Self.size {
            for col in 0..<Self.size {
                if canPlace(piece, at: GridPos(row: row, col: col)) { return true }
            }
        }
        return false
    }

    private struct ShapeDef {
        let id: Int
        let cells: [(Int, Int)]
    }

    private static let shapeLibrary: [ShapeDef] = [
        ShapeDef(id: 0, cells: [(0, 0)]),
        ShapeDef(id: 1, cells: [(0, 0), (0, 1)]),
        ShapeDef(id: 2, cells: [(0, 0), (1, 0)]),
        ShapeDef(id: 3, cells: [(0, 0), (0, 1), (0, 2)]),
        ShapeDef(id: 4, cells: [(0, 0), (1, 0), (2, 0)]),
        ShapeDef(id: 5, cells: [(0, 0), (0, 1), (1, 0)]),
        ShapeDef(id: 6, cells: [(0, 1), (0, 0), (1, 0)]),
        ShapeDef(id: 7, cells: [(0, 0), (0, 1), (1, 1)]),
        ShapeDef(id: 8, cells: [(0, 0), (1, 0), (1, 1)]),
        ShapeDef(id: 9, cells: [(0, 0), (0, 1), (1, 0), (1, 1)]),
        ShapeDef(id: 10, cells: [(0, 0), (0, 1), (0, 2), (1, 1)]),
        ShapeDef(id: 11, cells: [(0, 0), (1, 0), (1, 1), (2, 1)]),
        ShapeDef(id: 12, cells: [(0, 1), (1, 0), (1, 1), (2, 0)]),
        ShapeDef(id: 13, cells: [(0, 0), (0, 1), (1, 1), (1, 2)]),
        ShapeDef(id: 14, cells: [(0, 0), (0, 1), (0, 2), (0, 3)]),
        ShapeDef(id: 15, cells: [(0, 0), (0, 1), (1, 0), (1, 1), (2, 0)]),
    ]
}

extension Array {
    func randomElement(using rng: inout SeededRNG) -> Element? {
        guard !isEmpty else { return nil }
        return self[Int.random(in: 0..<count, using: &rng)]
    }
}
