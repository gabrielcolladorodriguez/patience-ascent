import Foundation

final class SpiderEngine: BaseEngine {
    private(set) var tableau: [CardPile] = (0..<10).map { CardPile(id: "t\($0)", cards: []) }
    private(set) var stock = CardPile(id: "stock", cards: [])
    var suitCount = 1

    override init(mode: SolitaireMode = .spider) { super.init(mode: mode) }

    override var isWon: Bool {
        tableau.allSatisfy(\.isEmpty) && stock.isEmpty
    }

    override func reset() {
        super.reset()
        var deck = DeckFactory.spiderDeck(suits: suitCount)
        tableau = (0..<10).map { col in
            let count = col < 4 ? 6 : 5
            var pile: [PlayingCard] = []
            for i in 0..<count {
                var card = deck.removeFirst()
                card.faceUp = i == count - 1
                pile.append(card)
            }
            return CardPile(id: "t\(col)", cards: pile)
        }
        stock = CardPile(id: "stock", cards: deck.map { var c = $0; c.faceUp = false; return c })
    }

    override func pile(_ ref: PileRef) -> CardPile {
        if ref.kind == .tableau { return tableau[ref.index] }
        if ref.kind == .stock { return stock }
        return CardPile(id: "x", cards: [])
    }

    override func allPileRefs() -> [PileRef] {
        (0..<10).map { PileRef(kind: .tableau, index: $0) } + [PileRef(kind: .stock, index: 0)]
    }

    override func drawFromStock() -> Bool {
        guard stock.cards.count >= 10 else { return false }
        var dealt: [PlayingCard] = []
        for col in 0..<10 {
            var card = stock.pop()!
            card.faceUp = true
            tableau[col].push(card)
            dealt.append(card)
        }
        moveHistory.append(CardMove(from: PileRef(kind: .stock, index: 0), to: PileRef(kind: .tableau, index: 0), cards: dealt, flippedCardID: nil))
        removeCompletedRuns()
        return true
    }

    override func canMove(from: PileRef, to: PileRef) -> Bool {
        guard from.kind == .tableau, to.kind == .tableau, from.index != to.index else { return false }
        guard let moving = movableCards(from: from), let top = moving.first else { return false }
        let dest = tableau[to.index]
        if dest.isEmpty { return top.rank == .king }
        guard let dt = dest.top, dt.faceUp, dt.suit == top.suit else { return false }
        return top.rank.rawValue == dt.rank.rawValue - 1
    }

    override func move(from: PileRef, to: PileRef) -> Bool {
        guard canMove(from: from, to: to), let cards = takeCards(from: from) else { return false }
        var flippedID: UUID?
        let src = tableau[from.index]
        if let last = src.cards.last, !last.faceUp {
            flippedID = last.id
            tableau[from.index].cards[src.cards.count - 1].faceUp = true
        }
        tableau[to.index].push(cards)
        moveHistory.append(CardMove(from: from, to: to, cards: cards, flippedCardID: flippedID))
        removeCompletedRuns()
        return true
    }

    override func hint() -> (from: PileRef, to: PileRef)? {
        for from in (0..<10).map({ PileRef(kind: .tableau, index: $0) }) {
            for to in (0..<10).map({ PileRef(kind: .tableau, index: $0) }) where from != to {
                if canMove(from: from, to: to) { return (from, to) }
            }
        }
        if stock.cards.count >= 10 { return (PileRef(kind: .stock, index: 0), PileRef(kind: .tableau, index: 0)) }
        return nil
    }

    override func applyUndo(_ move: CardMove) {
        if move.from.kind == .stock {
            for col in stride(from: 9, through: 0, by: -1) {
                if let card = tableau[col].pop() { stock.push(card) }
            }
            return
        }
        _ = tableau[move.to.index].pop(count: move.cards.count)
        if let fid = move.flippedCardID, let idx = tableau[move.from.index].cards.firstIndex(where: { $0.id == fid }) {
            tableau[move.from.index].cards[idx].faceUp = false
        }
        tableau[move.from.index].push(move.cards)
    }

    private func movableCards(from: PileRef) -> [PlayingCard]? {
        let pile = tableau[from.index]
        guard let start = pile.cards.firstIndex(where: { $0.faceUp }) else { return nil }
        let visible = Array(pile.cards[start...])
        guard let first = visible.first else { return nil }
        var seq = [first]
        for i in 1..<visible.count {
            let a = visible[i - 1], b = visible[i]
            guard a.suit == b.suit, a.rank.rawValue == b.rank.rawValue + 1 else { break }
            seq.append(b)
        }
        return seq
    }

    private func takeCards(from: PileRef) -> [PlayingCard]? {
        guard let moving = movableCards(from: from) else { return nil }
        return tableau[from.index].pop(count: moving.count)
    }

    private func removeCompletedRuns() {
        for col in 0..<10 {
            let pile = tableau[col]
            guard pile.cards.count >= 13 else { continue }
            let tail = Array(pile.cards.suffix(13))
            guard let first = tail.first, first.rank == .king else { continue }
            var ok = true
            for i in 1..<13 {
                if tail[i].suit != first.suit || tail[i].rank.rawValue != tail[i - 1].rank.rawValue - 1 { ok = false; break }
            }
            if ok { tableau[col].cards.removeLast(13) }
            if let last = tableau[col].cards.last, !last.faceUp {
                tableau[col].cards[tableau[col].cards.count - 1].faceUp = true
            }
        }
    }
}
