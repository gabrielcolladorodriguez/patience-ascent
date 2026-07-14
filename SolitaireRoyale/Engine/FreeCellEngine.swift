import Foundation

final class FreeCellEngine: BaseEngine {
    private(set) var tableau: [CardPile] = (0..<8).map { CardPile(id: "t\($0)", cards: []) }
    private(set) var freeCells: [CardPile] = (0..<4).map { CardPile(id: "fc\($0)", cards: []) }
    private(set) var foundations: [CardPile] = (0..<4).map { CardPile(id: "f\($0)", cards: []) }

    override init(mode: SolitaireMode = .freeCell) { super.init(mode: mode) }

    override var isWon: Bool { foundations.allSatisfy { $0.cards.count == 13 } }

    override func reset() {
        super.reset()
        var deck = DeckFactory.standardDeck()
        var index = 0
        tableau = (0..<8).map { i in
            let count = i < 4 ? 7 : 6
            let cards = (0..<count).map { _ -> PlayingCard in
                var c = deck[index]; index += 1; c.faceUp = true; return c
            }
            return CardPile(id: "t\(i)", cards: cards)
        }
        freeCells = (0..<4).map { CardPile(id: "fc\($0)", cards: []) }
        foundations = (0..<4).map { CardPile(id: "f\($0)", cards: []) }
    }

    override func pile(_ ref: PileRef) -> CardPile {
        switch ref.kind {
        case .tableau: return tableau[ref.index]
        case .foundation: return foundations[ref.index]
        case .freeCell: return freeCells[ref.index]
        default: return CardPile(id: "x", cards: [])
        }
    }

    override func allPileRefs() -> [PileRef] {
        var refs = (0..<8).map { PileRef(kind: .tableau, index: $0) }
        refs += (0..<4).map { PileRef(kind: .foundation, index: $0) }
        refs += (0..<4).map { PileRef(kind: .freeCell, index: $0) }
        return refs
    }

    private var emptyFreeCells: Int { freeCells.filter(\.isEmpty).count }
    private var emptyTableau: Int { tableau.filter(\.isEmpty).count }

    override func canMove(from: PileRef, to: PileRef) -> Bool {
        guard let moving = movableCards(from: from), let top = moving.first else { return false }
        if to.kind == .freeCell {
            return moving.count == 1 && freeCells[to.index].isEmpty
        }
        if to.kind == .foundation {
            guard moving.count == 1 else { return false }
            let dest = foundations[to.index]
            if dest.isEmpty { return top.rank == .ace }
            guard let dt = dest.top, dt.suit == top.suit else { return false }
            return top.rank.rawValue == dt.rank.rawValue + 1
        }
        if to.kind == .tableau {
            let dest = tableau[to.index]
            if dest.isEmpty {
                return top.rank == .king && maxMovable(from: from) >= moving.count
            }
            guard let dt = dest.top else { return false }
            return top.suit.isRed != dt.suit.isRed && top.rank.rawValue == dt.rank.rawValue - 1 && maxMovable(from: from) >= moving.count
        }
        return false
    }

    override func move(from: PileRef, to: PileRef) -> Bool {
        guard canMove(from: from, to: to), let cards = takeCards(from: from, count: movableCards(from: from)?.count ?? 0) else { return false }
        switch to.kind {
        case .freeCell: freeCells[to.index].push(cards)
        case .foundation: foundations[to.index].push(cards)
        case .tableau: tableau[to.index].push(cards)
        default: return false
        }
        moveHistory.append(CardMove(from: from, to: to, cards: cards, flippedCardID: nil))
        return true
    }

    override func hint() -> (from: PileRef, to: PileRef)? {
        for from in allPileRefs() {
            for to in allPileRefs() where from != to {
                if canMove(from: from, to: to) { return (from, to) }
            }
        }
        return nil
    }

    override func applyUndo(_ move: CardMove) {
        switch move.to.kind {
        case .freeCell: _ = freeCells[move.to.index].pop(count: move.cards.count)
        case .foundation: _ = foundations[move.to.index].pop(count: move.cards.count)
        case .tableau: _ = tableau[move.to.index].pop(count: move.cards.count)
        default: break
        }
        switch move.from.kind {
        case .tableau: tableau[move.from.index].push(move.cards)
        case .foundation: foundations[move.from.index].push(move.cards)
        case .freeCell: freeCells[move.from.index].push(move.cards)
        default: break
        }
    }

    private func maxMovable(from: PileRef) -> Int {
        let empty = emptyFreeCells + emptyTableau + (from.kind == .tableau && tableau[from.index].cards.count == movableCards(from: from)?.count ? 1 : 0)
        return (empty + 1) * (empty + 1)
    }

    private func movableCards(from: PileRef) -> [PlayingCard]? {
        switch from.kind {
        case .freeCell: return freeCells[from.index].top.map { [$0] }
        case .foundation: return foundations[from.index].top.map { [$0] }
        case .tableau:
            let pile = tableau[from.index]
            guard let top = pile.top else { return nil }
            var seq = [top]
            for i in stride(from: pile.cards.count - 2, through: 0, by: -1) {
                let a = pile.cards[i], b = pile.cards[i + 1]
                guard a.suit.isRed != b.suit.isRed, a.rank.rawValue == b.rank.rawValue + 1 else { break }
                seq.insert(a, at: 0)
            }
            return seq
        default: return nil
        }
    }

    private func takeCards(from: PileRef, count: Int) -> [PlayingCard]? {
        switch from.kind {
        case .freeCell: return freeCells[from.index].pop().map { [$0] }
        case .foundation: return foundations[from.index].pop().map { [$0] }
        case .tableau: return tableau[from.index].pop(count: count)
        default: return nil
        }
    }
}
