import Foundation

/// Original glyph-connect puzzle modes — no classic solitaire.
enum SolitaireMode: String, CaseIterable, Identifiable, Codable {
    case glyphLink
    case glyphChain
    case glyphRush
    case glyphZen

    var id: String { rawValue }

    static var puzzleModes: [SolitaireMode] { allCases }

    var title: String { L10n.modeTitle(self) }
    var subtitle: String { L10n.modeSubtitle(self) }
    var controlsHint: String { L10n.controlsHint(self) }
    var theme: ModeTheme { ModeTheme.forMode(self) }

    var matchStyle: PuzzleMatchStyle {
        switch self {
        case .glyphLink: return .celestialSymbols
        case .glyphChain: return .runeSymbols
        case .glyphRush: return .sameNumber
        case .glyphZen: return .sumPairs
        }
    }

    func levelConfig(level: Int = 1) -> LevelConfig {
        LevelConfig.forMode(self, level: level)
    }

    func rules(level: Int = 1) -> GlyphLinkRules {
        let config = levelConfig(level: level)
        switch self {
        case .glyphLink:
            return GlyphLinkRules(
                autoReshuffle: true,
                requiresChain: false,
                rushDuration: nil,
                winOnClear: true,
                pressureLimit: config.pressureLimit,
                sumTarget: 0
            )
        case .glyphChain:
            return GlyphLinkRules(
                autoReshuffle: true,
                requiresChain: true,
                rushDuration: nil,
                winOnClear: true,
                pressureLimit: config.pressureLimit,
                sumTarget: 0
            )
        case .glyphRush:
            return GlyphLinkRules(
                autoReshuffle: true,
                requiresChain: false,
                rushDuration: config.rushDuration,
                winOnClear: false,
                pressureLimit: nil,
                sumTarget: 0
            )
        case .glyphZen:
            return GlyphLinkRules(
                autoReshuffle: false,
                requiresChain: false,
                rushDuration: nil,
                winOnClear: true,
                pressureLimit: nil,
                sumTarget: config.sumTarget
            )
        }
    }

    var quickRules: [String] {
        switch self {
        case .glyphLink:
            return [L10n.s("rules_glyph_1"), L10n.s("rules_glyph_2"), L10n.s("rules_glyph_3"), L10n.s("rules_glyph_4")]
        case .glyphChain:
            return [L10n.s("rules_chain_1"), L10n.s("rules_chain_2"), L10n.s("rules_chain_3"), L10n.s("rules_chain_4")]
        case .glyphRush:
            return [L10n.s("rules_rush_1"), L10n.s("rules_rush_2"), L10n.s("rules_rush_3"), L10n.s("rules_rush_4")]
        case .glyphZen:
            return [L10n.s("rules_zen_1"), L10n.s("rules_zen_2"), L10n.s("rules_zen_3"), L10n.s("rules_zen_4")]
        }
    }

    var tutorialSteps: [String] {
        switch self {
        case .glyphLink:
            return [L10n.s("tut_link_1"), L10n.s("tut_link_2"), L10n.s("tut_link_3")]
        case .glyphChain:
            return [L10n.s("tut_chain_1"), L10n.s("tut_chain_2"), L10n.s("tut_chain_3")]
        case .glyphRush:
            return [L10n.s("tut_rush_1"), L10n.s("tut_rush_2"), L10n.s("tut_rush_3")]
        case .glyphZen:
            return [L10n.s("tut_zen_1"), L10n.s("tut_zen_2"), L10n.s("tut_zen_3")]
        }
    }

    var iconName: String {
        switch self {
        case .glyphLink: return "moon.stars.fill"
        case .glyphChain: return "bolt.horizontal.circle.fill"
        case .glyphRush: return "number.circle.fill"
        case .glyphZen: return "plus.circle.fill"
        }
    }

    var usesScoreLeaderboard: Bool { self == .glyphRush }

    var tutorialStorageKey: String { "tutorialSeen_\(rawValue)" }
}

struct GlyphLinkRules {
    let autoReshuffle: Bool
    let requiresChain: Bool
    let rushDuration: TimeInterval?
    let winOnClear: Bool
    let pressureLimit: TimeInterval?
    let sumTarget: Int
}
