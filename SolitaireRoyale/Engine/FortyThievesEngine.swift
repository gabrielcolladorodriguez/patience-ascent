import Foundation

final class FortyThievesEngine: BaseEngine {
    private(set) var tableau: [CardPile] = (0..<10).map { CardPile(id: "t\($0)", cards: []) }
    private(set) var foundations: [CardPile] = (0..<8).map { CardPile(id: "f\($0)", cards: []) }
    private(set) var stock = CardPile(id: "stock", cards: [])
    private(set) var waste = CardPile(id: "waste", cards: [])

    override init(mode: SolitaireMode = .fortyThieves) { super.init(mode: mode) }

    override var isWon: Bool { foundations.allSatisfy { $0.cards.count == 13 } }

    override func reset() {
        super.reset()
        var deck = DeckFactory.doubleDeck()
        tableau = (0..<10).map { _ in
            var pile: [PlayingCard] = []
            for _ in 0..<4 {
                var c = deck.removeFirst(); c.faceUp = true; pile.append(c)
            }
            return CardPile(id: "t", cards: pile)
        }
        stock = CardPile(id: "stock", cards: deck.map { var c = $0; c.faceUp = false; return c })
        waste = CardPile(id: "waste", cards: [])
        foundations = (0..<8).map { CardPile(id: "f\($0)", cards: []) }
    }

    override func pile(_ ref: PileRef) -> CardPile {
        switch ref.kind {
        case .tableau: return tableau[ref.index]
        case .foundation: return foundations[ref.index]
        case .stock: return stock
        case .waste: return waste
        default: return CardPile(id: "x", cards: [])
        }
    }

    override func allPileRefs() -> [PileRef] {
        var refs = (0..<10).map { PileRef(kind: .tableau, index: $0) }
        refs += (0..<8).map { PileRef(kind: .foundation, index: $0) }
        refs += [PileRef(kind: .stock, index: 0), PileRef(kind: .waste, index: 0)]
        return refs
    }

    override func drawFromStock() -> Bool {
        if stock.isEmpty {
            guard !waste.isEmpty else { return false }
            let recycled = waste.cards.reversed().map { var c = $0; c.faceUp = false; return c }
            stock.cards = recycled
            waste.cards = []
            return true
        }
        guard var card = stock.pop() else { return false }
        card.faceUp = true
        waste.push(card)
        moveHistory.append(CardMove(from: PileRef(kind: .stock, index: 0), to: PileRef(kind: .waste, index: 0), cards: [card], flippedCardID: nil))
        return true
    }

    override func canMove(from: PileRef, to: PileRef) -> Bool {
        guard let moving = movableCards(from: from), moving.count == 1, let top = moving.first else { return false }
        if to.kind == .foundation {
            let dest = foundations[to.index]
            if dest.isEmpty { return top.rank == .ace }
            guard let dt = dest.top, dt.suit == top.suit else { return false }
            return top.rank.rawValue == dt.rank.rawValue + 1
        }
        if to.kind == .tableau {
            let dest = tableau[to.index]
            if dest.isEmpty { return true }
            guard let dt = dest.top else { return false }
            return top.suit == dt.suit && top.rank.rawValue == dt.rank.rawValue - 1
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
        if !stock.isEmpty { return (PileRef(kind: .stock, index: 0), PileRef(kind: .waste, index: 0)) }
        return nil
    }

    override func applyUndo(_ move: CardMove) {
        switch move.to.kind {
        case .foundation: _ = foundations[move.to.index].pop()
        case .tableau: _ = tableau[move.to.index].pop()
        case .waste: _ = waste.pop()
        default: break
        }
        switch move.from.kind {
        case .tableau: tableau[move.from.index].push(move.cards)
        case .foundation: foundations[move.from.index].push(move.cards)
        case .stock:
            _ = stock.pop()
            waste.push(move.cards)
        case .waste: waste.push(move.cards)
        default: break
        }
    }

    private func movableCards(from: PileRef) -> [PlayingCard]? {
        switch from.kind {
        case .waste: return waste.top.map { [$0] }
        case .foundation: return foundations[from.index].top.map { [$0] }
        case .tableau: return tableau[from.index].top.map { [$0] }
        default: return nil
        }
    }

    private func takeCards(from: PileRef) -> [PlayingCard]? {
        movableCards(from: from).flatMap { _ in
            switch from.kind {
            case .waste: return waste.pop().map { [$0] }
            case .foundation: return foundations[from.index].pop().map { [$0] }
            case .tableau: return tableau[from.index].pop().map { [$0] }
            default: return nil
            }
        }
    }
}

enum EngineFactory {
    static func make(for mode: SolitaireMode) -> SolitaireEngine {
        switch mode {
        case .klondike: return KlondikeEngine()
        case .freeCell: return FreeCellEngine()
        case .spider: return SpiderEngine()
        case .pyramid: return PyramidEngine()
        case .triPeaks: return TriPeaksEngine()
        case .golf: return GolfEngine()
        case .yukon: return YukonEngine()
        case .fortyThieves: return FortyThievesEngine()
        case .glyphLink: return BaseEngine(mode: .glyphLink)
        }
    }
}
