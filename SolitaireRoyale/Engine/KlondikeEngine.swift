import Foundation

final class KlondikeEngine: BaseEngine {
    private(set) var tableau: [CardPile] = (0..<7).map { CardPile(id: "t\($0)", cards: []) }
    private(set) var foundations: [CardPile] = (0..<4).map { CardPile(id: "f\($0)", cards: []) }
    private(set) var stock = CardPile(id: "stock", cards: [])
    private(set) var waste = CardPile(id: "waste", cards: [])
    var drawCount = 1

    override init(mode: SolitaireMode = .klondike) { super.init(mode: mode) }

    override var isWon: Bool {
        foundations.allSatisfy { $0.cards.count == 13 }
    }

    override func reset() {
        super.reset()
        var deck = DeckFactory.standardDeck()
        tableau = (0..<7).map { col in
            var pileCards: [PlayingCard] = []
            for row in 0...col {
                var card = deck.removeFirst()
                card.faceUp = row == col
                pileCards.append(card)
            }
            return CardPile(id: "t\(col)", cards: pileCards)
        }
        stock = CardPile(id: "stock", cards: deck.map { var c = $0; c.faceUp = false; return c })
        waste = CardPile(id: "waste", cards: [])
        foundations = (0..<4).map { CardPile(id: "f\($0)", cards: []) }
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
        var refs = (0..<7).map { PileRef(kind: .tableau, index: $0) }
        refs += (0..<4).map { PileRef(kind: .foundation, index: $0) }
        refs += [PileRef(kind: .stock, index: 0), PileRef(kind: .waste, index: 0)]
        return refs
    }

    override func drawFromStock() -> Bool {
        if stock.isEmpty {
            guard !waste.isEmpty else { return false }
            let recycled = waste.cards.reversed().map { var c = $0; c.faceUp = false; return c }
            moveHistory.append(CardMove(from: PileRef(kind: .waste, index: 0), to: PileRef(kind: .stock, index: 0), cards: waste.cards, flippedCardID: nil))
            stock.cards = recycled
            waste.cards = []
            return true
        }
        let take = min(drawCount, stock.cards.count)
        var drawn: [PlayingCard] = []
        for _ in 0..<take {
            var card = stock.pop()!
            card.faceUp = true
            drawn.append(card)
        }
        moveHistory.append(CardMove(from: PileRef(kind: .stock, index: 0), to: PileRef(kind: .waste, index: 0), cards: drawn, flippedCardID: nil))
        waste.push(drawn)
        return true
    }

    override func canMove(from: PileRef, to: PileRef) -> Bool {
        guard let moving = movableCards(from: from) else { return false }
        guard let top = moving.first else { return false }
        if to.kind == .foundation {
            guard moving.count == 1 else { return false }
            let dest = foundations[to.index]
            if dest.isEmpty { return top.rank == .ace }
            guard let destTop = dest.top, destTop.suit == top.suit else { return false }
            return top.rank.rawValue == destTop.rank.rawValue + 1
        }
        if to.kind == .tableau {
            let dest = tableau[to.index]
            if dest.isEmpty { return top.rank == .king }
            guard let destTop = dest.top, destTop.faceUp else { return false }
            return top.suit.isRed != destTop.suit.isRed && top.rank.rawValue == destTop.rank.rawValue - 1
        }
        return false
    }

    override func move(from: PileRef, to: PileRef) -> Bool {
        guard canMove(from: from, to: to), let cards = takeCards(from: from) else { return false }
        var flippedID: UUID?
        if from.kind == .tableau {
            let src = tableau[from.index]
            if let last = src.cards.last, !last.faceUp {
                flippedID = last.id
                tableau[from.index].cards[src.cards.count - 1].faceUp = true
            }
        }
        switch to.kind {
        case .foundation: foundations[to.index].push(cards)
        case .tableau: tableau[to.index].push(cards)
        default: return false
        }
        moveHistory.append(CardMove(from: from, to: to, cards: cards, flippedCardID: flippedID))
        return true
    }

    override func hint() -> (from: PileRef, to: PileRef)? {
        for from in allPileRefs() {
            for to in allPileRefs() where from != to {
                if canMove(from: from, to: to) { return (from, to) }
            }
        }
        if !stock.isEmpty || !waste.isEmpty { return (PileRef(kind: .stock, index: 0), PileRef(kind: .waste, index: 0)) }
        return nil
    }

    override func applyUndo(_ move: CardMove) {
        switch move.to.kind {
        case .foundation: _ = foundations[move.to.index].pop(count: move.cards.count)
        case .tableau: _ = tableau[move.to.index].pop(count: move.cards.count)
        case .waste:
            for _ in move.cards { _ = waste.pop() }
            stock.push(move.cards.reversed().map { var c = $0; c.faceUp = false; return c })
            return
        default: break
        }
        switch move.from.kind {
        case .tableau:
            if let fid = move.flippedCardID, let idx = tableau[move.from.index].cards.firstIndex(where: { $0.id == fid }) {
                tableau[move.from.index].cards[idx].faceUp = false
            }
            tableau[move.from.index].push(move.cards)
        case .foundation: foundations[move.from.index].push(move.cards)
        case .stock:
            for _ in move.cards { _ = stock.pop() }
            waste.push(move.cards)
        case .waste: waste.push(move.cards)
        default: break
        }
    }

    private func movableCards(from: PileRef) -> [PlayingCard]? {
        switch from.kind {
        case .waste:
            guard let top = waste.top, top.faceUp else { return nil }
            return [top]
        case .foundation:
            guard let top = foundations[from.index].top else { return nil }
            return [top]
        case .tableau:
            let pile = tableau[from.index]
            guard let start = pile.cards.firstIndex(where: { $0.faceUp }) else { return nil }
            return Array(pile.cards[start...])
        default: return nil
        }
    }

    private func takeCards(from: PileRef) -> [PlayingCard]? {
        switch from.kind {
        case .waste: return waste.pop().map { [$0] }
        case .foundation: return foundations[from.index].pop().map { [$0] }
        case .tableau:
            guard let moving = movableCards(from: from) else { return nil }
            return tableau[from.index].pop(count: moving.count)
        default: return nil
        }
    }
}
