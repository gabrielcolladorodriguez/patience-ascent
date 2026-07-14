import Foundation

final class YukonEngine: BaseEngine {
    private(set) var tableau: [CardPile] = (0..<7).map { CardPile(id: "t\($0)", cards: []) }
    private(set) var foundations: [CardPile] = (0..<4).map { CardPile(id: "f\($0)", cards: []) }

    override init(mode: SolitaireMode = .yukon) { super.init(mode: mode) }

    override var isWon: Bool { foundations.allSatisfy { $0.cards.count == 13 } }

    override func reset() {
        super.reset()
        var deck = DeckFactory.standardDeck()
        tableau = (0..<7).map { col in
            var pile: [PlayingCard] = []
            for _ in 0...col {
                var c = deck.removeFirst()
                c.faceUp = true
                pile.append(c)
            }
            return CardPile(id: "t\(col)", cards: pile)
        }
        for col in 1..<7 {
            for _ in 0..<4 {
                var c = deck.removeFirst()
                c.faceUp = true
                tableau[col].cards.append(c)
            }
        }
        foundations = (0..<4).map { CardPile(id: "f\($0)", cards: []) }
    }

    override func pile(_ ref: PileRef) -> CardPile {
        switch ref.kind {
        case .tableau: return tableau[ref.index]
        case .foundation: return foundations[ref.index]
        default: return CardPile(id: "x", cards: [])
        }
    }

    override func allPileRefs() -> [PileRef] {
        (0..<7).map { PileRef(kind: .tableau, index: $0) } + (0..<4).map { PileRef(kind: .foundation, index: $0) }
    }

    override func canMove(from: PileRef, to: PileRef) -> Bool {
        guard let moving = movableCards(from: from), let top = moving.first else { return false }
        if to.kind == .foundation {
            guard moving.count == 1 else { return false }
            let dest = foundations[to.index]
            if dest.isEmpty { return top.rank == .ace }
            guard let dt = dest.top, dt.suit == top.suit else { return false }
            return top.rank.rawValue == dt.rank.rawValue + 1
        }
        if to.kind == .tableau {
            let dest = tableau[to.index]
            if dest.isEmpty { return top.rank == .king }
            guard let dt = dest.top else { return false }
            return top.suit.isRed != dt.suit.isRed && top.rank.rawValue == dt.rank.rawValue - 1
        }
        return false
    }

    override func move(from: PileRef, to: PileRef) -> Bool {
        guard canMove(from: from, to: to), let cards = takeCards(from: from) else { return false }
        switch to.kind {
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
        case .foundation: _ = foundations[move.to.index].pop(count: move.cards.count)
        case .tableau: _ = tableau[move.to.index].pop(count: move.cards.count)
        default: break
        }
        switch move.from.kind {
        case .tableau: tableau[move.from.index].push(move.cards)
        case .foundation: foundations[move.from.index].push(move.cards)
        default: break
        }
    }

    private func movableCards(from: PileRef) -> [PlayingCard]? {
        switch from.kind {
        case .foundation: return foundations[from.index].top.map { [$0] }
        case .tableau:
            let pile = tableau[from.index]
            guard let start = pile.cards.firstIndex(where: { $0.faceUp }) else { return nil }
            return Array(pile.cards[start...])
        default: return nil
        }
    }

    private func takeCards(from: PileRef) -> [PlayingCard]? {
        guard let moving = movableCards(from: from) else { return nil }
        switch from.kind {
        case .foundation: return foundations[from.index].pop().map { [$0] }
        case .tableau: return tableau[from.index].pop(count: moving.count)
        default: return nil
        }
    }
}
