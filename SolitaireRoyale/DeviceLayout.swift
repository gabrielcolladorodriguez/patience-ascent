import SwiftUI

/// Layout for portrait puzzle boards (iPhone + iPad).
enum DeviceLayout {
    static func isPad(_ width: CGFloat) -> Bool { width >= 600 }

    static func menuMaxWidth(for width: CGFloat) -> CGFloat {
        isPad(width) ? min(440, width * 0.58) : width
    }

    static func fittedGlyphTileSize(boardSize: CGSize) -> CGFloat {
        let w = max(boardSize.width, 240)
        let h = max(boardSize.height, 280)
        let gap: CGFloat = 4
        let widthBased = (w - gap * CGFloat(GlyphLinkEngine.cols - 1)) / CGFloat(GlyphLinkEngine.cols)
        let heightBased = (h - gap * CGFloat(GlyphLinkEngine.rows - 1)) / CGFloat(GlyphLinkEngine.rows)
        let raw = min(widthBased, heightBased)
        let cap: CGFloat = isPad(w) ? 64 : 56
        let floor: CGFloat = isPad(w) ? 30 : 26
        return min(max(raw, floor), cap)
    }
}
