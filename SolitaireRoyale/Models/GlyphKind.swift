import SwiftUI

enum PuzzleMatchStyle: String, Codable {
    case celestialSymbols
    case runeSymbols
    case sameNumber
    case sumPairs
}

/// One tile on the board — symbols, numbers, or sum-pair values per mode.
struct PuzzleCell: Codable, Equatable, Hashable {
    let key: String
    let display: String
    let symbolName: String?
    let numericValue: Int
    let accent: ColorComponents

    struct ColorComponents: Codable, Equatable, Hashable {
        let r: Double
        let g: Double
        let b: Double

        var color: Color { Color(red: r, green: g, blue: b) }
    }

    func matches(_ other: PuzzleCell, style: PuzzleMatchStyle, sumTarget: Int) -> Bool {
        switch style {
        case .celestialSymbols, .runeSymbols:
            return key == other.key
        case .sameNumber:
            return numericValue == other.numericValue
        case .sumPairs:
            return numericValue + other.numericValue == sumTarget
        }
    }
}

struct GridPos: Hashable, Codable {
    let row: Int
    let col: Int
}

enum PuzzleCellFactory {
    static func board(for mode: SolitaireMode, config: LevelConfig, rng: inout SeededRNG) -> [PuzzleCell] {
        switch mode.matchStyle {
        case .celestialSymbols:
            return fillBoard(tokens: Array(celestialTokens.prefix(config.tokenVariety)), pairsPerToken: config.pairsPerToken, rng: &rng)
        case .runeSymbols:
            return fillBoard(tokens: Array(runeTokens.prefix(config.tokenVariety)), pairsPerToken: config.pairsPerToken, rng: &rng)
        case .sameNumber:
            return fillBoard(tokens: numberTokens(config.numberRange), pairsPerToken: config.pairsPerToken, rng: &rng)
        case .sumPairs:
            return fillSumBoard(target: config.sumTarget, pairCount: config.tokenVariety, pairsPerToken: config.pairsPerToken, rng: &rng)
        }
    }

    private static func fillBoard(tokens: [PuzzleCell], pairsPerToken: Int, rng: inout SeededRNG) -> [PuzzleCell] {
        var bag: [PuzzleCell] = []
        for token in tokens {
            bag.append(contentsOf: Array(repeating: token, count: pairsPerToken * 2))
        }
        bag.shuffle(using: &rng)
        return bag
    }

    private static func fillSumBoard(target: Int, pairCount: Int, pairsPerToken: Int, rng: inout SeededRNG) -> [PuzzleCell] {
        var pairs: [(Int, Int)] = []
        for a in 1...(target / 2) {
            let b = target - a
            if b >= 1 && b <= 12 { pairs.append((a, b)) }
        }
        pairs.shuffle(using: &rng)
        let chosen = Array(pairs.prefix(pairCount))
        var bag: [PuzzleCell] = []
        for (a, b) in chosen {
            let left = numberToken(a, hue: Double(a) * 0.07)
            let right = numberToken(b, hue: Double(b) * 0.07 + 0.5)
            for _ in 0..<pairsPerToken {
                bag.append(left)
                bag.append(right)
            }
        }
        bag.shuffle(using: &rng)
        return Array(bag.prefix(GlyphLinkEngine.rows * GlyphLinkEngine.cols))
    }

    private static func numberTokens(_ range: ClosedRange<Int>) -> [PuzzleCell] {
        range.map { numberToken($0, hue: Double($0) * 0.06) }
    }

    private static func numberToken(_ n: Int, hue: Double) -> PuzzleCell {
        PuzzleCell(
            key: "n\(n)",
            display: "\(n)",
            symbolName: nil,
            numericValue: n,
            accent: PuzzleCell.ColorComponents(
                r: 0.35 + hue * 0.4,
                g: 0.55 + (1 - hue) * 0.3,
                b: 0.95
            )
        )
    }

    private static var celestialTokens: [PuzzleCell] {
        [
            token("moon", "moon.stars.fill", "✦", 0.68, 0.55, 0.95),
            token("sun", "sun.max.fill", "☀", 0.98, 0.78, 0.28),
            token("star", "star.fill", "★", 1.0, 0.88, 0.42),
            token("sparkle", "sparkles", "✧", 0.55, 0.82, 0.98),
            token("cloud", "cloud.moon.fill", "☁", 0.72, 0.78, 0.92),
            token("comet", "meteor", "☄", 0.88, 0.52, 0.98),
        ]
    }

    private static var runeTokens: [PuzzleCell] {
        [
            token("bolt", "bolt.fill", "⚡", 0.25, 0.88, 0.98),
            token("flame", "flame.fill", "🔥", 0.98, 0.45, 0.22),
            token("wind", "wind", "🌪", 0.42, 0.92, 0.88),
            token("wave", "water.waves", "🌊", 0.18, 0.55, 0.98),
            token("snow", "snowflake", "❄", 0.75, 0.92, 1.0),
            token("leaf", "leaf.fill", "🍃", 0.35, 0.88, 0.42),
        ]
    }

    private static func token(_ key: String, _ symbol: String, _ display: String, _ r: Double, _ g: Double, _ b: Double) -> PuzzleCell {
        PuzzleCell(
            key: key,
            display: display,
            symbolName: symbol,
            numericValue: 0,
            accent: PuzzleCell.ColorComponents(r: r, g: g, b: b)
        )
    }
}
