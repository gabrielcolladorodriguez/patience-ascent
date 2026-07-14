import Foundation

struct LevelUpResult: Equatable {
    let mode: SolitaireMode
    let oldLevel: Int
    let newLevel: Int
    let xpGained: Int
    let stars: Int
}

/// Per-mode difficulty that scales with player level.
struct LevelConfig: Equatable {
    let mode: SolitaireMode
    let level: Int

    static func forMode(_ mode: SolitaireMode, level: Int) -> LevelConfig {
        LevelConfig(mode: mode, level: max(1, level))
    }

    var tierKey: String {
        switch level {
        case 1...4: return "tier_rookie"
        case 5...9: return "tier_adept"
        case 10...19: return "tier_expert"
        case 20...34: return "tier_master"
        case 35...49: return "tier_legend"
        default: return "tier_ascendant"
        }
    }

    var tierName: String { L10n.s(tierKey) }

    var intensity: Double { min(1.0, Double(level - 1) * 0.04) }

    var tokenVariety: Int {
        switch mode.matchStyle {
        case .celestialSymbols, .runeSymbols:
            return min(6, 3 + (level - 1) / 2)
        case .sameNumber:
            return min(12, 4 + (level - 1) / 2)
        case .sumPairs:
            return min(6, 3 + (level - 1) / 3)
        }
    }

    var pairsPerToken: Int { min(8, 4 + (level - 1) / 3) }

    var sumTarget: Int {
        switch level {
        case 1...4: return 10
        case 5...9: return 11
        case 10...14: return 12
        case 15...19: return 13
        default: return 15
        }
    }

    var numberRange: ClosedRange<Int> {
        let upper = min(12, max(4, tokenVariety))
        return 1...upper
    }

    var rushDuration: TimeInterval { max(40, 96 - Double(level) * 2.8) }

    var pressureLimit: TimeInterval? {
        guard level >= 6, mode == .glyphLink || mode == .glyphChain else { return nil }
        return max(90, 280 - Double(level) * 9)
    }

    var difficultyTags: [String] {
        var tags: [String] = [L10n.s("diff_level_fmt", level), tierName]
        if mode == .glyphRush {
            tags.append(L10n.s("diff_timer_fmt", Int(rushDuration)))
        }
        if mode == .glyphZen {
            tags.append(L10n.s("diff_sum_fmt", sumTarget))
        }
        if let limit = pressureLimit {
            tags.append(L10n.s("diff_pressure_fmt", Int(limit)))
        }
        if tokenVariety >= 5 {
            tags.append(L10n.s("diff_dense"))
        }
        return tags
    }
}

enum AscentProgression {
    static let maxLevel = 99

    static func xpRequired(forLevel level: Int) -> Int {
        70 + level * 45
    }

    static func xpProgress(level: Int, xp: Int) -> Double {
        let need = xpRequired(forLevel: level)
        guard need > 0 else { return 0 }
        return min(1.0, Double(xp) / Double(need))
    }

    static func computeStars(mode: SolitaireMode, moves: Int, comboPeak: Int, elapsed: TimeInterval, score: Int) -> Int {
        var stars = 1
        if comboPeak >= 3 { stars = 2 }
        if mode == .glyphRush {
            if score >= 2500 || comboPeak >= 5 { stars = 3 }
        } else if comboPeak >= 6 || moves <= 28 {
            stars = 3
        } else if elapsed > 0 && elapsed < 120 && moves <= 36 {
            stars = max(stars, 2)
        }
        return stars
    }

    static func xpReward(mode: SolitaireMode, level: Int, stars: Int, comboPeak: Int, score: Int) -> Int {
        var xp = 35 + level * 8 + stars * 30 + comboPeak * 6
        if mode == .glyphRush { xp += score / 90 }
        return max(25, xp)
    }

    static func globalRank(levels: [String: Int]) -> Int {
        levels.values.reduce(0, +)
    }

    static func globalRankTitle(_ rank: Int) -> String {
        switch rank {
        case 0...7: return L10n.s("rank_novice")
        case 8...19: return L10n.s("rank_climber")
        case 20...39: return L10n.s("rank_veteran")
        case 40...69: return L10n.s("rank_elite")
        default: return L10n.s("rank_mythic")
        }
    }
}
