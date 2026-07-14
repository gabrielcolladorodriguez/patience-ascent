import Foundation

final class TriPeaksEngine: BaseEngine {
    private(set) var peaks: [PlayingCard?] = Array(repeating: nil, count: 28)
    private(set) var stock = CardPile(id: "stock", cards: [])
    private(set) var waste = CardPile(id: "waste", cards: [])

    // Layout indices 0-27 in 3 peaks (rows 0-8)
    private let layoutRows = [1, 2, 3, 4, 5, 6, 3, 2, 1]

    override init(mode: SolitaireMode = .triPeaks) { super.init(mode: mode) }

    override var isWon: Bool { peaks.allSatisfy { $0 == nil } }

    override func reset() {
        super.reset()
        var deck = DeckFactory.standardDeck()
        peaks = (0..<28).map { _ in var c = deck.removeFirst(); c.faceUp = true; return c }
        stock = CardPile(id: "stock", cards: deck.map { var c = $0; c.faceUp = false; return c })
        waste = CardPile(id: "waste", cards: [])
    }

    override func pile(_ ref: PileRef) -> CardPile {
        if ref.kind == .stock { return stock }
        if ref.kind == .waste { return waste }
        return CardPile(id: "peak", cards: peaks.compactMap { $0 })
    }

    override func allPileRefs() -> [PileRef] {
        var refs = (0..<28).compactMap { peaks[$0] != nil ? PileRef(kind: .tableau, index: $0) : nil }
        refs += [PileRef(kind: .stock, index: 0), PileRef(kind: .waste, index: 0)]
        return refs
    }

    private func neighborsBelow(_ index: Int) -> [Int] {
        // Simplified tri-peaks adjacency for 28-card layout
        let map: [Int: [Int]] = [
            0: [3, 4], 1: [4, 5], 2: [5, 6],
            3: [7, 8], 4: [8, 9], 5: [9, 10], 6: [10, 11],
            7: [12, 13], 8: [13, 14], 9: [14, 15], 10: [15, 16], 11: [16, 17],
            12: [18, 19], 13: [19, 20], 14: [20, 21], 15: [21, 22], 16: [22, 23], 17: [23, 24],
            18: [25], 19: [25, 26], 20: [26, 27], 21: [27], 22: [27], 23: [27], 24: [27]
        ]
        return map[index] ?? []
    }

    private func isExposed(_ index: Int) -> Bool {
        neighborsBelow(index).allSatisfy { peaks[$0] == nil }
    }

    private func wraps(_ a: Int, _ b: Int) -> Bool {
        abs(a - b) == 1 || (a == 1 && b == 13) || (a == 13 && b == 1)
    }

    override func drawFromStock() -> Bool {
        guard let card = stock.pop() else { return false }
        var c = card; c.faceUp = true
        waste = CardPile(id: "waste", cards: [c])
        moveHistory.append(CardMove(from: PileRef(kind: .stock, index: 0), to: PileRef(kind: .waste, index: 0), cards: [c], flippedCardID: nil))
        return true
    }

    override func canMove(from: PileRef, to: PileRef) -> Bool {
        guard from.kind == .tableau, to.kind == .waste else { return false }
        guard let card = peaks[from.index], isExposed(from.index), let w = waste.top else { return false }
        return wraps(card.value, w.value)
    }

    override func move(from: PileRef, to: PileRef) -> Bool {
        guard canMove(from: from, to: to), let card = peaks[from.index] else { return false }
        peaks[from.index] = nil
        waste = CardPile(id: "waste", cards: [card])
        moveHistory.append(CardMove(from: from, to: to, cards: [card], flippedCardID: nil))
        return true
    }

    override func hint() -> (from: PileRef, to: PileRef)? {
        guard let w = waste.top else {
            if !stock.isEmpty { return (PileRef(kind: .stock, index: 0), PileRef(kind: .waste, index: 0)) }
            return nil
        }
        for i in 0..<28 where peaks[i] != nil && isExposed(i) {
            if wraps(peaks[i]!.value, w.value) { return (PileRef(kind: .tableau, index: i), PileRef(kind: .waste, index: 0)) }
        }
        if !stock.isEmpty { return (PileRef(kind: .stock, index: 0), PileRef(kind: .waste, index: 0)) }
        return nil
    }

    override func applyUndo(_ move: CardMove) {
        if move.from.kind == .stock {
            stock.push(move.cards.map { var c = $0; c.faceUp = false; return c })
            waste = CardPile(id: "waste", cards: [])
            return
        }
        peaks[move.from.index] = move.cards.first
        // restore previous waste from prior history if needed - simplified: clear waste
        if let prev = moveHistory.dropLast().last?.cards.last {
            waste = CardPile(id: "waste", cards: [prev])
        } else {
            waste = CardPile(id: "waste", cards: [])
        }
    }
}
