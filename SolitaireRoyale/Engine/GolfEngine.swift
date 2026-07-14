import Foundation

final class GolfEngine: BaseEngine {
    private(set) var tableau: [CardPile] = (0..<7).map { CardPile(id: "t\($0)", cards: []) }
    private(set) var stock = CardPile(id: "stock", cards: [])
    private(set) var waste = CardPile(id: "waste", cards: [])

    override init(mode: SolitaireMode = .golf) { super.init(mode: mode) }

    override var isWon: Bool {
        tableau.allSatisfy(\.isEmpty) && stock.isEmpty
    }

    override func reset() {
        super.reset()
        var deck = DeckFactory.standardDeck()
        tableau = (0..<7).map { _ in
            var pile: [PlayingCard] = []
            for _ in 0..<5 {
                var c = deck.removeFirst(); c.faceUp = true; pile.append(c)
            }
            return CardPile(id: "t", cards: pile)
        }
        var wasteCard = deck.removeFirst(); wasteCard.faceUp = true
        waste = CardPile(id: "waste", cards: [wasteCard])
        stock = CardPile(id: "stock", cards: deck.map { var c = $0; c.faceUp = false; return c })
    }

    override func pile(_ ref: PileRef) -> CardPile {
        switch ref.kind {
        case .tableau: return tableau[ref.index]
        case .stock: return stock
        case .waste: return waste
        default: return CardPile(id: "x", cards: [])
        }
    }

    override func allPileRefs() -> [PileRef] {
        (0..<7).map { PileRef(kind: .tableau, index: $0) } + [PileRef(kind: .stock, index: 0), PileRef(kind: .waste, index: 0)]
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
        guard from.kind == .tableau, to.kind == .waste, let card = tableau[from.index].top, let w = waste.top else { return false }
        return wraps(card.value, w.value)
    }

    override func move(from: PileRef, to: PileRef) -> Bool {
        guard canMove(from: from, to: to), let card = tableau[from.index].pop() else { return false }
        waste = CardPile(id: "waste", cards: [card])
        moveHistory.append(CardMove(from: from, to: to, cards: [card], flippedCardID: nil))
        return true
    }

    override func hint() -> (from: PileRef, to: PileRef)? {
        guard let w = waste.top else { return nil }
        for i in 0..<7 where tableau[i].top.map({ wraps($0.value, w.value) }) == true {
            return (PileRef(kind: .tableau, index: i), PileRef(kind: .waste, index: 0))
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
        tableau[move.from.index].push(move.cards)
        if let prev = moveHistory.dropLast().last?.cards.first {
            waste = CardPile(id: "waste", cards: [prev])
        }
    }
}
