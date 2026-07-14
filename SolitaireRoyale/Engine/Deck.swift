import Foundation

enum DeckFactory {
    static func standardDeck(shuffled: Bool = true) -> [PlayingCard] {
        var cards: [PlayingCard] = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(PlayingCard(suit: suit, rank: rank))
            }
        }
        return shuffled ? cards.shuffled() : cards
    }

    static func doubleDeck(shuffled: Bool = true) -> [PlayingCard] {
        var cards = standardDeck(shuffled: false) + standardDeck(shuffled: false)
        return shuffled ? cards.shuffled() : cards
    }

    static func spiderDeck(suits: Int = 1) -> [PlayingCard] {
        let chosen = Array(Suit.allCases.prefix(max(1, min(4, suits))))
        var cards: [PlayingCard] = []
        for _ in 0..<2 {
            for suit in chosen {
                for rank in Rank.allCases {
                    cards.append(PlayingCard(suit: suit, rank: rank))
                }
            }
        }
        return cards.shuffled()
    }
}

protocol SolitaireEngine: AnyObject {
    var mode: SolitaireMode { get }
    var moveHistory: [CardMove] { get set }
    var isWon: Bool { get }
    var canUndo: Bool { get }

    func reset()
    func drawFromStock() -> Bool
    func canMove(from: PileRef, to: PileRef) -> Bool
    func move(from: PileRef, to: PileRef) -> Bool
    func undo() -> Bool
    func hint() -> (from: PileRef, to: PileRef)?
    func pile(_ ref: PileRef) -> CardPile
    func allPileRefs() -> [PileRef]
}

extension SolitaireEngine {
    func record(_ move: CardMove) { moveHistory.append(move) }
}

class BaseEngine: SolitaireEngine {
    let mode: SolitaireMode
    var moveHistory: [CardMove] = []
    var isWon: Bool { false }
    var canUndo: Bool { !moveHistory.isEmpty }

    init(mode: SolitaireMode) { self.mode = mode }

    func reset() { moveHistory.removeAll() }
    func drawFromStock() -> Bool { false }
    func canMove(from: PileRef, to: PileRef) -> Bool { false }
    func move(from: PileRef, to: PileRef) -> Bool { false }

    func undo() -> Bool {
        guard let last = moveHistory.popLast() else { return false }
        applyUndo(last)
        return true
    }

    func hint() -> (from: PileRef, to: PileRef)? { nil }
    func pile(_ ref: PileRef) -> CardPile { CardPile(id: ref.kind.rawValue, cards: []) }
    func allPileRefs() -> [PileRef] { [] }

    func applyUndo(_ move: CardMove) {}
}
