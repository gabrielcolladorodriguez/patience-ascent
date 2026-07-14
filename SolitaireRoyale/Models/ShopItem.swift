import Foundation

enum ShopItemKind: String, Codable, CaseIterable, Identifiable {
    case hintPack
    case undoPack
    case cardBackBlue
    case cardBackGreen
    case dailyBoost
    case coinBundleSmall
    case coinBundleLarge

    var id: String { rawValue }

    var title: String {
        switch self {
        case .hintPack: return "Pack 5 Pistas"
        case .undoPack: return "Pack 10 Deshacer"
        case .cardBackBlue: return "Reverso Azul"
        case .cardBackGreen: return "Reverso Verde"
        case .dailyBoost: return "Boost Diario x2"
        case .coinBundleSmall: return "Bolsa 200 Monedas"
        case .coinBundleLarge: return "Cofre 600 Monedas"
        }
    }

    var price: Int {
        switch self {
        case .hintPack: return 120
        case .undoPack: return 150
        case .cardBackBlue: return 300
        case .cardBackGreen: return 300
        case .dailyBoost: return 200
        case .coinBundleSmall: return 0
        case .coinBundleLarge: return 0
        }
    }

    var iconName: String {
        switch self {
        case .hintPack, .undoPack: return "star"
        case .cardBackBlue, .cardBackGreen: return "play"
        case .dailyBoost: return "trophy"
        case .coinBundleSmall, .coinBundleLarge: return "coin"
        }
    }

    var isIAPPlaceholder: Bool {
        self == .coinBundleSmall || self == .coinBundleLarge
    }
}
