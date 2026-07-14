import SwiftUI

struct ModeTheme {
    let feltTop: Color
    let feltMid: Color
    let feltBottom: Color
    let feltGlow: Color
    let accent: Color
    let accentLight: Color
    let gold: Color
    let tableSurface: Color
    let tableSurface2: Color
    let tableBorder: Color
    let tableFrame: Color
    let particleSymbol: String

    static func forMode(_ mode: SolitaireMode) -> ModeTheme {
        switch mode {
        case .glyphLink:
            return ModeTheme(
                feltTop: Color(red: 0.14, green: 0.08, blue: 0.38),
                feltMid: Color(red: 0.10, green: 0.06, blue: 0.28),
                feltBottom: Color(red: 0.05, green: 0.03, blue: 0.16),
                feltGlow: Color(red: 0.55, green: 0.35, blue: 0.95),
                accent: Color(red: 0.62, green: 0.42, blue: 0.98),
                accentLight: Color(red: 0.78, green: 0.62, blue: 1.0),
                gold: Color(red: 0.95, green: 0.82, blue: 0.45),
                tableSurface: Color(red: 0.97, green: 0.95, blue: 1.0),
                tableSurface2: Color(red: 0.92, green: 0.88, blue: 0.98),
                tableBorder: Color(red: 0.68, green: 0.55, blue: 0.88),
                tableFrame: Color(red: 0.82, green: 0.62, blue: 0.98),
                particleSymbol: "sparkles"
            )
        case .glyphChain:
            return ModeTheme(
                feltTop: Color(red: 0.02, green: 0.28, blue: 0.36),
                feltMid: Color(red: 0.02, green: 0.20, blue: 0.28),
                feltBottom: Color(red: 0.01, green: 0.10, blue: 0.14),
                feltGlow: Color(red: 0.15, green: 0.85, blue: 0.92),
                accent: Color(red: 0.10, green: 0.72, blue: 0.88),
                accentLight: Color(red: 0.35, green: 0.92, blue: 0.98),
                gold: Color(red: 0.45, green: 0.95, blue: 0.98),
                tableSurface: Color(red: 0.94, green: 0.99, blue: 1.0),
                tableSurface2: Color(red: 0.86, green: 0.96, blue: 0.98),
                tableBorder: Color(red: 0.45, green: 0.78, blue: 0.88),
                tableFrame: Color(red: 0.25, green: 0.88, blue: 0.95),
                particleSymbol: "bolt.fill"
            )
        case .glyphRush:
            return ModeTheme(
                feltTop: Color(red: 0.38, green: 0.10, blue: 0.06),
                feltMid: Color(red: 0.28, green: 0.06, blue: 0.04),
                feltBottom: Color(red: 0.14, green: 0.02, blue: 0.02),
                feltGlow: Color(red: 0.98, green: 0.45, blue: 0.18),
                accent: Color(red: 0.98, green: 0.38, blue: 0.12),
                accentLight: Color(red: 1.0, green: 0.58, blue: 0.28),
                gold: Color(red: 1.0, green: 0.75, blue: 0.22),
                tableSurface: Color(red: 1.0, green: 0.97, blue: 0.94),
                tableSurface2: Color(red: 0.98, green: 0.90, blue: 0.84),
                tableBorder: Color(red: 0.92, green: 0.62, blue: 0.42),
                tableFrame: Color(red: 0.98, green: 0.55, blue: 0.22),
                particleSymbol: "flame.fill"
            )
        case .glyphZen:
            return ModeTheme(
                feltTop: Color(red: 0.18, green: 0.26, blue: 0.22),
                feltMid: Color(red: 0.12, green: 0.20, blue: 0.18),
                feltBottom: Color(red: 0.06, green: 0.10, blue: 0.09),
                feltGlow: Color(red: 0.55, green: 0.78, blue: 0.62),
                accent: Color(red: 0.42, green: 0.68, blue: 0.52),
                accentLight: Color(red: 0.62, green: 0.85, blue: 0.68),
                gold: Color(red: 0.82, green: 0.92, blue: 0.72),
                tableSurface: Color(red: 0.97, green: 0.99, blue: 0.96),
                tableSurface2: Color(red: 0.92, green: 0.96, blue: 0.92),
                tableBorder: Color(red: 0.68, green: 0.82, blue: 0.72),
                tableFrame: Color(red: 0.72, green: 0.88, blue: 0.75),
                particleSymbol: "leaf.fill"
            )
        }
    }

    static func palette(for mode: SolitaireMode) -> ModeTheme { forMode(mode) }
}

enum AppTheme {
    static let feltTop = Color(red: 0.06, green: 0.42, blue: 0.30)
    static let feltMid = Color(red: 0.04, green: 0.32, blue: 0.22)
    static let feltBottom = Color(red: 0.02, green: 0.18, blue: 0.12)
    static let feltGlow = Color(red: 0.18, green: 0.72, blue: 0.52)

    static let tableSurface = Color(red: 0.99, green: 0.98, blue: 0.96)
    static let tableSurface2 = Color(red: 0.96, green: 0.94, blue: 0.90)
    static let tableBorder = Color(red: 0.78, green: 0.70, blue: 0.55)
    static let tableGoldFrame = Color(red: 0.88, green: 0.72, blue: 0.28)

    static let panelFill = Color.white.opacity(0.14)
    static let panelFillStrong = Color.white.opacity(0.24)
    static let panelStroke = Color.white.opacity(0.38)
    static let glassHighlight = Color.white.opacity(0.55)
    static let textOnGreen = Color.white
    static let textMutedOnGreen = Color.white.opacity(0.86)

    static let textOnTable = Color(red: 0.10, green: 0.14, blue: 0.18)
    static let textMutedOnTable = Color(red: 0.38, green: 0.44, blue: 0.50)

    static let gold = Color(red: 1.0, green: 0.88, blue: 0.42)
    static let goldLight = Color(red: 1.0, green: 0.95, blue: 0.72)
    static let goldDark = Color(red: 0.72, green: 0.54, blue: 0.08)
    static let accent = Color(red: 0.12, green: 0.68, blue: 0.48)
    static let accentLight = Color(red: 0.28, green: 0.82, blue: 0.60)
    static let accentPressed = Color(red: 0.06, green: 0.52, blue: 0.36)
    static let danger = Color(red: 0.95, green: 0.32, blue: 0.34)
    static let success = Color(red: 0.22, green: 0.82, blue: 0.52)

    static let cornerRadius: CGFloat = 18
    static let buttonHeight: CGFloat = 56
    static let minTap: CGFloat = 44
    static let cardCornerRatio: CGFloat = 0.10

    static func titleFont(_ size: CGFloat = 32) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }

    static func bodyFont(_ weight: Font.Weight = .medium) -> Font {
        .system(.body, design: .rounded, weight: weight)
    }

    static var primaryButtonGradient: LinearGradient {
        LinearGradient(
            colors: [accentLight, accent, accentPressed],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var goldShineGradient: LinearGradient {
        LinearGradient(
            colors: [goldLight, gold, goldDark.opacity(0.9)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func primaryButtonGradient(theme: ModeTheme) -> LinearGradient {
        LinearGradient(
            colors: [theme.accentLight, theme.accent, theme.accent.opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
