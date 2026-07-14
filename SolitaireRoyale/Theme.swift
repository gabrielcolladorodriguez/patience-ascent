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

    static let game = ModeTheme(
        feltTop: Color(red: 0.10, green: 0.14, blue: 0.32),
        feltMid: Color(red: 0.06, green: 0.10, blue: 0.24),
        feltBottom: Color(red: 0.03, green: 0.05, blue: 0.14),
        feltGlow: Color(red: 0.42, green: 0.55, blue: 0.98),
        accent: Color(red: 0.38, green: 0.52, blue: 0.98),
        accentLight: Color(red: 0.58, green: 0.70, blue: 1.0),
        gold: Color(red: 0.98, green: 0.82, blue: 0.38),
        tableSurface: Color(red: 0.14, green: 0.16, blue: 0.22),
        tableSurface2: Color(red: 0.10, green: 0.12, blue: 0.18),
        tableBorder: Color(red: 0.32, green: 0.38, blue: 0.52),
        tableFrame: Color(red: 0.55, green: 0.62, blue: 0.88),
        particleSymbol: "square.fill"
    )
}

enum BlockPalette {
    static let colors: [Color] = [
        Color(red: 0.96, green: 0.38, blue: 0.42),
        Color(red: 0.32, green: 0.72, blue: 0.98),
        Color(red: 0.48, green: 0.88, blue: 0.52),
        Color(red: 0.98, green: 0.72, blue: 0.28),
        Color(red: 0.78, green: 0.48, blue: 0.98),
        Color(red: 0.98, green: 0.52, blue: 0.72)
    ]

    static func color(for index: Int) -> Color {
        colors[max(0, index) % colors.count]
    }
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

    static let textOnTable = Color(red: 0.92, green: 0.94, blue: 0.98)
    static let textMutedOnTable = Color(red: 0.68, green: 0.72, blue: 0.82)

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
