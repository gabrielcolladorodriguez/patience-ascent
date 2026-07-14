import Foundation

struct GlyphLinkSnapshot: Codable {
    let cells: [PuzzleCell?]
    let moves: Int
}

/// Connect matching tiles with paths of at most two turns (portrait puzzle).
final class GlyphLinkEngine {
    static let rows = 8
    static let cols = 6

    private(set) var cells: [PuzzleCell?]
    private(set) var moveHistory: [GlyphLinkSnapshot] = []
    private var rng: SeededRNG

    private let autoReshuffle: Bool
    private let matchStyle: PuzzleMatchStyle
    private let sumTarget: Int
    private let levelConfig: LevelConfig

    var isWon: Bool { cells.allSatisfy { $0 == nil } }
    var canUndo: Bool { !moveHistory.isEmpty }

    init(mode: SolitaireMode, levelConfig: LevelConfig? = nil, seed: UInt64? = nil) {
        let config = levelConfig ?? mode.levelConfig()
        self.levelConfig = config
        autoReshuffle = mode.rules(level: config.level).autoReshuffle
        matchStyle = mode.matchStyle
        sumTarget = mode.rules(level: config.level).sumTarget
        rng = SeededRNG(seed: seed ?? UInt64.random(in: 1...UInt64.max))
        cells = Array(repeating: nil, count: Self.rows * Self.cols)
        reset(config: config)
    }

    func reset(config: LevelConfig) {
        moveHistory.removeAll()
        var bag = PuzzleCellFactory.board(for: config.mode, config: config, rng: &rng)
        while bag.count < Self.rows * Self.cols {
            bag.append(contentsOf: PuzzleCellFactory.board(for: config.mode, config: config, rng: &rng))
        }
        cells = bag.prefix(Self.rows * Self.cols).map { Optional.some($0) }
        if !hasAnyMatch() {
            reshuffleRemaining()
        }
    }

    func reset(mode: SolitaireMode) {
        reset(config: levelConfig)
    }

    func cell(at pos: GridPos) -> PuzzleCell? {
        guard isInside(pos) else { return nil }
        return cells[index(pos)]
    }

    func tap(_ pos: GridPos) -> GlyphLinkMatchResult {
        guard let tile = cell(at: pos) else { return .ignored }

        if let first = pendingFirst {
            if first == pos {
                pendingFirst = nil
                return .deselected
            }
            if let other = cell(at: first), tilesMatch(tile, other), canConnect(from: first, to: pos) {
                pendingFirst = nil
                return removePair(first, pos)
            }
            pendingFirst = pos
            return .selected(pos)
        }

        pendingFirst = pos
        return .selected(pos)
    }

    private var pendingFirst: GridPos?

    func undo() -> Bool {
        guard let snap = moveHistory.popLast() else { return false }
        cells = snap.cells
        pendingFirst = nil
        return true
    }

    func hint() -> (GridPos, GridPos)? { findAnyMatch() }

    func reshuffleRemaining() {
        var tiles: [PuzzleCell] = cells.compactMap { $0 }
        guard tiles.count >= 2 else { return }
        tiles.shuffle(using: &rng)
        var i = 0
        for idx in cells.indices where cells[idx] != nil {
            cells[idx] = tiles[i]
            i += 1
        }
        pendingFirst = nil
    }

    func hasAnyMatch() -> Bool { findAnyMatch() != nil }

    private func tilesMatch(_ a: PuzzleCell, _ b: PuzzleCell) -> Bool {
        a.matches(b, style: matchStyle, sumTarget: sumTarget)
    }

    private func removePair(_ a: GridPos, _ b: GridPos) -> GlyphLinkMatchResult {
        let snap = GlyphLinkSnapshot(cells: cells, moves: moveHistory.count)
        moveHistory.append(snap)
        cells[index(a)] = nil
        cells[index(b)] = nil
        applyGravity()
        let won = isWon
        if !won && !hasAnyMatch() && autoReshuffle {
            reshuffleRemaining()
        }
        return .matched(a, b, won: won)
    }

