import SwiftUI

enum AppTheme {
    // Fieltro — menús (alto contraste)
    static let feltTop = Color(red: 0.11, green: 0.48, blue: 0.32)
    static let feltBottom = Color(red: 0.05, green: 0.24, blue: 0.16)
    static let feltGlow = Color(red: 0.20, green: 0.62, blue: 0.42)

    // Mesa — área de juego
    static let tableSurface = Color(red: 0.98, green: 0.97, blue: 0.94)
    static let tableBorder = Color(red: 0.82, green: 0.76, blue: 0.62)
    static let tableGoldFrame = Color(red: 0.79, green: 0.65, blue: 0.28)

    // Paneles sobre verde
    static let panelFill = Color.white.opacity(0.16)
    static let panelFillStrong = Color.white.opacity(0.22)
    static let panelStroke = Color.white.opacity(0.28)
    static let textOnGreen = Color.white
    static let textMutedOnGreen = Color.white.opacity(0.82)

    // Texto sobre mesa blanca
    static let textOnTable = Color(red: 0.12, green: 0.16, blue: 0.20)
    static let textMutedOnTable = Color(red: 0.35, green: 0.40, blue: 0.46)

    // Acentos
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.35)
    static let goldDark = Color(red: 0.75, green: 0.58, blue: 0.10)
    static let accent = Color(red: 0.22, green: 0.62, blue: 0.44)
    static let accentPressed = Color(red: 0.14, green: 0.48, blue: 0.34)
    static let danger = Color(red: 0.92, green: 0.35, blue: 0.32)
    static let success = Color(red: 0.30, green: 0.78, blue: 0.48)

    static let cornerRadius: CGFloat = 16
    static let buttonHeight: CGFloat = 54
    static let minTap: CGFloat = 44

    static func titleFont(_ size: CGFloat = 32) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }

    static func bodyFont(_ weight: Font.Weight = .medium) -> Font {
        .system(.body, design: .rounded, weight: weight)
    }
}
