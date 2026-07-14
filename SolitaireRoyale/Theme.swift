import SwiftUI

enum AppTheme {
    // Felt green — menus & chrome
    static let feltTop = Color(red: 0.09, green: 0.42, blue: 0.28)
    static let feltBottom = Color(red: 0.04, green: 0.22, blue: 0.14)

    // Card table — game area
    static let tableSurface = Color(red: 0.97, green: 0.96, blue: 0.93)
    static let tableBorder = Color(red: 0.88, green: 0.84, blue: 0.76)

    // Panels & text on green
    static let panelFill = Color.white.opacity(0.14)
    static let panelStroke = Color.white.opacity(0.22)
    static let textOnGreen = Color.white
    static let textMutedOnGreen = Color.white.opacity(0.78)

    // Panels & text on table (white)
    static let textOnTable = Color(red: 0.15, green: 0.18, blue: 0.22)
    static let textMutedOnTable = Color(red: 0.38, green: 0.42, blue: 0.48)

    // Accents
    static let gold = Color(red: 0.95, green: 0.78, blue: 0.28)
    static let goldDark = Color(red: 0.72, green: 0.55, blue: 0.12)
    static let accent = Color(red: 0.18, green: 0.55, blue: 0.38)
    static let accentPressed = Color(red: 0.12, green: 0.42, blue: 0.30)

    static let cornerRadius: CGFloat = 16
    static let buttonHeight: CGFloat = 52
}