    private func applyGravity() {
        for col in 0..<Self.cols {
            var stack: [PuzzleCell] = []
            for row in 0..<Self.rows {
                if let g = cells[index(GridPos(row: row, col: col))] {
                    stack.append(g)
                }
            }
            for row in 0..<Self.rows {
                let idx = index(GridPos(row: row, col: col))
                let offset = row - (Self.rows - stack.count)
                cells[idx] = offset >= 0 ? stack[offset] : nil
            }
        }
    }

    func canConnect(from a: GridPos, to b: GridPos) -> Bool {
        guard a != b, let tileA = cell(at: a), let tileB = cell(at: b), tilesMatch(tileA, tileB) else { return false }
        if lineClear(from: a, to: b) { return true }

        let corner1 = GridPos(row: a.row, col: b.col)
        let skip = Set([a, b])
        if isPassable(corner1, excluding: skip),
           lineClear(from: a, to: corner1),
           lineClear(from: corner1, to: b) {
            return true
        }

        let corner2 = GridPos(row: b.row, col: a.col)
        if isPassable(corner2, excluding: skip),
           lineClear(from: a, to: corner2),
           lineClear(from: corner2, to: b) {
            return true
        }

        for row in -1...Self.rows {
            let pivotA = GridPos(row: row, col: a.col)
            let pivotB = GridPos(row: row, col: b.col)
            if isPassable(pivotA, excluding: skip),
               isPassable(pivotB, excluding: skip),
               lineClear(from: a, to: pivotA),
               lineClear(from: pivotA, to: pivotB),
               lineClear(from: pivotB, to: b) {
                return true
            }
        }

        for col in -1...Self.cols {
            let pivotA = GridPos(row: a.row, col: col)
            let pivotB = GridPos(row: b.row, col: col)
            if isPassable(pivotA, excluding: skip),
               isPassable(pivotB, excluding: skip),
               lineClear(from: a, to: pivotA),
               lineClear(from: pivotA, to: pivotB),
               lineClear(from: pivotB, to: b) {
                return true
            }
        }

        return false
    }

    private func findAnyMatch() -> (GridPos, GridPos)? {
        var occupied: [GridPos] = []
        for row in 0..<Self.rows {
            for col in 0..<Self.cols {
                let pos = GridPos(row: row, col: col)
                if cell(at: pos) != nil { occupied.append(pos) }
            }
        }
        for i in 0..<occupied.count {
            for j in (i + 1)..<occupied.count {
                let a = occupied[i], b = occupied[j]
                if let tileA = cell(at: a), let tileB = cell(at: b),
                   tilesMatch(tileA, tileB), canConnect(from: a, to: b) {
                    return (a, b)
                }
            }
        }
        return nil
    }

    private func isInside(_ pos: GridPos) -> Bool {
        pos.row >= 0 && pos.row < Self.rows && pos.col >= 0 && pos.col < Self.cols
    }

    private func index(_ pos: GridPos) -> Int { pos.row * Self.cols + pos.col }

    private func isPassable(_ pos: GridPos, excluding: Set<GridPos> = []) -> Bool {
        if excluding.contains(pos) { return true }
        if !isInside(pos) { return true }
        return cells[index(pos)] == nil
    }

    private func lineClear(from a: GridPos, to b: GridPos) -> Bool {
        let skip = Set([a, b])
        if a.row == b.row {
            let minC = min(a.col, b.col) + 1
            let maxC = max(a.col, b.col) - 1
            if minC > maxC { return true }
            for col in minC...maxC where !isPassable(GridPos(row: a.row, col: col), excluding: skip) {
                return false
            }
            return true
        }
        if a.col == b.col {
            let minR = min(a.row, b.row) + 1
            let maxR = max(a.row, b.row) - 1
            if minR > maxR { return true }
            for row in minR...maxR where !isPassable(GridPos(row: row, col: a.col), excluding: skip) {
                return false
            }
            return true
        }
        return false
    }
}

enum GlyphLinkMatchResult: Equatable {
    case ignored
    case deselected
    case selected(GridPos)
    case matched(GridPos, GridPos, won: Bool)
}

struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0xDEAD_BEEF_CAFE_BABE : seed
    }

    mutating func next() -> UInt64 {
        state &*= 6_364_136_223_847_093_763
        state &+= 1
        return state
    }
}
