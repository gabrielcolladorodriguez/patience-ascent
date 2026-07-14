import SwiftUI

enum GlyphKind: Int, CaseIterable, Codable, Equatable {
    case moon
    case drop
    case leaf
    case flame
    case star
    case bolt

    var symbol: String {
        switch self {
        case .moon: return "moon.fill"
        case .drop: return "drop.fill"
        case .leaf: return "leaf.fill"
        case .flame: return "flame.fill"
        case .star: return "star.fill"
        case .bolt: return "bolt.fill"
        }
    }

    var color: Color {
        switch self {
        case .moon: return Color(red: 0.72, green: 0.58, blue: 0.95)
        case .drop: return Color(red: 0.35, green: 0.72, blue: 0.98)
        case .leaf: return Color(red: 0.42, green: 0.82, blue: 0.48)
        case .flame: return Color(red: 0.98, green: 0.55, blue: 0.28)
        case .star: return AppTheme.gold
        case .bolt: return Color(red: 0.98, green: 0.86, blue: 0.32)
        }
    }
}

struct GridPos: Hashable, Codable {
    let row: Int
    let col: Int
}
