import Foundation

/// Single puzzle mode — gravity block placement (Patience Ascent).
enum SolitaireMode: String, CaseIterable, Identifiable, Codable {
    case gravityBlocks

    var id: String { rawValue }

    static var puzzleModes: [SolitaireMode] { [.gravityBlocks] }

    var title: String { L10n.s("mode_gravity_blocks") }
    var subtitle: String { L10n.s("mode_gravity_sub") }
    var controlsHint: String { L10n.s("controls_gravity") }
    var theme: ModeTheme { ModeTheme.game }

    var quickRules: [String] {
        [
            L10n.s("rules_gravity_1"),
            L10n.s("rules_gravity_2"),
            L10n.s("rules_gravity_3"),
            L10n.s("rules_gravity_4")
        ]
    }

    var iconName: String { "square.grid.3x3.fill" }
    var usesScoreLeaderboard: Bool { true }
}
