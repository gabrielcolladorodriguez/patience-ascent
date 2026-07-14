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

    var rules: GlyphLinkRules {
        switch self {
        case .glyphLink:
            return GlyphLinkRules(autoReshuffle: true, requiresChain: false, rushDuration: nil, winOnClear: true)
        case .glyphChain:
            return GlyphLinkRules(autoReshuffle: true, requiresChain: true, rushDuration: nil, winOnClear: true)
        case .glyphRush:
            return GlyphLinkRules(autoReshuffle: true, requiresChain: false, rushDuration: 90, winOnClear: false)
        case .glyphZen:
            return GlyphLinkRules(autoReshuffle: false, requiresChain: false, rushDuration: nil, winOnClear: true)
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

    var iconName: String {
        switch self {
        case .glyphLink: return "link.circle.fill"
        case .glyphChain: return "bolt.circle.fill"
        case .glyphRush: return "timer.circle.fill"
        case .glyphZen: return "leaf.circle.fill"
        }
    }

    var usesScoreLeaderboard: Bool { self == .glyphRush }
}

struct GlyphLinkRules {
    let autoReshuffle: Bool
    let requiresChain: Bool
    let rushDuration: TimeInterval?
    let winOnClear: Bool
}
