import Foundation

final class PyramidEngine: BaseEngine {
    private(set) var pyramid: [PlayingCard?] = Array(repeating: nil, count: 28)
    private(set) var stock = CardPile(id: "stock", cards: [])
    private(set) var waste = CardPile(id: "waste", cards: [])

    override init(mode: SolitaireMode = .pyramid) { super.init(mode: mode) }

    override var isWon: Bool {
        pyramid.allSatisfy { $0 == nil } && stock.isEmpty && waste.isEmpty
    }

    override func reset() {
        super.reset()
        var deck = DeckFactory.standardDeck()
        pyramid = (0..<28).map { _ in
            var c = deck.removeFirst(); c.faceUp = true; return c
        }
        stock = CardPile(id: "stock", cards: deck.map { var c = $0; c.faceUp = false; return c })
        waste = CardPile(id: "waste", cards: [])
    }

    override func pile(_ ref: PileRef) -> CardPile {
        if ref.kind == .stock { return stock }
        if ref.kind == .waste { return waste }
        return CardPile(id: "pyr", cards: pyramid.compactMap { $0 })
    }

    override func allPileRefs() -> [PileRef] {
        var refs = (0..<28).compactMap { pyramid[$0] != nil ? PileRef(kind: .tableau, index: $0) : nil }
        refs += [PileRef(kind: .stock, index: 0), PileRef(kind: .waste, index: 0)]
        return refs
    }

    private func children(of index: Int) -> [Int] {
        let row = rowOf(index)
        let start = row * (row + 1) / 2
        if row >= 6 { return [] }
        let left = start + row + 1 + (index - start)
        return [left, left + 1]
    }

    private func rowOf(_ index: Int) -> Int {
        var n = 0, row = 0
        while n + row <= index { n += row; row += 1 }
        return row - 1
    }

    private func isExposed(_ index: Int) -> Bool {
        children(of: index).allSatisfy { pyramid[$0] == nil }
    }

    override func drawFromStock() -> Bool {
        guard let card = stock.pop() else { return false }
        var c = card; c.faceUp = true
        waste.push(c)
        moveHistory.append(CardMove(from: PileRef(kind: .stock, index: 0), to: PileRef(kind: .waste, index: 0), cards: [c], flippedCardID: nil))
        return true
    }

    override func canMove(from: PileRef, to: PileRef) -> Bool {
        if from.kind == .tableau && to.kind == .waste {
            guard let a = pyramid[from.index], isExposed(from.index), let b = waste.top else { return false }
            return a.value + b.value == 13
        }
        if from.kind == .tableau && to.kind == .tableau {
            guard let a = pyramid[from.index], let b = pyramid[to.index], from.index != to.index else { return false }
            guard isExposed(from.index), isExposed(to.index) else { return false }
            return a.value + b.value == 13
        }
        if from.kind == .waste && to.kind == .tableau {
            guard let b = pyramid[to.index], isExposed(to.index), let a = waste.top else { return false }
            return a.value + b.value == 13
        }
        return false
    }

    override func move(from: PileRef, to: PileRef) -> Bool {
        if from.kind == .tableau && to.kind == .waste {
            guard canMove(from: from, to: to), let a = pyramid[from.index], let b = waste.top else { return false }
            pyramid[from.index] = nil
            _ = waste.pop()
            moveHistory.append(CardMove(from: from, to: to, cards: [a, b], flippedCardID: nil))
            return true
        }
        if from.kind == .tableau && to.kind == .tableau {
            guard canMove(from: from, to: to), let a = pyramid[from.index], let b = pyramid[to.index] else { return false }
            pyramid[from.index] = nil
            pyramid[to.index] = nil
            moveHistory.append(CardMove(from: from, to: to, cards: [a, b], flippedCardID: nil))
            return true
        }
        if from.kind == .waste && to.kind == .tableau {
            guard canMove(from: from, to: to), let a = waste.top, let b = pyramid[to.index] else { return false }
            _ = waste.pop()
            pyramid[to.index] = nil
            moveHistory.append(CardMove(from: from, to: to, cards: [a, b], flippedCardID: nil))
            return true
        }
        return false
    }

    override func hint() -> (from: PileRef, to: PileRef)? {
        if let w = waste.top {
            for i in 0..<28 where pyramid[i] != nil && isExposed(i) {
                if pyramid[i]!.value + w.value == 13 { return (PileRef(kind: .tableau, index: i), PileRef(kind: .waste, index: 0)) }
            }
        }
        let exposed = (0..<28).filter { pyramid[$0] != nil && isExposed($0) }
        for i in exposed {
            for j in exposed where i < j {
                if pyramid[i]!.value + pyramid[j]!.value == 13 {
                    return (PileRef(kind: .tableau, index: i), PileRef(kind: .tableau, index: j))
                }
            }
        }
        if !stock.isEmpty { return (PileRef(kind: .stock, index: 0), PileRef(kind: .waste, index: 0)) }
        return nil
    }

    override func applyUndo(_ move: CardMove) {
        if move.cards.count == 2 {
            if move.from.kind == .tableau && move.to.kind == .waste {
                pyramid[move.from.index] = move.cards[0]
                waste.push(move.cards[1])
            } else if move.from.kind == .tableau && move.to.kind == .tableau {
                pyramid[move.from.index] = move.cards[0]
                pyramid[move.to.index] = move.cards[1]
            } else if move.from.kind == .waste && move.to.kind == .tableau {
                waste.push(move.cards[0])
                pyramid[move.to.index] = move.cards[1]
            }
        } else if move.from.kind == .stock {
            _ = waste.pop()
            stock.push(move.cards.map { var c = $0; c.faceUp = false; return c })
        }
    }
}
