import SwiftUI

/// Métricas adaptativas iPhone / iPad (portrait).
enum DeviceLayout {
    static func isPad(_ width: CGFloat) -> Bool { width >= 600 }
    static func isLargePhone(_ width: CGFloat) -> Bool { width >= 390 && width < 600 }

    /// Ancho máximo del contenido en menús (centrado en iPad).
    static func menuMaxWidth(for width: CGFloat) -> CGFloat {
        if isPad(width) { return min(480, width * 0.62) }
        return width
    }

    /// Padding horizontal según dispositivo.
    static func horizontalPadding(for width: CGFloat) -> CGFloat {
        isPad(width) ? 28 : 16
    }

    /// Escala de cartas según modo y ancho disponible.
    static func cardWidth(for mode: SolitaireMode, in size: CGSize) -> CGFloat {
        let w = max(size.width, 280)
        let pad = isPad(w)

        switch mode {
        case .klondike, .yukon:
            if pad { return min(w * 0.13, 88) }
            return min(w * 0.195, isLargePhone(w) ? 78 : 72)
        case .freeCell, .golf:
            if pad { return min(w * 0.14, 90) }
            return min(w * 0.21, 80)
        case .pyramid:
            let fit = (w - 24) / 7.1
            return min(max(fit, w * 0.15), pad ? 82 : 74)
        case .triPeaks:
            let fit = (w - 28) / 7.4
            return min(max(fit, w * 0.13), pad ? 68 : 58)
        case .spider, .fortyThieves:
            if pad { return min(w * 0.09, 56) }
            return min(w * 0.115, 50)
        }
    }

    static func stackOffset(for cardW: CGFloat) -> CGFloat { cardW * 0.17 }
    static func cardHeight(for cardW: CGFloat) -> CGFloat { cardW * 1.42 }
}
