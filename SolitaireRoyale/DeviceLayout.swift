import SwiftUI

/// Layout que cabe en pantalla sin scroll (iPhone + iPad portrait).
enum DeviceLayout {
    static func isPad(_ width: CGFloat) -> Bool { width >= 600 }

    static func menuMaxWidth(for width: CGFloat) -> CGFloat {
        isPad(width) ? min(440, width * 0.58) : width
    }

    /// Calcula ancho de carta para que el tablero quepa en `boardSize`.
    static func fittedCardWidth(
        for mode: SolitaireMode,
        boardSize: CGSize,
        maxStackDepth: Int
    ) -> CGFloat {
        let w = max(boardSize.width, 260)
        let h = max(boardSize.height, 200)
        let depth = CGFloat(max(1, maxStackDepth))
        let stackRatio: CGFloat = 0.14

        let widthBased: CGFloat
        let heightBased: CGFloat

        switch mode {
        case .klondike, .yukon:
            widthBased = w / 7.6
            heightBased = (h - widthBased * 1.5) / (1.38 + (depth - 1) * stackRatio)
        case .freeCell:
            widthBased = w / 4.8
            heightBased = (h - widthBased * 1.6) / (1.38 + (depth - 1) * stackRatio)
        case .golf:
            widthBased = w / 7.8
            heightBased = (h - widthBased * 3.2) / 1.38
        case .pyramid:
            widthBased = (w - 24) / 7.2
            heightBased = (h - widthBased * 8.5) / 1.38
        case .triPeaks:
            widthBased = (w - 20) / 7.2
            heightBased = (h - widthBased * 5.5) / 1.38
        case .spider, .fortyThieves:
            let cols: CGFloat = 10
            widthBased = w / (cols + 0.8)
            heightBased = (h - widthBased * 1.8) / (1.38 + (depth - 1) * stackRatio)
        }

        let raw = min(widthBased, heightBased)
        let cap: CGFloat = isPad(w) ? 72 : 68
        let floor: CGFloat = isPad(w) ? 28 : 24
        return min(max(raw, floor), cap)
    }

    static func stackOffset(for cardW: CGFloat, depth: Int) -> CGFloat {
        let ratio: CGFloat = depth > 12 ? 0.11 : (depth > 8 ? 0.13 : 0.15)
        return cardW * ratio
    }

    static func cardHeight(for cardW: CGFloat) -> CGFloat { cardW * 1.38 }

    static func columnSpacing(for cardW: CGFloat, mode: SolitaireMode) -> CGFloat {
        switch mode {
        case .spider, .fortyThieves: return max(1, cardW * 0.04)
        default: return max(2, cardW * 0.06)
        }
    }
}
