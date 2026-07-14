import Foundation

enum Suit: String, CaseIterable, Codable {
    case clubs, diamonds, hearts, spades

    var isRed: Bool { self == .hearts || self == .diamonds }
}

enum Rank: Int, CaseIterable, Codable {
    case ace = 1, two, three, four, five, six, seven, eight, nine, ten, jack, queen, king

    var label: String {
        switch self {
        case .ace: return "A"
        case .jack: return "J"
        case .queen: return "Q"
        case .king: return "K"
        default: return "\(rawValue)"
        }
    }
}

struct PlayingCard: Identifiable, Equatable, Codable, Hashable {
    let id: UUID
    let suit: Suit
    let rank: Rank
    var faceUp: Bool

    init(suit: Suit, rank: Rank, faceUp: Bool = false, id: UUID = UUID()) {
        self.id = id
        self.suit = suit
        self.rank = rank
        self.faceUp = faceUp
    }

    var imageName: String {
        let rankName: String
        switch rank {
        case .ace: rankName = "ace"
        case .jack: rankName = "jack"
        case .queen: rankName = "queen"
        case .king: rankName = "king"
        default: rankName = "\(rank.rawValue)"
        }
        return "\(rankName)_of_\(suit.rawValue)"
    }

    var value: Int { rank.rawValue }
}

struct CardPile: Identifiable, Equatable, Codable {
    let id: String
    var cards: [PlayingCard]

    var top: PlayingCard? { cards.last }
    var isEmpty: Bool { cards.isEmpty }

    mutating func push(_ card: PlayingCard) { cards.append(card) }
    mutating func push(_ cards newCards: [PlayingCard]) { cards.append(contentsOf: newCards) }
    @discardableResult mutating func pop() -> PlayingCard? { cards.popLast() }
    @discardableResult mutating func pop(count: Int) -> [PlayingCard]? {
        guard count > 0, cards.count >= count else { return nil }
        let slice = Array(cards.suffix(count))
        cards.removeLast(count)
        return slice
    }
}

enum PileKind: String, Codable {
    case tableau, foundation, stock, waste, freeCell, reserve
}

struct PileRef: Hashable, Codable {
    let kind: PileKind
    let index: Int

    var code: String { "\(kind.rawValue):\(index)" }

    static func decode(_ code: String) -> PileRef? {
        let parts = code.split(separator: ":")
        guard parts.count == 2,
              let kind = PileKind(rawValue: String(parts[0])),
              let idx = Int(parts[1]) else { return nil }
        return PileRef(kind: kind, index: idx)
    }
}

struct CardMove: Equatable, Codable {
    let from: PileRef
    let to: PileRef
    let cards: [PlayingCard]
    let flippedCardID: UUID?
}
